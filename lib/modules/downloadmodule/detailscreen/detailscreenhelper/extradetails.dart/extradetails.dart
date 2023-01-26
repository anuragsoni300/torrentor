import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/common/percentindicator.dart';
import '../../../../../backend/model/torrent/tasktorrent.dart';
import 'details/downloadspeed.dart';
import 'details/peers.dart';
import 'details/seeders.dart';
import 'details/size.dart';

class MoreDetails extends StatelessWidget {
  final double width;
  const MoreDetails({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    var backC = Theme.of(context).colorScheme.background;
    return Container(
      decoration: BoxDecoration(
          color: backC,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(1.3.h),
            topRight: Radius.circular(1.3.h),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black38
                  : Colors.black12,
              blurRadius: 30.0,
            ),
          ]),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              height: 4,
              width: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey
                  : Colors.black54,
                borderRadius: BorderRadius.circular(1.3.h),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black38
                        : Colors.black12,
                    blurRadius: 30.0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: width / 3,
                  child: Column(
                    children: const [
                      MyMoreSize(),
                      CurrentMoreSeeders(),
                    ],
                  ),
                ),
                SizedBox(
                  width: width / 3,
                  child: Provider.of<TaskTorrent?>(context) == null
                      ? const PercentIndicator(progress: 0.00)
                      : ValueListenableBuilder<String>(
                          valueListenable:
                              Provider.of<TaskTorrent?>(context)!.progressValue,
                          builder: (_, c, __) {
                            double progress =
                                double.parse(c.replaceAll('%', ''));
                            return PercentIndicator(
                              progress: progress,
                              size: 6.w,
                            );
                          },
                        ),
                ),
                SizedBox(
                  width: width / 3,
                  child: Column(
                    children: const [
                      PeersMoreCount(),
                      DownloadMoreSpeed(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
