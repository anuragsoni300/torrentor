import 'package:flutter/material.dart';
import 'package:torrentor/modules/downloadmodule/downloadhelper/details/extradetails.dart/details/downloadspeed.dart';
import 'package:torrentor/modules/downloadmodule/downloadhelper/details/extradetails.dart/details/filescount.dart';
import 'package:torrentor/modules/downloadmodule/downloadhelper/details/extradetails.dart/details/size.dart';

import 'details/seeders.dart';

class ExtraDetails extends StatelessWidget {
  final double width;
  const ExtraDetails({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: width / 4, child: const MySize()),
          SizedBox(width: width / 4, child: const CurrentSeeders()),
          SizedBox(width: width / 4, child: const FilesCount()),
          SizedBox(width: width / 4, child: const DownloadSpeed()),
        ],
      ),
    );
  }
}
