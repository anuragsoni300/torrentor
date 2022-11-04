import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/modules/downloadmodule/detailscreen/detailscreenhelper/files.dart';
import 'package:torrentor/modules/downloadmodule/detailscreen/detailscreenhelper/name.dart';
import 'package:torrentor/modules/downloadmodule/detailscreen/detailscreenhelper/piecemap.dart';

import 'detailscreenhelper/extradetails.dart/extradetails.dart';

class DetailScreen extends StatelessWidget {
  final String name;
  const DetailScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: 5.h, left: 4.w, right: 4.w),
              child: Column(
                children: [
                  MyName(name: name),
                  const SizedBox(height: 20),
                  const Files(),
                  const SizedBox(height: 20),
                  MoreDetails(width: 92.w),
                  const PieceMap(),
                ],
              ),
            ),
          ),
          const BackButton(),
        ],
      ),
    );
  }
}
