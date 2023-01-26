import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

class Nothing extends StatefulWidget {
  const Nothing({Key? key}) : super(key: key);

  @override
  NothingState createState() => NothingState();
}

class NothingState extends State<Nothing> with TickerProviderStateMixin {
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Lottie.asset(
              'assets/showads.json',
              height: 70.w,
              width: 100.w,
              reverse: true,
              frameRate: FrameRate.max,
              controller: _controller,
              onLoaded: (composition) {
                _controller.duration = composition.duration;
                _controller.repeat();
              },
            ),
            Text(
              '     Nothing to download',
              style: GoogleFonts.comfortaa(
                textStyle: TextStyle(
                  fontSize: 10.sp,
                  color: Theme.of(context).colorScheme.background ==
                          const Color.fromRGBO(242, 242, 242, 1)
                      ? Colors.black
                      : Colors.grey,
                  fontWeight: FontWeight.w700,
                ),
                height: 1.7,
              ),
            ),
          ],
        ),
        const SizedBox()
      ],
    );
  }
}
