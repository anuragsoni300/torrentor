import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class TorrentDownload extends StatefulWidget {
  final data;

  const TorrentDownload({Key? key, this.data}) : super(key: key);
  @override
  _TorrentDownloadState createState() => _TorrentDownloadState();
}

class _TorrentDownloadState extends State<TorrentDownload>
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
        widget.data.infoHash.toString().contains('magnet')
            ? myMagnet = widget.data.infoHash
            : myMagnet = 'magnet:?xt=urn:btih:${widget.data.infoHash}';
        await canLaunch(myMagnet)
            ? launch(myMagnet)
            : showGeneralDialog(
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
                          width: 300,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).backgroundColor,
                          ),
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Cannot find any torrent downloader.\n         Download it and try again",
                                style: GoogleFonts.comfortaa(
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).backgroundColor ==
                                            Color.fromRGBO(242, 242, 242, 1)
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
                                      top: 15, bottom: 4, left: 20, right: 20),
                                  child: Card(
                                    elevation: 15,
                                    color: Colors.blueAccent,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 12,
                                          bottom: 12,
                                          left: 40,
                                          right: 40),
                                      child: Text(
                                        'OK',
                                        style: GoogleFonts.comfortaa(
                                          textStyle: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                        .backgroundColor ==
                                                    Color.fromRGBO(
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
      },
      child: Icon(
        Icons.download_rounded,
        color: Theme.of(context).backgroundColor ==
                Color.fromRGBO(242, 242, 242, 1)
            ? Colors.black.withAlpha(200)
            : Colors.grey,
      ),
    );
  }
}
