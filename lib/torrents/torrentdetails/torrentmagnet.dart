import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class TorrentMagnet extends StatefulWidget {
  final data;

  const TorrentMagnet({Key? key, this.data}) : super(key: key);
  @override
  _TorrentMagnetState createState() => _TorrentMagnetState();
}

class _TorrentMagnetState extends State<TorrentMagnet>
    with TickerProviderStateMixin {
  late String myMagnet;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        microseconds: 800,
      ),
      reverseDuration: Duration(
        microseconds: 800,
      ),
    );
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
        if (_controller.isAnimating) {
          _controller.reset();
          _controller.forward();
        } else if (_controller.status == AnimationStatus.completed) {
          _controller.reset();
          _controller.forward();
        } else {
          _controller.forward();
        }
        Clipboard.setData(
          new ClipboardData(
            text: widget.data.infoHash.toString().contains('magnet')
                ? widget.data.infoHash
                : 'magnet:?xt=urn:btih:${widget.data.infoHash}',
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.black,
            margin: EdgeInsets.only(left: 20, right: 20, bottom: 30),
            behavior: SnackBarBehavior.floating,
            content: Container(
              height: 15,
              child: Center(
                child: Text(
                  "Magnet Copied",
                  style: GoogleFonts.gruppo(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            duration: Duration(milliseconds: 600),
          ),
        );
      },
      child: Icon(
        Icons.copy,
        color: Theme.of(context).backgroundColor ==
                Color.fromRGBO(242, 242, 242, 1)
            ? Colors.black.withAlpha(200)
            : Colors.grey,
        size: 20,
      ),
    );
  }
}
