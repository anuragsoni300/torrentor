import 'dart:io';
import 'dart:typed_data';
import '../../dartorrent_common_base.dart';
import 'scrape_event.dart';
import 'udp_tracker_base.dart';
import 'scrape.dart';

/// Take a look : [UDP Scrape Specification](http://xbtt.sourceforge.net/udp_tracker_protocol.html)
class UDPScrape extends Scrape with UDPTrackerBase {
  UDPScrape(Uri uri) : super('${uri.host}:${uri.port}', uri);

  @override
  Future scrape(Map<String?, dynamic>? options) {
    return contactAnnouncer(options);
  }

  /// When scraping, send to remote:
  /// -Connection ID. This is returned by Remote after the first connection and has been passed in as a parameter.
  /// -Action , here is 2, which means Scrape,
  /// -Transcation ID, which is already generated when connecting for the first time
  /// -[info hash] , this can be the info hash of multiple torrent files
  @override
  Uint8List? generateSecondTouchMessage(Uint8List? connectionId, Map? options) {
    var list = <int>[];
    list.addAll(connectionId!);
    list.addAll(ACTION_SCRAPE); // The type of Action, currently scrapt, ie 2
    list.addAll(transcationId); // session id
    var infos = infoHashSet;
    if (infos.isEmpty) throw Exception('infohash cannot be empty');
    for (var info in infos) {
      list.addAll(info!);
    }
    return Uint8List.fromList(list);
  }

  ///
  /// Process scrape information returned from remote.
  ///
  /// The information is a set of data consisting of complete, downloaded, and incomplete.
  @override
  dynamic processResponseData(
      Uint8List? data, int? action, Iterable<CompactAddress?>? addresses) {
    var event = ScrapeEvent(scrapeUrl);
    if (action != 2) throw Exception('返回数据中的Action不匹配');
    var view = ByteData.view(data!.buffer);
    var i = 0;
    for (var index = 8; index < data.length; index += 12, i++) {
      var file = ScrapeResult(
          transformBufferToHexString(infoHashSet.elementAt(i)),
          complete: view.getUint32(index),
          downloaded: view.getUint32(index + 4),
          incomplete: view.getUint32(index + 8));
      event.addFile(file.infoHash!, file);
    }
    return event;
  }

  @override
  void handleSocketDone() {
    close();
  }

  @override
  void handleSocketError(e) {
    close();
  }

  @override
  Future<List<CompactAddress?>?> get addresses async {
    try {
      var ips = await InternetAddress.lookup(scrapeUrl!.host);
      var l = <CompactAddress>[];
      for (var element in ips) {
        try {
          l.add(CompactAddress(element, scrapeUrl?.port));
        } catch (e) {
          //
        }
      }
      return l;
    } catch (e) {
      return null;
    }
  }
}
