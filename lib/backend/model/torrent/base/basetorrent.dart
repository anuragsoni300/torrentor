import 'dart:io';
import '../../../../modules/downloadmodule/torrentrepository/model/torrent.dart';

abstract class BaseTorrentRepository {
  Future<File> torrentSave();
  Future<Torrent> parseTorrent();
}