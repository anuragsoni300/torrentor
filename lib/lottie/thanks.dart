import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/lottie/share.dart';

class LottieThanks extends StatefulWidget {
  @override
  _LottieThanksState createState() => _LottieThanksState();
}

class _LottieThanksState extends State<LottieThanks>
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w, right: 2.w, bottom: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 2.w),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 1.w, right: 2.w, top: 1.h, bottom: 1.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loving this app?',
                        style: GoogleFonts.comfortaa(
                          textStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white60
                                    : Colors.black,
                            height: 1.5,
                            fontWeight: FontWeight.w100,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                      Text(
                        'Share it to your friends.',
                        style: GoogleFonts.comfortaa(
                          textStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white60
                                    : Colors.black,
                            height: 1.5,
                            fontWeight: FontWeight.w100,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Share.share('''Hey buddy try this app ;)
                      https://play.google.com/store/apps/details?id=com.torrentor.iam''');
                },
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 1.5.h),
                    child: LottieShare(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Lottie.asset(
            'assets/thanks.json',
            height: 40.h,
            reverse: true,
            frameRate: FrameRate.max,
            controller: _controller,
            onLoaded: (composition) {
              _controller..duration = composition.duration;
              _controller.repeat();
            },
          ),
        ),
      ],
    );
  }
}
