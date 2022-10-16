import 'dart:math';

import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../backend/model/torrent/tasktorrent.dart';

class DownloadStart extends StatefulWidget {
  const DownloadStart({super.key});

  @override
  State<DownloadStart> createState() => _DownloadStartState();
}

class _DownloadStartState extends State<DownloadStart> {
  @override
  Widget build(BuildContext context) {
    var backC = Theme.of(context).colorScheme.background;
    return Provider.of<TaskTorrent?>(context) == null
        ? const SizedBox(child: Text('data'))
        : Padding(
            padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 2.h),
            child: ClayContainer(
              height: 300,
              width: double.infinity,
              parentColor: backC,
              surfaceColor: backC,
              color: backC,
              curveType: CurveType.convex,
              borderRadius: 1.3.h,
              spread: 0,
              child: ListView.builder(
                itemCount: Provider.of<TaskTorrent>(context).model.files.length,
                itemBuilder: (_, index) => Column(
                  children: [
                    Text(Provider.of<TaskTorrent>(context)
                        .model
                        .files[index]
                        .name),
                    Text(
                      formatBytes(
                          Provider.of<TaskTorrent>(context)
                              .model
                              .files[index]
                              .length,
                          2),
                    ),
                    const SizedBox(height: 20)
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
