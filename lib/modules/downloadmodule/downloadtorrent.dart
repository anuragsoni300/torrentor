import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/backend/model/common/commonmodel.dart';
import 'package:torrentor/backend/model/torrent/tasktorrent.dart';
import 'package:torrentor/backend/model/torrent/torrentmodel.dart';
import 'package:torrentor/modules/downloadmodule/detailscreen/detailscreen.dart';
import 'package:torrentor/modules/downloadmodule/downloadhelper/downloadstart.dart';
import '../../backend/model/storgae/basestorage.dart';
import '../../backend/torrentrepository/model/torrent.dart';
import '../../backend/torrentrepository/task/task.dart';
import '../../myopencontainer.dart';

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
  TaskTorrent? taskTorrent;
  CommonModel commonModel = CommonModel();

  @override
  void initState() {
    super.initState();
  }

  Future<TaskTorrent> torrentStarter() async {
    String path = await commonModel.savePathFetcher();
    late List<dynamic> metaData;
    if (widget.metaData == null || widget.infoBuffer == null) {
      metaData = await getMetaData();
      log('hello');
    }
    torrentRepository = TorrentRepository(path, widget.infoHash,
        widget.metaData ?? metaData[0], widget.infoBuffer ?? metaData[1]);
    File torrentFile = await torrentRepository.torrentSave();
    Torrent model = await Torrent.parse(torrentFile.path);
    TorrentTask newTask = TorrentTask.newTask(model, '$path/');
    taskTorrent = TaskTorrent(newTask, widget.infoBuffer!, model);
    taskTorrent!.findingPublicTrackers();
    taskTorrent!.addDhtNodes();
    taskTorrent!.values();
    await taskTorrent!.start();
    return taskTorrent!;
  }

  Future<List<dynamic>> getMetaData() async {
    List<dynamic> metaData =
        await Provider.of<StorageRepository>(context, listen: false)
            .metaData(widget.infoHash);
    return metaData;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var backC = Theme.of(context).colorScheme.background;
    String name = widget.metaData == null
        ? widget.infoHash
        : String.fromCharCodes(widget.metaData["name"]);
    return FutureProvider<TaskTorrent?>(
      initialData: null,
      create: (context) {
        return torrentStarter();
      },
      child: Padding(
        padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 2.h),
        child: OpenContainer(
          transitionDuration: const Duration(milliseconds: 400),
          transitionType: ContainerTransitionType.fadeThrough,
          openColor: backC,
          closedColor: backC,
          closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(1.3.h)),
          closedBuilder: (__, _) => DownloadStart(
            infoHash: widget.infoHash,
            name: name,
          ),
          openBuilder: (__, _) => ListenableProvider<TaskTorrent?>.value(
            value: taskTorrent,
            child: DetailScreen(name: name),
          ),
          tappable: true,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
