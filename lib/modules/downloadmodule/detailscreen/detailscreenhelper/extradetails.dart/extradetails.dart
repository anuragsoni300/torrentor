import 'package:flutter/material.dart';

import 'details/downloadspeed.dart';
import 'details/peers.dart';
import 'details/seeders.dart';
import 'details/size.dart';

class MoreDetails extends StatelessWidget {
  final double width;
  const MoreDetails({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(width: width / 2, child: const MyMoreSize()),
              SizedBox(width: width / 2, child: const CurrentMoreSeeders()),
            ],
          ),
          Row(
            children: [
              SizedBox(width: width / 2, child: const PeersMoreCount()),
              SizedBox(width: width / 2, child: const DownloadMoreSpeed()),
            ],
          ),
        ],
      ),
    );
  }
}
