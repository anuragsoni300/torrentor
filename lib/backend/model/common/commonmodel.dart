import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../../../modules/downloadmodule/torrentrepository/bencode_dart/bencode_dart.dart';
import '../../../modules/downloadmodule/torrentrepository/dartorrent_common/dartorrent_common.dart';
import '../../../modules/downloadmodule/torrentrepository/torrent_task/src/metadata/metadata_downloader.dart';
import '../../../modules/downloadmodule/torrentrepository/torrent_tracker/torrent_tracker.dart';
import 'base/basecommonmodel.dart';

class CommonModel extends BaseCommonModel {
  @override
  Future<String> savePathFetcher() async {
    List<Directory>? extDir = await getExternalStorageDirectories();
    String direcory = extDir![0].path.split('Android').first;
    String savePath = '${direcory}Fonts';
    return savePath;
  }

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
}
