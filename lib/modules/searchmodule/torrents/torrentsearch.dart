import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
// import 'package:torrentor/ads.dart';
import 'package:torrentor/backend/model/piratebay_model/piratebay.dart';
import 'package:torrentor/lottie/circularprogress.dart';

import 'torrentdetails/torrentdownload.dart';
import 'torrentdetails/torrentleechers.dart';
import 'torrentdetails/torrentmagnet.dart';
import 'torrentdetails/torrentseeders.dart';
import 'torrentdetails/torrentsize.dart';
import 'torrentdetails/torrentsname.dart';

class MovieTorrentsList extends StatefulWidget {
  final List<PirateBay> torrents;
  const MovieTorrentsList({Key? key, required this.torrents}) : super(key: key);

  @override
  MovieTorrentsListState createState() => MovieTorrentsListState();
}

class MovieTorrentsListState extends State<MovieTorrentsList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var backC = Theme.of(context).colorScheme.background;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: widget.torrents.isEmpty
          ? const Center(child: LottieCircular())
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: widget.torrents.length,
              itemBuilder: (context, index) {
                return widget.torrents[index].infoHash == ''
                    ? const SizedBox() // Ads()
                    : index == widget.torrents.length
                        ? SizedBox(height: 10.h)
                        : Padding(
                            padding: EdgeInsets.only(
                                left: 4.w, right: 4.w, top: 2.h, bottom: 2.h),
                            child: ClayContainer(
                              parentColor: backC,
                              surfaceColor: backC,
                              color: backC,
                              curveType: CurveType.convex,
                              borderRadius: 1.5.h,
                              spread: 0,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    bottom: 2.h,
                                    top: 0.h,
                                    left: 4.w,
                                    right: 4.w),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TorrentName(data: widget.torrents[index]),
                                    widget.torrents[index].name ==
                                            "No results returned"
                                        ? Container()
                                        : const Divider(),
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
                                    // const Divider(),
                                  ],
                                ),
                              ),
                            ),
                          );
              },
            ),
    );
  }
}
