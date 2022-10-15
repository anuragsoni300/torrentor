import 'dart:typed_data';

import 'package:torrentor/backend/model/torrent/base/basetasktorrent.dart';
import 'package:torrentor/modules/downloadmodule/torrentrepository/torrent_model/torrent_model.dart';
import '../../../modules/downloadmodule/torrentrepository/dartorrent_common/dartorrent_common.dart';
import '../../../modules/downloadmodule/torrentrepository/torrent_task/torrent_task.dart';

class TaskTorrent extends BaseTaskTorrent {
  final TorrentTask _task;
  final List<int> _infoHashBuffer;
  final Torrent _model;
  TaskTorrent(this._task, this._infoHashBuffer, this._model);
  @override
  Future<void> start() async {
    await _task.start();
  }

  @override
  void resume() {
    _task.resume();
  }

  @override
  void pause() {
    _task.pause();
  }

  @override
  void stop() {
    _task.stop();
  }

  @override
  void findingPublicTrackers() {
    findPublicTrackers().listen((alist) {
      for (var element in alist) {
        _task.startAnnounceUrl(element, Uint8List.fromList(_infoHashBuffer));
      }
    });
  }

  @override
  void addDhtNodes() {
    for (var element in _model.nodes) {
      _task.addDHTNode(element);
    }
  }
}
