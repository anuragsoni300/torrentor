import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:torrentor/backend/model/piratebay_model/piratebay.dart';
import 'package:torrentor/common/permissions/storagepermission.dart';
import '../../../../backend/model/storgae/basestorage.dart';

class TorrentDownload extends StatefulWidget {
  final PirateBay? data;

  const TorrentDownload({Key? key, this.data}) : super(key: key);
  @override
  TorrentDownloadState createState() => TorrentDownloadState();
}

class TorrentDownloadState extends State<TorrentDownload>
    with TickerProviderStateMixin {
  late String myMagnet;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.data!.infoHash.toString().contains('magnet')
            ? myMagnet = widget.data!.infoHash!
            : myMagnet = 'magnet:?xt=urn:btih:${widget.data!.infoHash}';
        Provider.of<StorageRepository>(context, listen: false)
            .addInfoHash(myMagnet);
        showMyDialog(context);
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
