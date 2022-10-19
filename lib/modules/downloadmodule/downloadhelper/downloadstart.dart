import 'dart:math';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/modules/downloadmodule/downloadhelper/details/divider.dart';
import 'package:torrentor/modules/downloadmodule/downloadhelper/details/extradetails.dart/extradetails.dart';
import 'package:torrentor/modules/downloadmodule/downloadhelper/details/name.dart';

class DownloadStart extends StatefulWidget {
  final String infoHash;
  const DownloadStart({super.key, required this.infoHash});

  @override
  State<DownloadStart> createState() => _DownloadStartState();
}

class _DownloadStartState extends State<DownloadStart> {
  @override
  Widget build(BuildContext context) {
    var backC = Theme.of(context).colorScheme.background;
    return Padding(
      padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 2.h),
      child: ClayContainer(
        height: 100,
        width: 92.w,
        parentColor: backC,
        surfaceColor: backC,
        color: backC,
        curveType: CurveType.convex,
        borderRadius: 1.3.h,
        spread: 0,
        child: Padding(
          padding: EdgeInsets.only(left: 2.w, right: 2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Name(infoHash: widget.infoHash, width: 75.w),
                  MyDivider(width: 75.w),
                  ExtraDetails(width: 75.w)
                ],
              ),
              const MyVerticalDivider(),
              SizedBox(
                width: 9.w,
                child: Icon(
                  Icons.pause,
                  color: Theme.of(context).colorScheme.brightness ==
                          Brightness.dark
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatBytes(int bytes, int decimals) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
}
