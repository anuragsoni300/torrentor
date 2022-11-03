import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sizer/sizer.dart';

class PercentIndicator extends StatelessWidget {
  final double progress;
  const PercentIndicator({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 4.w,
      addAutomaticKeepAlive: false,
      animation: true,
      animationDuration: 2000,
      curve: Curves.elasticInOut,
      circularStrokeCap: CircularStrokeCap.round,
      percent: progress / 100,
      progressColor: Colors.deepOrange,
      backgroundWidth: 0,
      lineWidth: 2,
      maskFilter: const MaskFilter.blur(BlurStyle.solid, 3),
      center: Text(progress.toInt().toString()),
    );
  }
}
