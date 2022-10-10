import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/backend/model/piratebay_model/piratebay.dart';
import 'package:url_launcher/url_launcher.dart';

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
      onTap: () async {
        widget.data!.infoHash.toString().contains('magnet')
            ? myMagnet = widget.data!.infoHash!
            : myMagnet = 'magnet:?xt=urn:btih:${widget.data!.infoHash}';
        if (!await launchUrl(
          Uri.parse(myMagnet),
          mode: LaunchMode.externalApplication,
        )) {
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel:
                MaterialLocalizations.of(context).modalBarrierDismissLabel,
            barrierColor: Colors.black45,
            transitionDuration: const Duration(milliseconds: 200),
            pageBuilder: (BuildContext buildContext, Animation animation,
                Animation secondaryAnimation) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Material(
                  color: Colors.transparent,
                  child: Center(
                    child: Container(
                      width: 70.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.background,
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Cannot find any torrent downloader.\n         Download it and try again",
                            style: GoogleFonts.comfortaa(
                              textStyle: TextStyle(
                                fontSize: 10.sp,
                                color: Theme.of(context).colorScheme.background ==
                                        const Color.fromRGBO(242, 242, 242, 1)
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              height: 1.7,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 2.h,
                                  bottom: 0.4.h,
                                  left: 4.w,
                                  right: 4.w),
                              child: Card(
                                elevation: 15,
                                color: Theme.of(context).colorScheme.background ==
                                        const Color.fromRGBO(242, 242, 242, 1)
                                    ? Colors.black
                                    : Colors.white,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 1.h,
                                      bottom: 1.h,
                                      left: 8.w,
                                      right: 8.w),
                                  child: Text(
                                    'OK',
                                    style: GoogleFonts.comfortaa(
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        color:
                                            Theme.of(context).colorScheme.background !=
                                                    const Color.fromRGBO(
                                                        242, 242, 242, 1)
                                                ? Colors.black
                                                : Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
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
