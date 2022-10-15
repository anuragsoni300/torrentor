// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:typed_data';
import 'package:torrentor/modules/downloadmodule/torrentrepository/torrent_task/src/metadata/metadata_downloader.dart';
import 'package:torrentor/modules/downloadmodule/torrentrepository/torrent_task/torrent_task.dart';
import '../../../modules/downloadmodule/torrentrepository/bencode_dart/bencode_dart.dart';
import '../../../modules/downloadmodule/torrentrepository/dartorrent_common/dartorrent_common.dart';
import '../../../modules/downloadmodule/torrentrepository/torrent_model/torrent_model.dart';
import '../../../modules/downloadmodule/torrentrepository/torrent_tracker/torrent_tracker.dart';
import 'base/basetorrent.dart';

class TorrentRepository extends BaseTorrentRepository {
  final String _path;
  final String _infoHash;

  TorrentRepository(this._path, this._infoHash);

  @override
  Future<List<dynamic>> metaData(String infoHash) {
    final completer = Completer<List<dynamic>>();
    var metadata = MetadataDownloader(infoHash);
    metadata.startDownload();
    var tracker = TorrentAnnounceTracker(metadata);
    dynamic msg;
    metadata.onDownloadComplete((data) {
      msg = decode(Uint8List.fromList(data));
      completer.complete([msg, metadata.infoHashBuffer]);
      tracker.stop(true);
    });

    var u8List = Uint8List.fromList(metadata.infoHashBuffer!);

    tracker.onPeerEvent((source, event) {
      var peers = event.peers;
      peers?.forEach((element) {
        metadata.addNewPeerAddress(element);
      });
    });
    findPublicTrackers().listen((alist) {
      for (var element in alist) {
        tracker.runTracker(element, u8List);
      }
    });
    return completer.future;
  }

  @override
  Future<void> torrentInit(dynamic info, List<int> infoBuffer) async {
    Torrent model = Torrent(
      info,
      'MyName',
      _infoHash,
      Uint8List.fromList(infoBuffer),
    );
    await model.saveAs('$_path/$_infoHash.torrent');
  }

  @override
  Future<Torrent> parseTorrent() async {
    return Torrent.parse('$_path/');
  }

  @override
  void start(TorrentTask task) {
    task.start();
  }

  @override
  void resume(TorrentTask task) {
    task.resume();
  }

  @override
  void pause(TorrentTask task) {
    task.pause();
  }
}
