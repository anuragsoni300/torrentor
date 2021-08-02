import 'package:clay_containers/clay_containers.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:torrentor/ads.dart';
import 'package:torrentor/backend/model/piratebay_model/piratebay.dart';
import 'package:torrentor/lottie/circularprogress.dart';
import 'package:torrentor/torrents/torrentdetails/torrentdownload.dart';
import 'package:torrentor/torrents/torrentdetails/torrentleechers.dart';
import 'package:torrentor/torrents/torrentdetails/torrentmagnet.dart';
import 'package:torrentor/torrents/torrentdetails/torrentseeders.dart';
import 'package:torrentor/torrents/torrentdetails/torrentsize.dart';
import 'package:torrentor/torrents/torrentdetails/torrentsname.dart';

class MovieTorrentsList extends StatefulWidget {
  final List<PirateBay> torrents;
  const MovieTorrentsList({Key? key, required this.torrents}) : super(key: key);

  @override
  _MovieTorrentsListState createState() => _MovieTorrentsListState();
}

class _MovieTorrentsListState extends State<MovieTorrentsList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var backC = Theme.of(context).backgroundColor;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: widget.torrents.isEmpty
          ? Center(child: LottieCircular())
          : ListView.builder(
              itemCount: widget.torrents.length,
              itemBuilder: (context, index) {
                return widget.torrents[index].infoHash == ''
                    ? Ads()
                    : Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20, top: 15),
                        child: ClayContainer(
                          parentColor: backC,
                          surfaceColor: backC,
                          color: Theme.of(context).backgroundColor,
                          curveType: CurveType.convex,
                          borderRadius: 15,
                          emboss: true,
                          depth: 20,
                          spread: 2.5,
                          height: 170,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TorrentName(data: widget.torrents[index]),
                                  widget.torrents[index].name ==
                                          "No results returned"
                                      ? Container()
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Divider(),
                                        ),
                                  widget.torrents[index].name ==
                                          "No results returned"
                                      ? Container()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TorrentSize(
                                                data: widget.torrents[index]),
                                            TorrentMagnet(
                                                data: widget.torrents[index]),
                                            TorrentDownload(
                                                data: widget.torrents[index]),
                                            TorrentSeeders(
                                                data: widget.torrents[index]),
                                            TorrentLeechers(
                                                data: widget.torrents[index]),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
              },
            ),
    );
  }
}
