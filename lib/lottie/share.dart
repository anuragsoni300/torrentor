import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieShare extends StatefulWidget {
  @override
  _LottieShareState createState() => _LottieShareState();
}

class _LottieShareState extends State<LottieShare>
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
        Theme.of(context).backgroundColor == Color.fromRGBO(242, 242, 242, 1)
            ? 'assets/share.json'
            : 'assets/share_dark.json',
        height: 50,
        width: 50,
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
