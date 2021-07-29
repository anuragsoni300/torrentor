import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TorrentSize extends StatefulWidget {
  final data;

  const TorrentSize({Key? key, this.data}) : super(key: key);
  @override
  _TorrentSizeState createState() => _TorrentSizeState();
}

class _TorrentSizeState extends State<TorrentSize>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
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
    double size = ((double.parse(widget.data.size) * 9.31) / 10000000000);
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4, top: 3),
      child: GestureDetector(
        onTap: () {
          if (_controller.isAnimating) {
            _controller.reset();
            _controller.forward();
          } else if (_controller.status == AnimationStatus.completed) {
            _controller.reset();
            _controller.forward();
          } else {
            _controller.forward();
          }
        },
        child: Column(
          children: [
            Theme.of(context).brightness == Brightness.dark
                ? Container(
                    height: 20,
                    width: 20,
                    child: SvgPicture.asset(
                      'assets/size.svg',
                      color: Colors.grey,
                    ),
                  )
                : Container(
                    height: 20,
                    width: 20,
                    child: SvgPicture.asset(
                      'assets/size.svg',
                      color: Colors.black.withAlpha(200),
                    ),
                  ),
            Text(
              size == 0
                  ? '0 MB'
                  : size.floor() == 0
                      ? size.toString().substring(2, 5) + ' MB'
                      : size.toString().substring(0, 4) + ' GB',
              style: GoogleFonts.gruppo(
                textStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black.withAlpha(230),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  height: 1.5,
                  wordSpacing: 2,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
