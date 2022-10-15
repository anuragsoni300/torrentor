import '../../../../modules/downloadmodule/torrentrepository/torrent_model/torrent_model.dart';
import '../../../../modules/downloadmodule/torrentrepository/torrent_task/torrent_task.dart';

abstract class BaseTorrentRepository {
  Future<void> torrentInit();
  void resume(TorrentTask task);
  void pause(TorrentTask task);
  void start(TorrentTask task);
  Future<Torrent> parseTorrent();
}