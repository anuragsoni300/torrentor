import 'dart:io';

import '../../../torrentrepository/model/torrent.dart';

abstract class BaseTorrentRepository {
  Future<File> torrentSave();
  Future<Torrent> parseTorrent();
}