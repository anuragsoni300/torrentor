import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/backend/model/piratebay_model/piratebay.dart';

class TorrentSize extends StatefulWidget {
  final PirateBay? data;

  const TorrentSize({Key? key, this.data}) : super(key: key);
  @override
  TorrentSizeState createState() => TorrentSizeState();
}

class TorrentSizeState extends State<TorrentSize>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      reverseDuration: const Duration(
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
    return Padding(
      padding:
          EdgeInsets.only(left: 2.w, right: 2.w, bottom: 0.4.h, top: 0.3.h),
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
                ? SizedBox(
                    height: 4.w,
                    width: 4.w,
                    child: SvgPicture.asset(
                      'assets/size.svg',
                      color: Colors.grey,
                    ),
                  )
                : SizedBox(
                    height: 4.w,
                    width: 4.w,
                    child: SvgPicture.asset(
                      'assets/size.svg',
                      color: Colors.black.withAlpha(200),
                    ),
                  ),
            Text(
              widget.data!.size,
              style: GoogleFonts.gruppo(
                textStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black.withAlpha(230),
                  fontWeight: FontWeight.w700,
                  fontSize: 10.sp,
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
