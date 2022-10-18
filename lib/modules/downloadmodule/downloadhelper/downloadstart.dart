import 'dart:math';

import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../backend/model/torrent/tasktorrent.dart';

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
        height: 70,
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
              SizedBox(
                width: 75.w,
                child: Text(
                  Provider.of<TaskTorrent?>(context) == null
                      ? widget.infoHash
                      : Provider.of<TaskTorrent>(context).model.name,
                  style: GoogleFonts.comfortaa(
                    textStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey
                          : Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                      height: 1.5,
                    ),
                  ),
                  maxLines: 1,
                ),
              ),
              VerticalDivider(
                  color: Theme.of(context).colorScheme.brightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  thickness: 0.1),
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
              // Text(
              //   formatBytes(
              //       Provider.of<TaskTorrent>(context).model.length!, 2),
              //   style: GoogleFonts.comfortaa(
              //     textStyle: TextStyle(
              //       color:
              //           Theme.of(context).brightness == Brightness.dark
              //               ? Colors.grey
              //               : Colors.black87,
              //       fontWeight: FontWeight.w700,
              //       fontSize: 8.sp,
              //       height: 1.5,
              //     ),
              //   ),
              //   maxLines: 1,
              // ),
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
