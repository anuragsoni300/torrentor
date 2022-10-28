// ignore_for_file: constant_identifier_names, library_private_types_in_public_api, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'utp_data.dart';

const MAX_TIMEOUT = 5;

/// 100 ms = 100000 micro seconds
const CCONTROL_TARGET = 100000;

/// Each UDP packet should less than 1400 bytes
const MAX_PACKET_SIZE = 1382;

const MIN_PACKET_SIZE = 150;

const MAX_CWND_INCREASE_PACKETS_PER_RTT = 3000;

///
/// UTP socket client.
///
/// This class can connect remote UTP socket. One UTPSocketClient
/// can create multiple UTPSocket.
///
/// See also [ServerUTPSocket]
class UTPSocketClient extends _UTPCloseHandler with _UTPSocketRecorder {
  bool _closed = false;

  /// Has it been destroyed
  bool get isClosed => _closed;

  /// Each UDP socket can handler max connections
  final int maxSockets;

  RawDatagramSocket? _rawSocket;

  UTPSocketClient([this.maxSockets = 10]);

  InternetAddress? address;

  final Map<int, Completer<UTPSocket>> _connectingSocketMap = {};

  bool get isFull => indexMap.length >= maxSockets;

  bool get isNotFull => !isFull;

  /// Connect remote UTP server socket.
  ///
  /// If [remoteAddress] and [remotePort] related socket was connectted already ,
  /// it will return a `Future` with `UTPSocket` instance directly;
  ///
  /// or this method will try to create a new `UTPSocket` instance to connect remote,
  /// once connect succesffully , the return `Future` will complete with the instance ,
  /// if connect fail , the `Future` will complete with an exception.
  Future<UTPSocket?> connect(InternetAddress? remoteAddress, int? remotePort,
      [int localPort = 0]) async {
    _closed = false;
    assert(remotePort != null && remoteAddress != null,
        'Address and port can not be null');
    if (indexMap.length >= maxSockets) return null;
    if (_rawSocket == null) {
      _rawSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, localPort);
      _rawSocket!.listen((event) => _onData(event),
          onDone: () => _onDone(), onError: (e) => _onError(e));
    }

    var connId = Random().nextInt(MAX_UINT16);
    var utp = _UTPSocket(_rawSocket!, remoteAddress!, remotePort!);
    var completer = Completer<UTPSocket>();
    _connectingSocketMap[connId] = completer;

    utp.connectionState =
        _UTPConnectState.SYN_SENT; //Modify socket connection status
    // Initialize send_id and _receive_id
    utp.receiveId = connId; //Initially a random connection id
    utp.sendId = (utp.receiveId! + 1) & MAX_UINT16;
    utp.sendId = utp.sendId! & MAX_UINT16; // prevent overflow
    utp.currentLocalSeq = Random().nextInt(MAX_UINT16); // random one seq;
    utp.lastRemoteSeq =
        0; // This is set to 0, and the remote seq is not obtained at the beginning
    utp.lastRemotePktTimestamp = 0;
    utp.closeHandler = this;
    var packet = UTPPacket(ST_SYN, connId, 0, 0, utp.maxWindowSize,
        utp.currentLocalSeq, utp.lastRemoteSeq);
    utp.sendPacket(packet, 0, true, true);
    recordUTPSocket(connId, utp);
    return completer.future;
  }

  void _onData(RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      var datagram = _rawSocket!.receive();
      if (datagram == null) return;
      var address = datagram.address;
      var port = datagram.port;
      UTPPacket? data;
      try {
        data = parseData(datagram.data);
      } catch (e) {
        dev.log('Process receive data error :',
            error: e, name: runtimeType.toString());
        return;
      }
      if (data == null) {
        dev.log('Process receive data error :',
            error: 'Data is null', name: runtimeType.toString());
        return;
      }
      var connId = data.connectionId;
      var utp = findUTPSocket(connId);
      if (utp == null) {
        dev.log('UTP error',
            error: 'Can not find connection $connId',
            name: runtimeType.toString());
        return;
      }
      var completer = _connectingSocketMap.remove(connId);
      _processReceiveData(utp._socket, address, port, data, utp,
          onConnected: (socket) {
            socket.closeHandler = this;
            completer?.complete(socket);
          },
          onError: (socket, error) => completer?.completeError(error));
    }
  }

  void _onDone() async {
    await close('Local/Remote closed the connection');
  }

  void _onError(dynamic e) {
    dev.log('UDP socket error:', error: e, name: runtimeType.toString());
  }

  /// Close the raw UDP socket and all UTP sockets
  Future close([dynamic reason]) async {
    if (isClosed) return;
    _closed = true;
    _rawSocket?.close();
    _rawSocket = null;
    var f = <Future>[];
    indexMap.forEach((key, socket) {
      var r = socket.close();
      f.add(r);
    });
    clean();

    _connectingSocketMap.forEach((key, c) {
      if (!c.isCompleted) {
        c.completeError('Socket was disposed');
      }
    });
    _connectingSocketMap.clear();
    return Stream.fromFutures(f).toList();
  }

  @override
  void socketClosed(_UTPSocket socket) {
    removeUTPSocket(socket.connectionId);
    var completer = _connectingSocketMap.remove(socket.connectionId);
    if (completer != null && !completer.isCompleted) {
      completer.completeError('Connect remote failed');
    }
  }
}

///
/// This class will create a UTP socket to listening income UTP socket.
///
/// See also [UTPSocketClient]
abstract class ServerUTPSocket extends _UTPCloseHandler {
  int? get port;

  InternetAddress? get address;

  Future<dynamic> close([dynamic reason]);

  StreamSubscription<UTPSocket>? listen(void Function(UTPSocket socket) onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError});

  static Future<ServerUTPSocket> bind(dynamic host, [int port = 0]) async {
    var socket = await RawDatagramSocket.bind(host, port);
    return _ServerUTPSocket(socket);
  }
}

class _ServerUTPSocket extends ServerUTPSocket with _UTPSocketRecorder {
  bool _closed = false;

  bool get isClosed => _closed;

  RawDatagramSocket? _socket;

  StreamController<UTPSocket>? _sc;

  _ServerUTPSocket(RawDatagramSocket this._socket) {
    assert(_socket != null, 'UDP socket parameter can not be null');
    _sc = StreamController<UTPSocket>();

    _socket!.listen((event) {
      if (event == RawSocketEvent.read) {
        var datagram = _socket!.receive();
        if (datagram == null) return;
        var address = datagram.address;
        var port = datagram.port;
        UTPPacket? data;
        try {
          data = parseData(datagram.data);
        } catch (e) {
          dev.log('Process receive data error :',
              error: e, name: runtimeType.toString());
          return;
        }
        if (data == null) {
          dev.log('Process receive data error :',
              error: 'Data is null', name: runtimeType.toString());
          return;
        }
        var connId = data.connectionId;
        var utp = findUTPSocket(connId);
        _processReceiveData(_socket, address, port, data, utp,
            newSocket: (socket) {
              recordUTPSocket(socket.connectionId, socket);
              socket.closeHandler = this;
            },
            onConnected: (socket) => _sc?.add(socket));
      }
    }, onDone: () {
      close('Remote/Local socket closed');
    }, onError: (e) {
      dev.log('UDP error:', error: e, name: runtimeType.toString());
    });
  }

  @override
  InternetAddress? get address => _socket?.address;

  @override
  int? get port => _socket?.port;

  @override
  Future<dynamic> close([dynamic reason]) async {
    if (isClosed) return;
    _closed = true;
    var l = <Future>[];
    forEach((socket) {
      var r = socket.close(reason);
      l.add(r);
    });

    await Stream.fromFutures(l).toList();

    _socket?.close();
    _socket = null;
    var re = await _sc?.close();
    _sc = null;
    return re;
  }

  @override
  StreamSubscription<UTPSocket>? listen(void Function(UTPSocket p1) onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _sc?.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  void socketClosed(_UTPSocket socket) {
    removeUTPSocket(socket.connectionId);
  }
}

///
/// Record uTP socket with its remote address and remote port.
///
/// This mixin provide some methods to record/find/remove uTP socket
/// instance.
///
/// This mixin use two simple `Map` to record the socket instance currentlly
mixin _UTPSocketRecorder {
  final Map<int?, _UTPSocket> indexMap = {};

  /// Get the `UTPSocket` via [connectionId]
  ///
  /// If not found , return `null`
  _UTPSocket? findUTPSocket(int connectionId) {
    return indexMap[connectionId];
  }

  /// Record the `UTPSocket` via [connectionId]
  ///
  /// If it have a instance already , it will replace it with the new instance
  void recordUTPSocket(int? connectionId, _UTPSocket s) {
    indexMap[connectionId] = s;
  }

  _UTPSocket? removeUTPSocket(int? connectionId) {
    return indexMap.remove(connectionId);
  }

  /// For each
  void forEach(void Function(UTPSocket socket) processer) {
    indexMap.forEach((key, value) {
      processer(value);
    });
  }

  /// clean the record map
  void clean() {
    indexMap.clear();
  }
}

/// UTP socket
///
/// More details please take a look :
/// [UTP Micro_Transport_Protocol](http://en.wikipedia.org/wiki/Micro_Transport_Protocol)
abstract class UTPSocket extends Socket {
  /// Is UTP socket connected to remote
  bool get isConnected;

  /// 这是用于通讯的真正的UDP socket
  final RawDatagramSocket _socket;

  /// The connection id between this socket with remote socket
  int? get connectionId;

  /// Another side socket internet address
  @override
  final InternetAddress remoteAddress;

  /// Another side socket internet port
  @override
  final int remotePort;

  @override
  InternetAddress get address => _socket.address;

  /// Local internet port
  @override
  int get port => _socket.port;

  /// The max window size. ready-only
  final int maxWindowSize;

  /// The encoding for encode/decode string message.
  ///
  /// See also [write]
  @override
  Encoding encoding;

  /// [_socket] is a UDP socket instance.
  ///
  /// [remoteAddress] and [remotePort] is another side uTP address and port
  ///
  UTPSocket(this._socket, this.remoteAddress, this.remotePort,
      {this.maxWindowSize = 1048576, this.encoding = utf8});

  /// Send ST_FIN message to remote and close the socket.
  ///
  /// If remote don't reply ST_STATE to local for ST_FIN message , this socket
  /// will wait when timeout happen and close itself force.
  ///
  /// If socket is closed , it can't connect agian , if need to reconnect
  /// new a socket instance.
  @override
  Future<dynamic> close([dynamic reason]);

  /// This socket was closed no not
  bool get isClosed;

  /// Useless method
  @Deprecated("message")
  @override
  bool setOption(SocketOption option, bool enabled) {
    // TO DO: implement setOption
    return false;
  }

  /// Useless method
  @Deprecated("message")
  @override
  void setRawOption(RawSocketOption option) {
    // TO DO: implement setRawOption
  }

  /// Useless method
  @Deprecated("message")
  @override
  Uint8List getRawOption(RawSocketOption option) {
    // TO DO: implement getRawOption
    return Uint8List(0);
  }
}

/// UTP socket connection state.
enum _UTPConnectState {
  /// UTP socket send then SYN message to another for connecting
  SYN_SENT,

  /// UTP socket receive a SYN message from another
  SYN_RECV,

  /// UTP socket was connected with another one.
  CONNECTED,

  /// UTP socket was closed
  CLOSED,

  /// UTP socket is closing
  CLOSING
}

abstract class _UTPCloseHandler {
  void socketClosed(_UTPSocket socket);
}

class _UTPSocket extends UTPSocket {
  @override
  bool get isConnected => connectionState == _UTPConnectState.CONNECTED;

  @override
  int? get connectionId => receiveId;

  _UTPConnectState? connectionState;

  // int _timeoutCounterTime = 1000;

  int _packetSize = MIN_PACKET_SIZE;

  final int maxInflightPackets = 2;

  double? _srtt;

  late double _rttvar;

  /// 超时时间，单位微妙
  double _rto = 1000000.0;

  // double _rtt = 0.0;

  // double _rtt_var = 800.0;

  int? sendId;

  int _currentLocalSeq = 0;

  /// Make sure the num dont over max uint16
  int _getUint16Int(int? v) {
    if (v != null) {
      v = v & MAX_UINT16;
    }
    return 0;
  }

  /// The next Packet seq number
  int get currentLocalSeq => _currentLocalSeq;

  set currentLocalSeq(v) => _currentLocalSeq = _getUint16Int(v);

  int _lastRemoteSeq = 0;

  /// The last receive remote packet seq number
  int get lastRemoteSeq => _lastRemoteSeq;

  set lastRemoteSeq(v) => _lastRemoteSeq = _getUint16Int(v);

  int? _lastRemoteAck;

  int? _finalRemoteFINSeq;

  Timer? _FINTimer;

  /// The last packet remote acked.
  int? get lastRemoteAck => _lastRemoteAck;

  set lastRemoteAck(v) => _lastRemoteAck = _getUint16Int(v);

  /// The timestamp when receive the last remote packet
  late int lastRemotePktTimestamp;

  late int remoteWndSize;

  int? receiveId;

  final Map<int, UTPPacket> _inflightPackets = <int, UTPPacket>{};

  final Map<int, Timer> _resendTimer = <int, Timer>{};

  int _currentWindowSize = 0;

  Timer? _rtoTimer;

  bool _closed = false;

  int? minPacketRTT;

  final List<List<int>> _baseDelays = <List<int>>[];

  /// A future control completer that sends a fin message and closes the socket
  Completer? _closeCompleter;

  @override
  bool get isClosed => _closed;

  /// closing
  bool get isClosing => connectionState == _UTPConnectState.CLOSING;

  StreamController<Uint8List>? _receiveDataStreamController;

  final List<UTPPacket> _receivePacketBuffer = <UTPPacket>[];

  Timer? _addDataTimer;

  final List<int> _sendingDataCache = <int>[];

  List<int> _sendingDataBuffer = <int>[];

  final Map<int, int> _duplicateAckCountMap = <int, int>{};

  final Map<int, Timer> _requestSendAckMap = <int, Timer>{};

  Timer? _keepAliveTimer;

  int? _startTimeOffset;

  int? _allowWindowSize;

  _UTPCloseHandler? _handler;

  bool _finSended = false;

  set closeHandler(_UTPCloseHandler h) {
    _handler = h;
  }

  _UTPSocket(RawDatagramSocket socket,
      [InternetAddress? remoteAddress,
      int remotePort = 5001,
      int maxWindow = 1048576,
      Encoding encoding = utf8])
      : super(socket, remoteAddress ?? InternetAddress.anyIPv4, remotePort,
            maxWindowSize: maxWindow, encoding: encoding) {
    _allowWindowSize = MIN_PACKET_SIZE; // _packetSize * 2;
    // _allowWindowSize = maxWindow;
    _packetSize = MIN_PACKET_SIZE;
    _receiveDataStreamController = StreamController<Uint8List>();
  }

  bool isInCurrentAckWindow(int seq) {
    var currentWindow = max(_inflightPackets.length + 3, 3);
    var ma = currentLocalSeq - 1;
    var min = ma - currentWindow;
    if (compareSeqLess(ma, seq) || compareSeqLess(seq, min)) {
      return false;
    }
    return true;
  }

  /// Every time the socket is successfully connected or sends/receives any message (except keepalive messages), a Timer with a delay of 30 seconds is defined.
  ///
  /// Timer triggers to send an ST_STATE message, seq_nr is the next seq sent, and ack_nr is the last received remote seq-1
  void startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer(Duration(seconds: 30), () {
      var ack = 0;
      ack = (_lastRemoteSeq - 1) & MAX_UINT16;
      // dev.log('Send keepalive message', name: runtimeType.toString());
      var packet = UTPPacket(
          ST_STATE, sendId!, 0, 0, maxWindowSize, currentLocalSeq, ack);
      sendPacket(packet, 0, false, false);
    });
  }

  /// Send data will enter through this method
  ///
  /// When there is no data in the sending data buffer and [_closeCompleter] is not empty, a FIN message will be sent to the other party
  ///
  void _requestSendData([List<int>? data]) {
    if (data != null && data.isNotEmpty) _sendingDataBuffer.addAll(data);
    if (_sendingDataBuffer.isEmpty) {
      if (_closeCompleter != null &&
          !_closeCompleter!.isCompleted &&
          _sendingDataCache.isEmpty) {
        // This means that the fin message can be sent at this time
        _sendFIN();
      }
      return;
    }
    var window = min(_allowWindowSize!, remoteWndSize);
    var allowSize = window - _currentWindowSize;
    if (allowSize <= 0) {
      return;
    } else {
      var sendingBufferSize = _sendingDataBuffer.length;
      allowSize = min(allowSize, sendingBufferSize);
      var packetNum = allowSize ~/ _packetSize;
      num remainSize = allowSize.remainder(_packetSize);
      var offset = 0;

      if (packetNum == 0 &&
          _sendingDataCache.isEmpty &&
          sendingBufferSize <= _packetSize) {
        var payload = Uint8List(remainSize as int);
        List.copyRange(
            payload, 0, _sendingDataBuffer, offset, offset + remainSize);
        var packet = newDataPacket(payload);
        if (sendPacket(packet)) {
          offset += remainSize;
        } else {
          _currentLocalSeq--;
          _inflightPackets.remove(packet.seq_nr);
          _currentWindowSize -= packet.length;
        }
      } else {
        for (var i = 0; i < packetNum; i++, offset += _packetSize) {
          var payload = Uint8List(_packetSize);
          List.copyRange(
              payload, 0, _sendingDataBuffer, offset, offset + _packetSize);
          var packet = newDataPacket(payload);
          if (!sendPacket(packet)) {
            _currentLocalSeq--;
            _inflightPackets.remove(packet.seq_nr);
            _currentWindowSize -= packet.length;
            break;
          }
        }
      }
      if (offset != 0) _sendingDataBuffer = _sendingDataBuffer.sublist(offset);
      Timer.run(() => _requestSendData());
      // _requestSendData();
    }
  }

  @override
  Future<bool> any(bool Function(Uint8List) test) {
    return _receiveDataStreamController!.stream.any(test);
  }

  @override
  Stream<E> asyncExpand<E>(Stream<E>? Function(Uint8List) convert) {
    return _receiveDataStreamController!.stream.asyncExpand(convert);
  }

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(Uint8List) convert) {
    return _receiveDataStreamController!.stream.asyncMap(convert);
  }

  @override
  Stream<R> cast<R>() {
    return _receiveDataStreamController!.stream.cast<R>();
  }

  @override
  Future<bool> contains(Object? needle) {
    return _receiveDataStreamController!.stream.contains(needle);
  }

  @override
  Stream<Uint8List> distinct([bool Function(Uint8List, Uint8List)? equals]) {
    return _receiveDataStreamController!.stream.distinct(equals);
  }

  @override
  Future<E> drain<E>([E? futureValue]) {
    return _receiveDataStreamController!.stream.drain<E>(futureValue);
  }

  @override
  Future<Uint8List> elementAt(int index) {
    return _receiveDataStreamController!.stream.elementAt(index);
  }

  @override
  Future<bool> every(bool Function(Uint8List) test) {
    return _receiveDataStreamController!.stream.every(test);
  }

  @override
  Stream<S> expand<S>(Iterable<S> Function(Uint8List) convert) {
    return _receiveDataStreamController!.stream.expand<S>((convert));
  }

  @override
  Future<S> fold<S>(S initialValue, S Function(S, Uint8List) combine) {
    return _receiveDataStreamController!.stream.fold<S>(initialValue, combine);
  }

  @override
  Future<dynamic> forEach(void Function(Uint8List) action) {
    return _receiveDataStreamController!.stream.forEach(action);
  }

  @override
  Stream<Uint8List> handleError(Function onError,
      {bool Function(dynamic)? test}) {
    return _receiveDataStreamController!.stream
        .handleError(onError, test: test);
  }

  @override
  void addError(dynamic error, [StackTrace? stackTrace]) {
    if (isClosed || isClosing) return;
    if (isConnected) _receiveDataStreamController?.addError(error, stackTrace);
  }

  @override
  StreamSubscription<Uint8List> listen(void Function(Uint8List data)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    if (isClosed) throw 'Socket is closed';
    return _receiveDataStreamController!.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  void add(List<int> data) {
    if (isClosed || isClosing) return;
    if (isConnected && data.isNotEmpty) {
      _addDataTimer?.cancel();
      _sendingDataCache.addAll(data);
      if (_sendingDataCache.isEmpty) return;
      _addDataTimer = Timer(Duration.zero, () {
        var d = List<int>.from(_sendingDataCache);
        _sendingDataCache.clear();
        _requestSendData(d);
      });
    }
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    if (isClosed || isClosing) return Future.value();
    if (_receiveDataStreamController == null) return Future.value();
    var c = Completer();
    stream.listen((event) {
      if (isClosed || isClosing) {
        c.completeError('Socket was closed/closing , can not add event');
        return;
      }
      _receiveDataStreamController?.add(Uint8List.fromList(event));
    }, onDone: () {
      c.complete();
    }, onError: (e) {
      c.completeError(e);
    });
    return c.future;
  }

  @override
  Stream<Uint8List> asBroadcastStream(
      {void Function(StreamSubscription<Uint8List> subscription)? onListen,
      void Function(StreamSubscription<Uint8List> subscription)? onCancel}) {
    return _receiveDataStreamController!.stream
        .asBroadcastStream(onListen: onListen, onCancel: onCancel);
  }

  /// Send ST_RESET message to remote and close this socket force.
  @override
  Future destroy() async {
    connectionState = _UTPConnectState.CLOSING;
    await _sendResetMessage(sendId, _socket, remoteAddress, remotePort);
    _closeCompleter ??= Completer();
    closeForce();
    return _closeCompleter!.future;
  }

  @override
  Future get done => _receiveDataStreamController!.done;

  @override
  Future<Uint8List> get first => _receiveDataStreamController!.stream.first;

  @override
  Future<Uint8List> firstWhere(bool Function(Uint8List element) test,
      {Uint8List Function()? orElse}) {
    return _receiveDataStreamController!.stream
        .firstWhere(test, orElse: orElse);
  }

  @Deprecated('Useless')
  @override
  Future flush() {
    // TO DO: implement flush
    return Future(() => null);
  }

  @override
  bool get isBroadcast => _receiveDataStreamController!.stream.isBroadcast;

  @override
  Future<bool> get isEmpty => _receiveDataStreamController!.stream.isEmpty;

  @override
  Future<String> join([String separator = '']) {
    return _receiveDataStreamController!.stream.join(separator);
  }

  @override
  Future<Uint8List> get last => _receiveDataStreamController!.stream.last;

  @override
  Future<Uint8List> lastWhere(bool Function(Uint8List element) test,
      {Uint8List Function()? orElse}) {
    return _receiveDataStreamController!.stream.lastWhere(test, orElse: orElse);
  }

  @override
  Future<int> get length => _receiveDataStreamController!.stream.length;

  @override
  Stream<S> map<S>(S Function(Uint8List event) convert) {
    return _receiveDataStreamController!.stream.map(convert);
  }

  @override
  Future pipe(StreamConsumer<Uint8List> streamConsumer) {
    return _receiveDataStreamController!.stream.pipe(streamConsumer);
  }

  @override
  Future<Uint8List> reduce(
      Uint8List Function(Uint8List previous, Uint8List element) combine) {
    return _receiveDataStreamController!.stream.reduce(combine);
  }

  @override
  Future<Uint8List> get single => _receiveDataStreamController!.stream.single;

  @override
  Future<Uint8List> singleWhere(bool Function(Uint8List element) test,
      {Uint8List Function()? orElse}) {
    return _receiveDataStreamController!.stream
        .singleWhere(test, orElse: orElse);
  }

  @override
  Stream<Uint8List> skip(int count) {
    return _receiveDataStreamController!.stream.skip(count);
  }

  @override
  Stream<Uint8List> skipWhile(bool Function(Uint8List element) test) {
    return _receiveDataStreamController!.stream.skipWhile(test);
  }

  @override
  Stream<Uint8List> take(int count) {
    return _receiveDataStreamController!.stream.take(count);
  }

  @override
  Stream<Uint8List> takeWhile(bool Function(Uint8List element) test) {
    return _receiveDataStreamController!.stream.takeWhile(test);
  }

  @override
  Stream<Uint8List> timeout(Duration timeLimit,
      {void Function(EventSink<Uint8List> sink)? onTimeout}) {
    return _receiveDataStreamController!.stream
        .timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<List<Uint8List>> toList() {
    return _receiveDataStreamController!.stream.toList();
  }

  @override
  Future<Set<Uint8List>> toSet() {
    return _receiveDataStreamController!.stream.toSet();
  }

  @override
  Stream<S> transform<S>(StreamTransformer<Uint8List, S> streamTransformer) {
    return _receiveDataStreamController!.stream.transform(streamTransformer);
  }

  @override
  Stream<Uint8List> where(bool Function(Uint8List event) test) {
    return _receiveDataStreamController!.stream.where(test);
  }

  @override
  void write(Object? obj) {
    var str = obj?.toString();
    if (str != null && str.isNotEmpty) add(encoding.encode(str));
  }

  @override
  void writeAll(Iterable objects, [String separator = '']) {
    if (objects.isEmpty) return;
    var s = '';
    for (var i = 0; i < objects.length; i++) {
      var obj = objects.elementAt(i);
      var str = obj?.toString();
      if (str == null) continue;
      s = '$s$str';
      if (i < objects.length - 1 && separator.isNotEmpty) s += separator;
    }
    write(s);
  }

  @override
  void writeCharCode(int charCode) {
    var s = String.fromCharCode(charCode);
    write(s);
  }

  @override
  void writeln([Object? obj = '']) {
    var str = obj?.toString();
    if (str == null || str.isEmpty) return;
    str = '$str\n';
    write(str);
  }

  @override
  Future close([dynamic reason]) {
    if (isClosed) return Future(() => null);
    connectionState = _UTPConnectState.CLOSING;
    _closeCompleter = Completer();
    Timer(Duration.zero, () => _requestSendData(null));
    // Timer.run(() => _requestSendData(null));
    return _closeCompleter!.future;
  }

  /// Resend a Packet
  ///
  /// [seq] is the serial number of the packet
  ///
  /// [times] is the number of retransmissions
  void _resendPacket(int seq, [int times = 0]) {
    var packet = _inflightPackets[seq];
    if (packet == null) return _resendTimer.remove(seq)?.cancel();

    _resendTimer.remove(seq)?.cancel();
    _resendTimer[seq] = Timer(Duration.zero, () {
      // print('Resend $seq');
      _currentWindowSize -= packet.length;
      packet.resend++;
      _resendTimer.remove(seq);
      sendPacket(packet, times, false, false);
    });
  }

  /// update timeout
  ///
  /// For the calculation formula, please refer to the BEP0029 specification and [RFC6298](https://tools.ietf.org/html/rfc6298)
  void _caculateRTO(UTPPacket packet) {
    var packetRtt = getNowTimestamp(_startTimeOffset) - packet.sendTime;
    if (_srtt == null) {
      _srtt = packetRtt.toDouble();
      _rttvar = packetRtt / 2;
    } else {
      _rttvar = (1 - 0.25) * _rttvar + 0.25 * (_srtt! - packetRtt).abs();
      _srtt = (1 - 0.125) * _srtt! + 0.125 * packetRtt;
    }
    _rto = _srtt! + max(100000, 4 * _rttvar);
    // In Rf c6298 specification, if rto is less than 1 second, it is set to 1 second, here is the given 0.5 second
    _rto = max(_rto, 500000);
  }

  /// ACK a packet corresponding to a [seq].
  ///
  /// Returns null if the Packet has been acked, otherwise returns the packet
  UTPPacket? _ackPacket(int seq) {
    var packet = _inflightPackets.remove(seq);
    var resend = _resendTimer.remove(seq);
    resend?.cancel();
    if (packet != null) {
      var ackedSize = packet.length;
      _currentWindowSize -= ackedSize;
      var now = getNowTimestamp(_startTimeOffset);
      var rtt = now - packet.sendTime;
      // 重发的packet不算
      if (rtt != 0 && packet.resend == 0) {
        minPacketRTT ??= rtt;
        minPacketRTT = min(minPacketRTT!, rtt);
      }
      return packet;
    }
    return null;
  }

  /// update base delay
  ///
  /// Only save the delay within 5 seconds
  void _updateBaseDelay(int delay) {
    if (delay <= 0) return;
    var now = DateTime.now().millisecondsSinceEpoch;
    _baseDelays.add([now, delay]);
    var first = _baseDelays.first;
    while (now - first[0] > 5000) {
      _baseDelays.removeAt(0);
      if (_baseDelays.isEmpty) break;
      first = _baseDelays.first;
    }
  }

  /// Get the current Delay
  ///
  /// Calculation rule: the average value of the current basedelay minus the minimum value in the current basedelay
  int get currentDelay {
    if (_baseDelays.isEmpty) return 0;
    var sum = 0;
    int? baseDiff;
    for (var i = 0; i < _baseDelays.length; i++) {
      var diff = _baseDelays[i][1];
      baseDiff ??= diff;
      baseDiff = min(baseDiff, diff);
      sum += _baseDelays[i][1];
    }
    var avg = sum ~/ _baseDelays.length;
    return avg - baseDiff!;
  }

  /// Please see [rf c6817](https://tools.ietf.org/html/rfc6817) and be p0029 specification
  void _ledbatControl(int ackedSize, int delay) {
    if (ackedSize <= 0 || _allowWindowSize == 0) return;
    // int minBaseDelay;
    // _baseDelays.forEach((element) {
    //   minBaseDelay ??= element[1];
    //   minBaseDelay = min(minBaseDelay, element[1]);
    // });
    // if (minBaseDelay == null) return;
    // This is the algorithm mentioned in the original specification, which is consistent with the following algorithm.
    // The difference is that 1.UTP allows cwnd to be 0, so that no data can be sent, and then cwnd will be set to the minimum window when it times out
    // 2. The currnetDelay is different. It is proposed in the specification that the currentDelay can be obtained by filtering in many ways.
    // is one of the filters. When I implement it, I use the average of the delay in 5 seconds and the minimum packet rtt.
    // The minimum value of , which is based on the code of libutp, but I don't know if it is correct or not.
    // var queuing_delay = delay -minBaseDelay;
    // var off_target = (CCONTROL_TARGET -queuing_delay) /CCONTROL_TARGET;
    // cwnd += MAX_CWND_INCREASE_PACKETS_PER_RTT *off_target *ackedSize ~/cwnd;
    // var max_allowed_cwnd = _currentWindowSize + ackedSize + 3000;
    // cwnd = min(cwnd, max_allowed_cwnd);
    // cwnd = max(cwnd, 150);

    var current_delay = currentDelay;
    if (current_delay == 0 || minPacketRTT == null) return;
    var our_delay = min(minPacketRTT!,
        current_delay); // The delay will affect the size of the increase window, and the obtained delay will increase the window very aggressively
    // var our_delay = current_delay; //this approach is gentler
    if (our_delay == 0) return;
    // print(
    //     'rtt : $minPacketRTT ,our delay : $queuing_delay , current delay: $current_delay');
    var off_target1 = (CCONTROL_TARGET - our_delay) / CCONTROL_TARGET;
    //  The window size in the socket structure specifies the number of bytes we may have in flight (not acked) in total,
    //  on the connection. The send rate is directly correlated to this window size. The more bytes in flight, the faster
    //   send rate. In the code, the window size is called max_window. Its size is controlled, roughly, by the following expression:
    var delay_factor = off_target1;
    var window_factor = ackedSize / _allowWindowSize!;
    var scaled_gain =
        MAX_CWND_INCREASE_PACKETS_PER_RTT * delay_factor * window_factor;
    // Where the first factor scales the off_target to units of target delays.
    // The scaled_gain is then added to the max_window:
    _allowWindowSize = (_allowWindowSize ?? 0) + scaled_gain.toInt();
    _packetSize = MAX_PACKET_SIZE;
  }

  ///
  ///
  /// This method is implemented according to [BEP0029 Protocol Specification](http://www.bittorrent.org/beps/bep_0029.html) with modifications.
  ///
  /// Each time the other party confirms receipt of a data packet with a certain sequence number (applicable to both STATE and DATA types), it will compare the sequence number with the packets that have been sent. If this [ackSeq] is within the acknowledgement range,
  /// That is, if <= seq_nr and >= last_seq_nr, the [ackSeq] is considered valid.
  ///
  /// For a valid [ackSeq], the packets in the send queue will be checked, and all packets less than or equal to this [ackSeq] will be cleared (because the other party has already indicated that they have acknowledged receipt).
  ///
  /// When [ackSeq] is received repeatedly, or the sequence number in [selectiveAck] is received repeatedly, when the value of [isAckType] is `true`, it will be counted (only ack_nr of STATE type will be counted),
  /// When a seq is repeated more than 3 times:
  ///
  /// -If more than 3 packets with the sequence number ahead have been acknowledged (*if the sequence number was sent in the last few, then it may not have 3 in the first few, the threshold will be lowered*),
  /// Then all the packets between the sequence number and its previous and most recent confirmed received sequence numbers will be considered to have been lost.
  /// -If none of the above occurs, the acknowledgement [ackSeq] + 1 is considered lost.
  ///
  /// The count is then reset and the lost data is immediately resent.
  ///
  void remoteAcked(int ackSeq, int currentDelay,
      [bool isAckType = true, List<int>? selectiveAck]) {
    if (isClosed) return;
    if (!isConnected && !isClosing) return;
    if (ackSeq > currentLocalSeq || _inflightPackets.isEmpty) return;

    var acked = <int>[];
    lastRemoteAck = ackSeq;
    var ackedSize = 0;

    var thisAckPacket = _ackPacket(ackSeq);
    var newSeqAcked = thisAckPacket != null;
    if (thisAckPacket != null) ackedSize += thisAckPacket.length;
    if (thisAckPacket != null && isAckType) {
      _updateBaseDelay(currentDelay);
      _caculateRTO(thisAckPacket);
    }
    acked.add(ackSeq);
    if (selectiveAck != null && selectiveAck.isNotEmpty) {
      acked.addAll(selectiveAck);
    }

    for (var i = 1; i < acked.length; i++) {
      var ackedPacket = _ackPacket(acked[i]);
      newSeqAcked = (ackedPacket != null) || newSeqAcked;
      if (ackedPacket != null) ackedSize += ackedPacket.length;
    }

    var hasLost = false;

    if (isAckType) {
      var lostPackets = <int>{};
      for (var i = 0; i < acked.length; i++) {
        var key = acked[i];
        if (_duplicateAckCountMap[key] == null) {
          _duplicateAckCountMap[key] = 1;
        } else {
          _duplicateAckCountMap[key] = (_duplicateAckCountMap[key] ?? 0) + 1;
          if (_duplicateAckCountMap[key]! >= 3) {
            _duplicateAckCountMap.remove(key);
            // print('$key repeats the ack more than 3($oldcount) times, calculate the packet loss');
            var over = acked.length - i - 1;
            var limit = ((currentLocalSeq - 1 - key) & MAX_UINT16);
            limit = min(3, limit);
            if (over > limit) {
              var nextIndex = i + 1;
              var preIndex = i - 1;
              if (nextIndex < acked.length) {
                var c = ((acked[nextIndex] - key) & MAX_UINT16) -
                    1; // There are several between the two acks
                for (var j = 0; j < c; j++) {
                  lostPackets.add((key + j + 1) & MAX_UINT16);
                }
              }
              if (preIndex >= 0) {
                var c = ((key - acked[preIndex]) & MAX_UINT16) -
                    1; // There are several between the two acks
                for (var j = 0; j < c; j++) {
                  lostPackets.add((acked[preIndex] + j + 1) & MAX_UINT16);
                }
              }
            } else {
              var next = (key + 1) & MAX_UINT16;
              if (next < currentLocalSeq && !acked.contains(next)) {
                lostPackets.add(next);
              }
            }
          }
        }
      }
      hasLost = lostPackets.isNotEmpty;
      for (var seq in lostPackets) {
        _resendPacket(seq);
      }
    }

    var sended = _inflightPackets.keys;
    var keys = List<int>.from(sended);
    for (var i = 0; i < keys.length; i++) {
      var key = keys[i];
      if (compareSeqLess(ackSeq, key)) break;
      var ackedPacket = _ackPacket(key);
      if (ackedPacket != null) ackedSize += ackedPacket.length;
      newSeqAcked = (ackedPacket != null) || newSeqAcked;
    }

    if (newSeqAcked && isAckType) _ledbatControl(ackedSize, currentDelay);
    if (hasLost) {
      // dev.log('Lose packets, half cut window size and packet size',
      //     name: runtimeType.toString());
      _allowWindowSize = _allowWindowSize! ~/ 2;
    }

    if (_inflightPackets.isEmpty && _duplicateAckCountMap.isNotEmpty) {
      _duplicateAckCountMap.clear();
    } else {
      var useless = <int>[];
      for (var element in _duplicateAckCountMap.keys) {
        if (compareSeqLess(element, ackSeq)) {
          useless.add(element);
        }
      }
      for (var element in useless) {
        _duplicateAckCountMap.remove(element);
      }
    }
    if (_finSended && _inflightPackets.isEmpty) {
      // If FIN has been sent and all packets in the send queue have been acked
      // Then it is considered that the other party has all received, and the socket is closed.
      closeForce();
      return;
    }
    _startTimeoutCounter();
    startKeepAlive();
    Timer.run(() => _requestSendData());
  }

  /// start a timeout timer
  ///
  /// Every time a timeout occurs, the timeout limit will be doubled, and maxWindowSize will be set to min packet size, which is 150 bytes
  ///
  /// [times] Number of timeouts. If data is sent normally every time, this value is 0. If it is in timeout callback
  /// Send data in, this value will auto-increment.
  ///
  /// Each time it times out, the socket resends the packets in the queue. When the number of timeouts exceeds 5 times, it is considered that the other party has hung up, and the socket will be disconnected by itself
  void _startTimeoutCounter([int times = 0]) async {
    _rtoTimer?.cancel();
    if (_inflightPackets.isEmpty) return;
    if (connectionState == _UTPConnectState.SYN_SENT) {
      // See here RFC6298 Section 5 5.7
      if (_rto < 3000000) _rto = 3000000;
    }
    _rtoTimer = Timer(Duration(microseconds: _rto.floor()), () async {
      _rtoTimer?.cancel();
      if (_inflightPackets.isEmpty) return;
      if (times + 1 >= MAX_TIMEOUT) {
        dev.log('Socket closed :',
            error: 'Send data timeout (${times + 1}/$MAX_TIMEOUT)',
            name: runtimeType.toString());
        addError('Send data timeout');
        _closeCompleter ??= Completer();
        closeForce();
        await _closeCompleter!.future;
        return;
      }
      // dev.log(
      //     'Send data/SYN timeout (${times + 1}/$MAX_TIMEOUT) , reset window/packet to min size($MIN_PACKET_SIZE bytes)',
      //     name: runtimeType.toString());
      _allowWindowSize = MIN_PACKET_SIZE;
      _packetSize = MIN_PACKET_SIZE;
      // print('更改packet size: $_packetSize , max window : $_allowWindowSize');
      times++;
      var now = getNowTimestamp(_startTimeOffset);
      for (var packet in _inflightPackets.values) {
        var passed = now - packet.sendTime;
        if (passed >= _rto) {
          _resendPacket(packet.seq_nr, times);
        }
      }
      _rto *= 2; // Double the timeout
    });
  }

  UTPPacket newAckPacket() {
    return UTPPacket(
        ST_STATE, sendId!, 0, 0, maxWindowSize, currentLocalSeq, lastRemoteSeq);
  }

  UTPPacket newDataPacket(Uint8List payload) {
    return UTPPacket(
        ST_DATA, sendId!, 0, 0, maxWindowSize, currentLocalSeq, lastRemoteSeq,
        payload: payload);
  }

  SelectiveACK? newSelectiveACK() {
    if (_receivePacketBuffer.isEmpty) return null;
    _receivePacketBuffer.sort((a, b) {
      if (a > b) return 1;
      if (a < b) return -1;
      return 0;
    });
    var len = _receivePacketBuffer.last.seq_nr - lastRemoteSeq;
    var c = len ~/ 32;
    num r = len.remainder(32);
    if (r != 0) c++;
    var payload = List<int>.filled(c * 32, 0, growable: true);
    var selectiveAck = SelectiveACK(lastRemoteSeq, payload.length, payload);
    for (var packet in _receivePacketBuffer) {
      selectiveAck.setAcked(packet.seq_nr);
    }
    return selectiveAck;
  }

  /// Request to send ACK to remote side
  ///
  /// The request will be pushed into the event queue. If there is a new ACK to be sent before the trigger, and the ACK is not less than the ACK to be sent,
  /// will cancel the transmission and replace it with the latest ACK
  void requestSendAck() {
    if (isClosed) return;
    if (!isConnected && !isClosing) return;
    var packet = newAckPacket();
    var ack = packet.ack_nr;
    var keys = List<int>.from(_requestSendAckMap.keys);
    for (var i = 0; i < keys.length; i++) {
      var oldAck = keys[i];
      if (ack >= oldAck) {
        var timer = _requestSendAckMap.remove(oldAck);
        timer?.cancel();
      } else {
        break;
      }
    }
    var timer = _requestSendAckMap.remove(ack);
    timer?.cancel();
    _requestSendAckMap[ack] = Timer(Duration.zero, () {
      _requestSendAckMap.remove(ack);
      if (!sendPacket(packet, 0, false, false) &&
          packet.ack_nr == _finalRemoteFINSeq) {
        // Failed to send, unless it is the last fin, there is no need to continue to re-send
        Timer.run(() => requestSendAck());
      }
    });
  }

  /// Throw the data in the packet to the listener
  void _throwDataToListener(UTPPacket packet) {
    if (packet.payload != null && packet.payload!.isNotEmpty) {
      if (packet.offset != 0) {
        var data = packet.payload!.sublist(packet.offset);
        _receiveDataStreamController?.add(data as Uint8List);
      } else {
        _receiveDataStreamController?.add(packet.payload as Uint8List);
      }
      packet.payload = null;
    }
  }

  /// Process the received [packet]
  ///
  /// This is all about processing ST_DATA messages sent remotely
  void addReceivePacket(UTPPacket packet) {
    var expectSeq = (lastRemoteSeq + 1) & MAX_UINT16;
    var seq = packet.seq_nr;
    if (_finalRemoteFINSeq != null) {
      if (compareSeqLess(_finalRemoteFINSeq!, seq)) {
        // dev.log('Over FIN seq：$seq($_finalRemoteFINSeq)');
        return;
      }
    }
    if (compareSeqLess(seq, expectSeq)) {
      return;
    }
    if (compareSeqLess(expectSeq, seq)) {
      if (_receivePacketBuffer.contains(packet)) {
        return;
      }
      _receivePacketBuffer.add(packet);
    }
    if (seq == expectSeq) {
      // This is the correct order package to expect
      lastRemoteSeq = expectSeq;
      if (_receivePacketBuffer.isEmpty) {
        _throwDataToListener(packet);
      } else {
        _throwDataToListener(packet);
        _receivePacketBuffer.sort((a, b) {
          if (a > b) return 1;
          if (a < b) return -1;
          return 0;
        });
        var nextPacket = _receivePacketBuffer.first;
        while (nextPacket.seq_nr == ((lastRemoteSeq + 1) & MAX_UINT16)) {
          lastRemoteSeq = nextPacket.seq_nr;
          _throwDataToListener(nextPacket);
          _receivePacketBuffer.removeAt(0);
          if (_receivePacketBuffer.isEmpty) break;
          nextPacket = _receivePacketBuffer.first;
        }
      }
    }
    if (isClosing) {
      if (lastRemoteSeq == _finalRemoteFINSeq) {
        // If it is the last packet, close the socket
        var packet = newAckPacket();
        var s = sendPacket(packet, 0, false, false);
        // If you don't send it out, re-send it like crazy
        while (!s) {
          s = sendPacket(packet, 0, false, false);
        }
        _FINTimer?.cancel();
        closeForce();
        return;
      } else {
        //The fin countdown is reset every time new data is received
        _startCountDownFINData();
      }
    }
    requestSendAck(); // After receiving the data, it will request to send an ack
  }

  /// Send packets.
  ///
  /// Each data packet sent will update the sending time and timedifference, and will carry the latest ack and selectiveAck. but
  /// If it is a STATE type, the original ack value will not be changed.
  ///
  /// [packet] is the packet object.
  ///
  /// [times] is the number of retransmissions
  ///
  /// [increase] indicates whether to increase seq automatically, if the type is ST_STATE, the value will not increase seq regardless of whether it is true or false
  ///
  /// [save] indicates whether to save to the in-flighting packets map. If the type is ST_STATE, the value will not be saved regardless of whether it is true or false.
  bool sendPacket(UTPPacket packet,
      [int times = 0, bool increase = true, bool save = true]) {
    if (isClosed) return false;
    var len = packet.length;
    _currentWindowSize += len;
    // Calculated according to the time the package was created
    _startTimeOffset ??= DateTime.now().microsecondsSinceEpoch;
    var time = getNowTimestamp(_startTimeOffset);
    var diff = (time - lastRemotePktTimestamp).abs() & MAX_UINT32;
    if (packet.type == ST_SYN) {
      diff = 0;
    }
    if (increase && packet.type != ST_STATE) {
      currentLocalSeq++;
      currentLocalSeq &= MAX_UINT16;
    }
    if (save && packet.type != ST_STATE) {
      _inflightPackets[packet.seq_nr] = packet;
    }
    int? lastAck;
    if (packet.type == ST_DATA ||
        packet.type == ST_SYN ||
        packet.type == ST_FIN) {
      lastAck = lastRemoteSeq; // The latest ack is carried when the Data type is sent
    }
    if (packet.type == ST_DATA || packet.type == ST_STATE) {
      // Carry the latest selective ack
      packet.clearExtensions();
      var selectiveAck = newSelectiveACK();
      if (selectiveAck != null) {
        packet.addExtension(selectiveAck);
      }
    }
    var bytes = packet.getBytes(ack: lastAck, time: time, timeDiff: diff)!;
    var sendBytes = _socket.send(bytes, remoteAddress, remotePort);
    var success = sendBytes > 0;
    if (success) {
      // dev.log(
      //     'Send(${_Type2Map[packet.type]}) : seq : ${packet.seq_nr} , ack : ${packet.ack_nr},length:${packet.length}',
      //     name: runtimeType.toString());
      if (packet.type == ST_DATA ||
          packet.type == ST_SYN ||
          packet.type == ST_FIN) {
        _startTimeoutCounter(times);
      }
    }
    // Keepalive is updated every time it is sent
    if (isConnected && success) startKeepAlive();
    return success;
  }

  /// Send a FIN message to the other party.
  ///
  /// This method will be called when close
  void _sendFIN() {
    if (isClosed || _finSended) return;
    var packet =
        UTPPacket(ST_FIN, sendId!, 0, 0, 0, currentLocalSeq, lastRemoteSeq);
    _finSended = sendPacket(packet, 0, false, true);
    if (!_finSended) {
      _inflightPackets.remove(packet.seq_nr);
      Timer.run(() => _requestSendData());
    }
    return;
  }

  void _startCountDownFINData([int times = 0]) {
    if (times >= 5) {
      // time out
      closeForce();
      return;
    }
    _FINTimer = Timer(Duration(microseconds: _rto.floor()), () {
      _rto *= 2;
      _startCountDownFINData(++times);
    });
  }

  void _remoteFIN(int finalSeq) async {
    var expectFinal = (lastRemoteSeq + 1) & MAX_UINT32;
    if (compareSeqLess(expectFinal, finalSeq) || expectFinal == finalSeq) {
      _finalRemoteFINSeq = finalSeq;
      connectionState = _UTPConnectState.CLOSING;
    }
  }

  /// force close
  ///
  /// Do not send FIN to remote, close the socket directly
  void closeForce() async {
    if (isClosed) return;
    connectionState = _UTPConnectState.CLOSED;
    _closed = true;

    _FINTimer?.cancel();
    _FINTimer = null;
    _receivePacketBuffer.clear();

    _addDataTimer?.cancel();
    _sendingDataCache.clear();
    _duplicateAckCountMap.clear();
    _rtoTimer?.cancel();

    _inflightPackets.clear();
    _resendTimer.forEach((key, timer) {
      timer.cancel();
    });
    _resendTimer.clear();

    _requestSendAckMap.forEach((key, timer) {
      timer.cancel();
    });
    _requestSendAckMap.clear();

    _sendingDataBuffer.clear();
    _keepAliveTimer?.cancel();

    _baseDelays.clear();

    // Equivalent to throwing an event
    Timer.run(() {
      _handler?.socketClosed(this);
      _handler = null;
      if (_closeCompleter != null && !_closeCompleter!.isCompleted) {
        _closeCompleter!.complete();
        _closeCompleter = null;
      }
    });
    _finSended = false;
    await _receiveDataStreamController?.close();
    _receiveDataStreamController = null;

    return;
  }
}

///
/// uTP protocol receive data process
///
/// Include init connection and other type data process , both of Server socket and client socket
void _processReceiveData(
    RawDatagramSocket? rawSocket,
    InternetAddress remoteAddress,
    int remotePort,
    UTPPacket packetData,
    _UTPSocket? socket,
    {void Function(_UTPSocket socket)? onConnected,
    void Function(_UTPSocket socket)? newSocket,
    void Function(_UTPSocket socket, dynamic error)? onError}) {
  // print(
  //     'Received the other party's ${TYPE_NAME[packetData.type]} package:seq_nr:${packetData.seq_nr} , ack_nr : ${packetData.ack_nr}');
  // if (packetData.dataExtension != null) print('There is an Extension');
  if (socket != null && socket.isClosed) return;
  // dev.log(
  //     'Receive(${_Type2Map[packetData.type]}) : seq : ${packetData.seq_nr} , ack : ${packetData.ack_nr}',
  //     name: 'utp_protocol_impelement');
  switch (packetData.type) {
    case ST_SYN:
      _processSYNMessage(
          socket, rawSocket, remoteAddress, remotePort, packetData, newSocket);
      break;
    case ST_DATA:
      _processDataMessage(socket, packetData, onConnected, onError);
      break;
    case ST_STATE:
      _processStateMessage(socket, packetData, onConnected, onError);
      break;
    case ST_FIN:
      _processFINMessage(socket, packetData);
      break;
    case ST_RESET:
      _processResetMessage(socket);
      break;
  }
}

/// Handle Reset messages.
///
/// Socket forcibly closes the connection after receiving this message
void _processResetMessage(_UTPSocket? socket) {
  // socket?.addError('Reset by remote');
  socket?.closeForce();
}

/// Handling fin messages
void _processFINMessage(_UTPSocket? socket, UTPPacket packetData) async {
  if (socket == null || socket.isClosed || socket.isClosing) return;
  socket._remoteFIN(packetData.seq_nr);
  socket.lastRemotePktTimestamp = packetData.sendTime;
  socket.remoteWndSize = packetData.wnd_size;
  socket.addReceivePacket(packetData);
  socket.remoteAcked(packetData.ack_nr, packetData.timestampDifference, false);
}

/// Process incoming SYN messages
///
/// Every time a SYN message is received, a new connection must be created. But if the connection ID already has a corresponding [socket], it should notify the other party to Reset
void _processSYNMessage(_UTPSocket? socket, RawDatagramSocket? rawSocket,
    InternetAddress remoteAddress, int remotePort, UTPPacket packetData,
    [void Function(_UTPSocket socket)? newSocket]) {
  if (socket != null) {
    _sendResetMessage(
        packetData.connectionId, rawSocket, remoteAddress, remotePort);
    // dev.log(
    //     'Duplicated connection id or error data type , reset the connection',
    //     name: 'utp_protocol_implement');
    return;
  }
  var connId = (packetData.connectionId + 1) & MAX_UINT16;
  socket = _UTPSocket(rawSocket!, remoteAddress, remotePort);
  // init receive_id and sent_id
  socket.receiveId = connId;
  socket.sendId = packetData.connectionId; // Ensure that the sent conn id is consistent
  socket.currentLocalSeq = Random().nextInt(MAX_UINT16); // random seq
  socket.connectionState = _UTPConnectState.SYN_RECV; // Change connection status
  socket.lastRemoteSeq = packetData.seq_nr;
  socket.remoteWndSize = packetData.wnd_size;
  socket.lastRemotePktTimestamp = packetData.sendTime;
  var packet = socket.newAckPacket();
  socket.sendPacket(packet, 0, false, false);
  if (newSocket != null) newSocket(socket);
  return;
}

/// Send a reset type message directly to the other party through the udp socket
Future _sendResetMessage(int? connId, RawDatagramSocket? rawSocket,
    InternetAddress remoteAddress, int remotePort,
    [UTPPacket? packet, Completer? completer]) {
  if (rawSocket == null) return Future.value();
  packet ??= UTPPacket(ST_RESET, connId!, 0, 0, 0, 1, 0);
  var bytes = packet.getBytes()!;
  completer ??= Completer();
  var s = rawSocket.send(bytes, remoteAddress, remotePort);
  if (s > 0) {
    completer.complete();
    return completer.future;
  } else {
    Timer.run(() => _sendResetMessage(
        connId, rawSocket, remoteAddress, remotePort, packet, completer));
  }
  return completer.future;
}

/// Read out the ack serial number of the SelectiveAck Extension in the packet data
List<int>? _readSelectiveAcks(UTPPacket packetData) {
  List<int>? selectiveAcks;
  if (packetData.extensionList.isNotEmpty) {
    selectiveAcks = <int>[];
    for (var ext in packetData.extensionList) {
      if (ext.isUnKnownExtension) continue;
      var s = ext as SelectiveACK;
      selectiveAcks.addAll(s.getAckeds());
    }
  }
  return selectiveAcks;
}

/// Process incoming Data messages
///
/// For the socket in SYN_RECV, if the serial number is correct when the message is received at this time, it means the real connection is successful
void _processDataMessage(_UTPSocket? socket, UTPPacket packetData,
    [void Function(_UTPSocket)? onConnected,
    void Function(_UTPSocket source, dynamic error)? onError]) {
  if (socket == null) {
    return;
  }
  var selectiveAcks = _readSelectiveAcks(packetData);
  if (socket.connectionState == _UTPConnectState.SYN_RECV &&
      (socket.currentLocalSeq - 1) & MAX_UINT16 == packetData.ack_nr) {
    socket.connectionState = _UTPConnectState.CONNECTED;
    socket.startKeepAlive();
    socket.remoteWndSize = packetData.wnd_size;
    if (onConnected != null) onConnected(socket);
  }
  // After receiving the data in the connected state, remove the header and send the payload as an event
  if (socket.isConnected || socket.isClosing) {
    socket.remoteWndSize = packetData.wnd_size; // Update the other party's window size
    socket.lastRemotePktTimestamp = packetData.sendTime;
    socket.addReceivePacket(packetData);
    socket.remoteAcked(packetData.ack_nr, packetData.timestampDifference, false,
        selectiveAcks);

    return;
  }
}

/// Handling Ack messages
///
/// If [socket] is in SYN_SENT state, then if the serial number is correct at this time, it means the connection is successful
void _processStateMessage(_UTPSocket? socket, UTPPacket packetData,
    [void Function(_UTPSocket)? onConnected,
    void Function(_UTPSocket source, dynamic error)? onError]) {
  if (socket == null) return;
  var selectiveAcks = _readSelectiveAcks(packetData);
  if (socket.connectionState == _UTPConnectState.SYN_SENT &&
      (socket.currentLocalSeq - 1) & MAX_UINT16 == packetData.ack_nr) {
    socket.connectionState = _UTPConnectState.CONNECTED;
    socket.lastRemoteSeq = packetData.seq_nr;
    socket.lastRemoteSeq--;
    socket.remoteWndSize = packetData.wnd_size;
    socket.startKeepAlive();
    if (onConnected != null) onConnected(socket);
  }
  if (socket.isConnected || socket.isClosing) {
    socket.remoteWndSize = packetData.wnd_size; // Update the other party's window size
    socket.lastRemotePktTimestamp = packetData.sendTime;
    socket.remoteAcked(
        packetData.ack_nr, packetData.timestampDifference, true, selectiveAcks);
  }
}
