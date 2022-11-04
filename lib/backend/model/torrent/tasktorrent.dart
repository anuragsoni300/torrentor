import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:torrentor/backend/model/torrent/base/basetasktorrent.dart';
import '../../../common/functions.dart';
import '../../torrentrepository/dartorrent_common_base.dart';
import '../../torrentrepository/model/torrent.dart';
import '../../torrentrepository/task/task.dart';

class TaskTorrent extends BaseTaskTorrent with ChangeNotifier {
  final TorrentTask _task;
  final List<int> _infoHashBuffer;
  final Torrent _model;
  ValueNotifier seedersValue = ValueNotifier(0);
  ValueNotifier<String> progressValue = ValueNotifier<String>('0.00 %');
  ValueNotifier downloadSpeedValue = ValueNotifier('0 B');
  Torrent get model => _model;
  TorrentTask get task => _task;
  ValueNotifier<bool> isPaused = ValueNotifier<bool>(false);
  ValueNotifier<int> allPeersNumber = ValueNotifier<int>(0);
  ValueNotifier<String> averageDownloadSpeed = ValueNotifier<String>('0 B');
  ValueNotifier<int> connectedPeersNumber = ValueNotifier<int>(0);
  ValueNotifier<int?> downloaded = ValueNotifier<int?>(0);
  ValueNotifier<int?> fileManagerDownloaded = ValueNotifier<int>(0);
  ValueNotifier<int?> piecesNumber = ValueNotifier<int?>(0);

  TaskTorrent(this._task, this._infoHashBuffer, this._model);

  @override
  Future<void> start() async {
    await _task.start();
  }

  @override
  void resume() {
    _task.resume();
    isPaused.value = false;
  }

  @override
  void pause() {
    _task.pause();
    isPaused.value = true;
  }

  @override
  void stop() {
    _task.stop();
    isPaused.value = true;
  }

  @override
  void findingPublicTrackers() {
    findPublicTrackers().listen((alist) {
      for (var i = 0; i < alist.length; i++) {
        _task.startAnnounceUrl(alist[i], Uint8List.fromList(_infoHashBuffer));
      }
    });
  }

  @override
  void addDhtNodes() {
    for (var i = 0; i < model.nodes.length; i++) {
      _task.addDHTNode(model.nodes[i]);
    }
  }

  @override
  void values() {
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      var progress = '${(task.progress * 100).toStringAsFixed(2)}%';
      allPeersNumber.value = task.allPeersNumber;
      connectedPeersNumber.value = task.connectedPeersNumber;
      seedersValue.value = task.seederNumber;
      progressValue.value = progress;
      downloadSpeedValue.value =
          formatBytes((task.currentDownloadSpeed * 1000).toInt(), 2);
      averageDownloadSpeed.value =
          formatBytes((task.averageDownloadSpeed * 1000).toInt(), 2);
      downloaded.value = task.downloaded;
      fileManagerDownloaded.value = task.fileManager?.downloaded;
      piecesNumber.value = task.fileManager?.piecesNumber;
      if (progress == '100.00%') {
        pause();
        timer.cancel();
      }
      // log('Progress : $progress , Peers:($active/$seeders/$all)($utpc) upload speed : ($utpu)($aps/$ps)kb/s');
    });
  }

  @override
  void stopOnTaskComplete() {
    task.onTaskComplete(() {
      stop();
    });
  }
}
