import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

class LottieCircular extends StatefulWidget {
  const LottieCircular({Key? key}) : super(key: key);

  @override
  LottieCircularState createState() => LottieCircularState();
}

class LottieCircularState extends State<LottieCircular>
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
        'assets/circularprogress.json',
        height: 14.h,
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
