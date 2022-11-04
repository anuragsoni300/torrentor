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
    return Row(
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
                    double progress = double.parse(c.replaceAll('%', ''));
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
    );
  }
}
