import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:torrentor/backend/model/piratebay_model/piratebay.dart';
import '../../../backend/model/notifier/changenotifier.dart';
import '../../../backend/model/storgae/basestorage.dart';

class TorrentDownload extends StatefulWidget {
  final PirateBay? data;

  const TorrentDownload({Key? key, this.data}) : super(key: key);
  @override
  TorrentDownloadState createState() => TorrentDownloadState();
}

class TorrentDownloadState extends State<TorrentDownload>
    with TickerProviderStateMixin {
  final StorageRepository storageRepository = StorageRepository();
  late String myMagnet;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  putListofInfoHash(infohash) async {
    Box box = await storageRepository.openBox();
    await storageRepository.addInfoHash(box, infohash);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        widget.data!.infoHash.toString().contains('magnet')
            ? myMagnet = widget.data!.infoHash!
            : myMagnet = 'magnet:?xt=urn:btih:${widget.data!.infoHash}';
        putListofInfoHash(myMagnet);
        Provider.of<Change>(context, listen: false).getchanged(myMagnet);
      },
      child: Icon(
        Icons.download_rounded,
        color: Theme.of(context).colorScheme.background ==
                const Color.fromRGBO(242, 242, 242, 1)
            ? Colors.black.withAlpha(200)
            : Colors.grey,
      ),
    );
  }
}
