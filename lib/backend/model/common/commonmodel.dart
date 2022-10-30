import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../../torrentrepository/bencode_base.dart';
import '../../torrentrepository/dartorrent_common_base.dart';
import '../../torrentrepository/task/metadata/metadata_downloader.dart';
import '../../torrentrepository/tracker/torrent_tracker_base.dart';
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
      msg = decode(Uint8List.fromList(data!));
      // tracker.stop(true);
      completer.complete([msg, metadata.infoHashBuffer]);
    });

    var u8List = Uint8List.fromList(metadata.infoHashBuffer!);

    tracker.onPeerEvent((source, event) {
      var peers = event?.peers;
      peers?.forEach((element) {
        metadata.addNewPeerAddress(element);
      });
    });
    findPublicTrackers().listen((alist) {
      for (var i = 0; i < alist.length; i++) {
        tracker.runTracker(alist[i], u8List);
      }
    });
    return completer.future;
  }
}
