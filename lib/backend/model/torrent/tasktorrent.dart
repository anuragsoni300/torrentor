import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:torrentor/backend/model/torrent/base/basetasktorrent.dart';
import '../../../common/functions.dart';
import '../../../modules/downloadmodule/torrentrepository/dartorrent_common_base.dart';
import '../../../modules/downloadmodule/torrentrepository/model/torrent.dart';
import '../../../modules/downloadmodule/torrentrepository/task/torrent_task_base.dart';

class TaskTorrent extends BaseTaskTorrent {
  final TorrentTask _task;
  final List<int> _infoHashBuffer;
  final Torrent _model;
  ValueNotifier seedersValue = ValueNotifier(0);
  ValueNotifier progressValue = ValueNotifier('0.00 %');
  ValueNotifier downloadSpeedValue = ValueNotifier('0 B');
  ValueNotifier ulploadSpeedValue = ValueNotifier('0 B');
  Torrent get model => _model;
  TorrentTask get task => _task;
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

  @override
  void values() {
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      var progress = '${(task.progress * 100).toStringAsFixed(2)}%';
      // var ads = ((task.averageDownloadSpeed) * 1000 / 1024).toStringAsFixed(2);
      var aps = ((task.averageUploadSpeed) * 1000 / 1024).toStringAsFixed(2);
      var ds = ((task.currentDownloadSpeed) * 1000);
      var ps = ((task.uploadSpeed) * 1000);
      var utpu = ((task.utpUploadSpeed) * 1000 / 1024).toStringAsFixed(2);
      var utpc = task.utpPeerCount;
      var active = task.connectedPeersNumber;
      var seeders = task.seederNumber;
      var all = task.allPeersNumber;
      seedersValue.value = seeders;
      progressValue.value = progress;
      downloadSpeedValue.value = formatBytes((ds).toInt(), 2);
      ulploadSpeedValue.value = formatBytes((ps).toInt(), 2);
      if(progress == '100.00%') timer.cancel();
      log('Progress : $progress , Peers:($active/$seeders/$all)($utpc) upload speed : ($utpu)($aps/$ps)kb/s');
    });
  }

  @override
  void stopOnTaskComplete() {
    task.onTaskComplete(() {
      task.stop();
    });
  }
}
