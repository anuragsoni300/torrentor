import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieCircular extends StatefulWidget {
  @override
  _LottieCircularState createState() => _LottieCircularState();
}

class _LottieCircularState extends State<LottieCircular>
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
    return Center(
      child: Lottie.asset(
        'assets/circularprogress.json',
        height: 150,
        reverse: true,
        frameRate: FrameRate.max,
        controller: _controller,
        onLoaded: (composition) {
          _controller..duration = composition.duration;
          _controller.repeat();
        },
      ),
    );
  }
}
