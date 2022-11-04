import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sizer/sizer.dart';

class PercentIndicator extends StatelessWidget {
  final double progress;
  final double? size;
  const PercentIndicator({super.key, required this.progress, this.size});

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: size ?? 4.w,
      addAutomaticKeepAlive: false,
      animation: true,
      animationDuration: 0,
      curve: Curves.elasticInOut,
      circularStrokeCap: CircularStrokeCap.round,
      percent: progress / 100,
      progressColor: Colors.deepOrange,
      backgroundWidth: 0,
      lineWidth: 3,
      maskFilter: const MaskFilter.blur(BlurStyle.solid, 3),
      center: Text(
        '${progress.toInt().toString()}${size != null ? '%' : ''}',
        style: GoogleFonts.comfortaa(
          textStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey
                : const Color.fromARGB(221, 53, 52, 52),
            fontWeight: FontWeight.w700,
            fontSize: size != null ? 11.sp : 9.sp,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
