import '../../../../modules/downloadmodule/torrentrepository/torrent_model/torrent_model.dart';
import '../../../../modules/downloadmodule/torrentrepository/torrent_task/torrent_task.dart';

abstract class BaseTorrentRepository {
  Future<void> torrentInit(dynamic info, List<int> infoBuffer);
  void resume(TorrentTask task);
  void pause(TorrentTask task);
  void start(TorrentTask task);
  Future<List<dynamic>> metaData(String infoHash);
  Future<Torrent> parseTorrent();
}