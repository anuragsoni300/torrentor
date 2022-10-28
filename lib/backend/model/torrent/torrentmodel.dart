import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import '../../../modules/downloadmodule/torrentrepository/model/torrent.dart';
import 'base/basetorrent.dart';

class TorrentRepository extends BaseTorrentRepository {
  final String _path;
  final dynamic _info;
  final List<int> _infoBuffer;
  final String _infoHash;

  TorrentRepository(this._path, this._infoHash, this._info, this._infoBuffer);

  @override
  Future<File> torrentSave() async {
    Torrent model = Torrent(
      _info,
      'MyName',
      _infoHash,
      Uint8List.fromList(_infoBuffer),
    );
    File file = await model.saveAs('$_path/.$_infoHash.torrent', true);
    return file;
  }

  @override
  Future<Torrent> parseTorrent() async {
    Torrent torrent = await Torrent.parse('$_path/$_infoHash.torrent');
    return torrent;
  }
}
