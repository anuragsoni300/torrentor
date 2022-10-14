// ignore_for_file: constant_identifier_names, non_constant_identifier_names, avoid_print

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import '../../dartorrent_common/dartorrent_common.dart';
import '../../dht/dht_dart.dart';
import '../../torrent_model/torrent_model.dart';
import '../../torrent_tracker/torrent_tracker.dart';
import 'file/download_file_manager.dart';
import 'file/state_file.dart';
import 'lsd/lsd.dart';
import 'peer/peer.dart';
import 'piece/base_piece_selector.dart';
import 'piece/piece_manager.dart';
import 'peer/peers_manager.dart';
import 'utils.dart';

const MAX_PEERS = 50;
const MAX_IN_PEERS = 10;

abstract class TorrentTask {
  factory TorrentTask.newTask(Torrent metaInfo, String savePath) {
    return _TorrentTask(metaInfo, savePath);
  }
  void startAnnounceUrl(Uri url, Uint8List infoHash);

  int get allPeersNumber;

  int get connectedPeersNumber;

  int get seederNumber;

  /// Current download speed
  double get currentDownloadSpeed;

  /// Current upload speed
  double get uploadSpeed;

  /// Average download speed
  double get averageDownloadSpeed;

  /// Average upload speed
  double get averageUploadSpeed;

  double get utpDownloadSpeed;

  double get utpUploadSpeed;

  int get utpPeerCount;

  /// Downloaded total bytes length
  int? get downloaded;

  /// Downloaded percent
  double get progress;

  /// Start to download
  Future start();

  /// Stop this task
  Future stop();

  bool get isPaused;

  /// Pause task
  void pause();

  /// Resume task
  void resume();

  void requestPeersFromDHT();

  bool onTaskComplete(void Function() handler);

  bool offTaskComplete(void Function() handler);

  bool onFileComplete(void Function(String filepath) handler);

  bool offFileComplete(void Function(String filepath) handler);

  bool onStop(void Function() handler);

  bool offStop(void Function() handler);

  bool onPause(void Function() handler);

  bool offPause(void Function() handler);

  bool onResume(void Function() handler);

  bool offResume(void Function() handler);

  /// 增加DHT node，一般是将torrent文件中的nodes加入进去。
  ///
  /// 当然也可以直接添加已知的node地址
  void addDHTNode(Uri uri);

  /// 添加已知的Peer地址
  void addPeer(CompactAddress address,
      [PeerType type = PeerType.TCP, Socket socket]);
}

class _TorrentTask implements TorrentTask, AnnounceOptionsProvider {
  static InternetAddress LOCAL_ADDRESS =
      InternetAddress.fromRawAddress(Uint8List.fromList([127, 0, 0, 1]));

  final Set<void Function()> _taskCompleteHandlers = {};

  final Set<void Function(String filePath)> _fileCompleteHandlers = {};

  final Set<void Function()> _stopHandlers = {};

  final Set<void Function()> _resumeHandlers = {};

  final Set<void Function()> _pauseHandlers = {};

  TorrentAnnounceTracker? _tracker;

  DHT? _dht;

  LSD? _lsd;

  StateFile? _stateFile;

  PieceManager? _pieceManager;

  DownloadFileManager? _fileManager;

  PeersManager? _peersManager;

  final Torrent? _metaInfo;

  final String _savePath;

  final Set<String> _peerIds = {};

  String? _peerId; // 这个是生成的本地peer的id，和Peer类的id是两回事

  ServerSocket? _serverSocket;

  final Set<InternetAddress> _cominIp = {};

  bool _paused = false;

  _TorrentTask(this._metaInfo, this._savePath) {
    _peerId = generatePeerId();
  }

  @override
  double get averageDownloadSpeed {
    if (_peersManager != null) {
      return _peersManager!.averageDownloadSpeed;
    } else {
      return 0.0;
    }
  }

  @override
  double get averageUploadSpeed {
    if (_peersManager != null) {
      return _peersManager!.averageUploadSpeed;
    } else {
      return 0.0;
    }
  }

  @override
  double get currentDownloadSpeed {
    if (_peersManager != null) {
      return _peersManager!.currentDownloadSpeed;
    } else {
      return 0.0;
    }
  }

  @override
  double get uploadSpeed {
    if (_peersManager != null) {
      return _peersManager!.uploadSpeed;
    } else {
      return 0.0;
    }
  }

  String? _infoHashString;

  Timer? _dhtRepeatTimer;

  Future<PeersManager?> _init(Torrent? model, String savePath) async {
    _dht = DHT();
    _lsd = LSD(model?.infoHash, _peerId);
    _infoHashString =
        String.fromCharCodes(model?.infoHashBuffer as Iterable<int>);
    _tracker ??= TorrentAnnounceTracker(this);
    _stateFile ??= await StateFile.getStateFile(savePath, model);
    _pieceManager ??= PieceManager.createPieceManager(
        BasePieceSelector(), model, _stateFile?.bitfield);
    _fileManager ??= await DownloadFileManager.createFileManager(
        model, savePath, _stateFile);
    _peersManager ??= PeersManager(
        _peerId, _pieceManager, _pieceManager, _fileManager, model);
    return _peersManager;
  }

  @override
  void addPeer(CompactAddress address,
      [PeerType type = PeerType.TCP, Socket? socket]) {
    _peersManager?.addNewPeerAddress(address, type, socket);
  }

  void _whenTaskDownloadComplete() async {
    await _peersManager
        ?.disposeAllSeeder('Download complete,disconnect seeder');
    await _tracker?.complete();
    _fireTaskComplete();
  }

  void _whenFileDownloadComplete(String filePath) {
    _fireFileComplete(filePath);
  }

  void _processTrackerPeerEvent(Tracker source, PeerEvent? event) {
    if (event == null) return;
    var ps = event.peers;
    if (ps != null && ps.isNotEmpty) {
      for (var url in ps) {
        _processNewPeerFound(url);
      }
    }
  }

  void _processLSDPeerEvent(CompactAddress address, String infoHash) {
    print('居然有LSD');
  }

  void _processNewPeerFound(CompactAddress url) {
    _peersManager?.addNewPeerAddress(url);
  }

  void _processDHTPeer(CompactAddress peer, String infoHash) {
    if (infoHash == _infoHashString) {
      _processNewPeerFound(peer);
    }
  }

  void _hookInPeer(Socket socket) {
    if (socket.remoteAddress == LOCAL_ADDRESS) {
      socket.close();
      return;
    }
    if (_cominIp.length >= MAX_IN_PEERS || !_cominIp.add(socket.address)) {
      socket.close();
      return;
    }
    log('incoming connect: ${socket.remoteAddress.address}:${socket.remotePort}',
        name: runtimeType.toString());
    _peersManager?.addNewPeerAddress(
        CompactAddress(socket.address, socket.port), PeerType.TCP, socket);
  }

  @override
  void pause() {
    if (_paused) return;
    _paused = true;
    _peersManager?.pause();
    _fireTaskPaused();
  }

  @override
  bool get isPaused => _paused;

  @override
  void resume() {
    if (isPaused) {
      _paused = false;
      _peersManager?.resume();
      _fireTaskResume();
    }
  }

  @override
  Future start() async {
    // 进入的peer：
    _serverSocket ??= await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    await _init(_metaInfo, _savePath);
    _serverSocket?.listen(_hookInPeer);
    // _utpServer ??= await ServerUTPSocket.bind(InternetAddress.anyIPv4, 0);
    // _utpServer.listen(_hookUTP);
    // print(_utpServer.port);

    var map = {};
    map['name'] = _metaInfo?.name;
    map['tcp_socket'] = _serverSocket?.port;
    map['comoplete_pieces'] = List.from(_stateFile!.bitfield!.completedPieces);
    map['total_pieces_num'] = _stateFile!.bitfield!.piecesNum;
    map['downloaded'] = _stateFile!.downloaded;
    map['uploaded'] = _stateFile!.uploaded;
    map['total_length'] = _metaInfo?.length;
    // 主动访问的peer:
    _tracker?.onPeerEvent(_processTrackerPeerEvent);
    _peersManager?.onAllComplete(_whenTaskDownloadComplete);
    _fileManager?.onFileComplete(_whenFileDownloadComplete);

    _lsd?.onLSDPeer(_processLSDPeerEvent);
    _lsd?.port = _serverSocket!.port;
    _lsd?.start();

    _dht?.announce(
        String.fromCharCodes(_metaInfo!.infoHashBuffer!), _serverSocket!.port);
    _dht?.onNewPeer(_processDHTPeer);
    // ignore: unawaited_futures
    _dht?.bootstrap();
    if (_fileManager!.isAllComplete) {
      // ignore: unawaited_futures
      _tracker?.complete();
    } else {
      _tracker?.runTrackers(_metaInfo?.announces, _metaInfo?.infoHashBuffer!,
          event: EVENT_STARTED);
    }

    return map;
  }

  @override
  Future stop([bool force = false]) async {
    await _tracker?.stop(force);
    var tempHandler = Set<Function>.from(_stopHandlers);
    await dispose();
    for (var element in tempHandler) {
      Timer.run(() => element());
    }
    tempHandler.clear();
    tempHandler = {};
  }

  Future dispose() async {
    _dhtRepeatTimer?.cancel();
    _dhtRepeatTimer = null;
    _fileCompleteHandlers.clear();
    _taskCompleteHandlers.clear();
    _pauseHandlers.clear();
    _resumeHandlers.clear();
    _stopHandlers.clear();
    _tracker?.offPeerEvent(_processTrackerPeerEvent);
    _peersManager?.offAllComplete(_whenTaskDownloadComplete);
    _fileManager?.offFileComplete(_whenFileDownloadComplete);
    // 这是有顺序的,先停止tracker运行,然后停止监听serversocket以及所有的peer,最后关闭文件系统
    await _tracker?.dispose();
    _tracker = null;
    await _peersManager?.dispose();
    _peersManager = null;
    await _serverSocket?.close();
    _serverSocket = null;
    await _fileManager?.close();
    _fileManager = null;
    await _dht?.stop();
    _dht = null;

    _lsd?.close();
    _lsd = null;
    _peerIds.clear();
    _cominIp.clear();
    return;
  }

  @override
  Future<Map<String, dynamic>> getOptions(Uri? uri, String? infoHash) {
    var map = {
      'downloaded': _stateFile?.downloaded,
      'uploaded': _stateFile?.uploaded,
      'left': _metaInfo!.length! - _stateFile!.downloaded,
      'numwant': 50,
      'compact': 1,
      'peerId': _peerId,
      'port': _serverSocket?.port
    };
    return Future.value(map);
  }

  @override
  bool offFileComplete(void Function(String filepath) handler) {
    return _fileCompleteHandlers.remove(handler);
  }

  void _fireFileComplete(String filepath) {
    for (var handler in _fileCompleteHandlers) {
      Timer.run(() => handler(filepath));
    }
  }

  @override
  bool offPause(void Function() handler) {
    return _pauseHandlers.remove(handler);
  }

  @override
  bool offResume(void Function() handler) {
    return _resumeHandlers.remove(handler);
  }

  @override
  bool offStop(void Function() handler) {
    return _stopHandlers.remove(handler);
  }

  @override
  bool offTaskComplete(void Function() handler) {
    return _taskCompleteHandlers.remove(handler);
  }

  @override
  bool onFileComplete(void Function(String filepath) handler) {
    return _fileCompleteHandlers.add(handler);
  }

  @override
  bool onPause(void Function() handler) {
    return _pauseHandlers.add(handler);
  }

  @override
  bool onResume(void Function() handler) {
    return _resumeHandlers.add(handler);
  }

  @override
  bool onStop(void Function() handler) {
    return _stopHandlers.add(handler);
  }

  @override
  bool onTaskComplete(void Function() handler) {
    return _taskCompleteHandlers.add(handler);
  }

  void _fireTaskComplete() {
    for (var element in _taskCompleteHandlers) {
      Timer.run(() => element());
    }
  }

  @override
  int? get downloaded => _fileManager?.downloaded;

  @override
  double get progress {
    var d = downloaded;
    if (d == null) return 0.0;
    var l = _metaInfo?.length;
    if (l == null) return 0.0;
    return d / l;
  }

  void _fireTaskPaused() {
    for (var element in _pauseHandlers) {
      Timer.run(() => element());
    }
  }

  void _fireTaskResume() {
    for (var element in _resumeHandlers) {
      Timer.run(() => element());
    }
  }

  @override
  int get allPeersNumber {
    if (_peersManager != null) {
      return _peersManager!.peersNumber;
    } else {
      return 0;
    }
  }

  @override
  void addDHTNode(Uri url) {
    _dht?.addBootstrapNode(url);
  }

  @override
  int get connectedPeersNumber {
    if (_peersManager != null) {
      return _peersManager!.connectedPeersNumber;
    } else {
      return 0;
    }
  }

  @override
  int get seederNumber {
    if (_peersManager != null) {
      return _peersManager!.seederNumber;
    } else {
      return 0;
    }
  }

  @override
  double get utpDownloadSpeed {
    if (_peersManager == null) return 0.0;
    return _peersManager!.utpDownloadSpeed;
  }

  @override
  double get utpUploadSpeed {
    if (_peersManager == null) return 0.0;
    return _peersManager!.utpUploadSpeed;
  }

  @override
  int get utpPeerCount {
    if (_peersManager == null) return 0;
    return _peersManager!.utpPeerCount;
  }

  @override
  void startAnnounceUrl(Uri url, Uint8List infoHash) {
    _tracker?.runTracker(url, infoHash);
  }

  @override
  void requestPeersFromDHT() {
    if (_metaInfo == null) return;
    _dht?.requestPeers(String.fromCharCodes(_metaInfo!.infoHashBuffer!));
  }
}
