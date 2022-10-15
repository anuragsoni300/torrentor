import 'package:flutter/material.dart';
import 'package:torrentor/backend/model/common/commonmodel.dart';
import 'package:torrentor/backend/model/torrent/torrentmodel.dart';

class TorrentDownload extends StatefulWidget {
  final String infoHash;
  const TorrentDownload({super.key, required this.infoHash});

  @override
  State<TorrentDownload> createState() => _TorrentDownloadState();
}

class _TorrentDownloadState extends State<TorrentDownload> {
  late final TorrentRepository torrentRepository;
  CommonModel commonModel = CommonModel();

  @override
  void initState() {
    torrentStarter();
    super.initState();
  }

  torrentStarter() async {
    String path = await commonModel.savePathFetcher();
    torrentRepository = TorrentRepository(path, widget.infoHash);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: 0,
        itemBuilder: (_, index) => const Text(''),
      ),
    );
  }
}
