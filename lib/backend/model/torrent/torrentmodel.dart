// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:typed_data';
import 'package:torrentor/modules/downloadmodule/torrentrepository/torrent_task/torrent_task.dart';
import '../../../modules/downloadmodule/torrentrepository/torrent_model/torrent_model.dart';
import 'base/basetorrent.dart';

class TorrentRepository extends BaseTorrentRepository {
  final String _path;
  final dynamic _info;
  final List<int> _infoBuffer;
  final String _infoHash;

  TorrentRepository(this._path, this._infoHash, this._info, this._infoBuffer);

  @override
  Future<void> torrentInit() async {
    Torrent model = Torrent(
      _info,
      'MyName',
      _infoHash,
      Uint8List.fromList(_infoBuffer),
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
