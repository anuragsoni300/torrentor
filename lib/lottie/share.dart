import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

class LottieShare extends StatefulWidget {
  const LottieShare({Key? key}) : super(key: key);

  @override
  LottieShareState createState() => LottieShareState();
}

class LottieShareState extends State<LottieShare>
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
    return Center(
      child: Lottie.asset(
        Theme.of(context).backgroundColor == const Color.fromRGBO(242, 242, 242, 1)
            ? 'assets/share.json'
            : 'assets/share_dark.json',
        height: 12.w,
        width: 12.w,
        reverse: true,
        frameRate: FrameRate.max,
        controller: _controller,
        onLoaded: (composition) {
          _controller.duration = composition.duration;
          _controller.repeat();
        },
      ),
    );
  }
}
