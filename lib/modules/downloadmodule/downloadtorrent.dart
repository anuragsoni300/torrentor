import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:torrentor/backend/model/common/commonmodel.dart';
import 'package:torrentor/backend/model/torrent/tasktorrent.dart';
import 'package:torrentor/backend/model/torrent/torrentmodel.dart';
import 'package:torrentor/modules/downloadmodule/downloadhelper/downloadstart.dart';
import 'package:torrentor/modules/downloadmodule/torrentrepository/torrent_model/torrent_model.dart';
import 'package:torrentor/modules/downloadmodule/torrentrepository/torrent_task/torrent_task.dart';

class TorrentDownload extends StatefulWidget {
  final String infoHash;
  const TorrentDownload({super.key, required this.infoHash});

  @override
  State<TorrentDownload> createState() => _TorrentDownloadState();
}

class _TorrentDownloadState extends State<TorrentDownload>
    with AutomaticKeepAliveClientMixin {
  late final TorrentRepository torrentRepository;
  late final TaskTorrent taskTorrent;
  CommonModel commonModel = CommonModel();

  @override
  void initState() {
    super.initState();
  }

  Future<TaskTorrent> torrentStarter() async {
    String path = await commonModel.savePathFetcher();
    List<dynamic> metaData = await commonModel.metaData(widget.infoHash);
    torrentRepository =
        TorrentRepository(path, widget.infoHash, metaData[0], metaData[1]);
    // print(utf8.decode(metaData[0]['files'][0]['path'][0]));
    File torrentFile = await torrentRepository.torrentSave();
    Torrent model = await Torrent.parse(torrentFile.path);
    TorrentTask newTask = TorrentTask.newTask(model, '$path/');
    taskTorrent = TaskTorrent(newTask, metaData[1], model);
    taskTorrent.findingPublicTrackers();
    taskTorrent.addDhtNodes();
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
          create: (context) => torrentStarter(),
        ),
      ],
      child: const DownloadStart(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
