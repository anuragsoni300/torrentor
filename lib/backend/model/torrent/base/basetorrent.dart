import 'dart:io';
import '../../../../modules/downloadmodule/torrentrepository/torrent_model/torrent_model.dart';

abstract class BaseTorrentRepository {
  Future<File> torrentSave();
  Future<Torrent> parseTorrent();
}