import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:torrentor/backend/model/common/commonmodel.dart';
import 'package:torrentor/backend/model/torrent/tasktorrent.dart';
import 'package:torrentor/backend/model/torrent/torrentmodel.dart';
import 'package:torrentor/modules/downloadmodule/downloadhelper/downloadstart.dart';
import '../../backend/torrentrepository/model/torrent.dart';
import '../../backend/torrentrepository/task/task.dart';

class TorrentDownload extends StatefulWidget {
  final String infoHash;
  final dynamic metaData;
  final List<int>? infoBuffer;
  const TorrentDownload(
      {super.key,
      required this.infoHash,
      required this.metaData,
      required this.infoBuffer});

  @override
  State<TorrentDownload> createState() => _TorrentDownloadState();
}

class _TorrentDownloadState extends State<TorrentDownload>
    with AutomaticKeepAliveClientMixin {
  late TorrentRepository torrentRepository;
  late TaskTorrent taskTorrent;
  CommonModel commonModel = CommonModel();

  @override
  void initState() {
    super.initState();
  }

  Future<TaskTorrent> torrentStarter() async {
    String path = await commonModel.savePathFetcher();
    torrentRepository = TorrentRepository(
        path, widget.infoHash, widget.metaData, widget.infoBuffer!);
    File torrentFile = await torrentRepository.torrentSave();
    Torrent model = await Torrent.parse(torrentFile.path);
    TorrentTask newTask = TorrentTask.newTask(model, '$path/');
    log('${widget.infoBuffer?.length}');
    taskTorrent = TaskTorrent(newTask, widget.infoBuffer!, model);
    taskTorrent.findingPublicTrackers();
    taskTorrent.addDhtNodes();
    taskTorrent.values();
    await taskTorrent.start();
    return taskTorrent;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiProvider(
      providers: [
        FutureProvider<TaskTorrent?>(
          initialData: null,
          create: (context) =>
              widget.metaData == null || widget.infoBuffer == null
                  ? null
                  : torrentStarter(),
        ),
      ],
      child: DownloadStart(
        infoHash: widget.infoHash,
        name: widget.metaData == null
            ? widget.infoHash
            : String.fromCharCodes(widget.metaData["name"]),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
