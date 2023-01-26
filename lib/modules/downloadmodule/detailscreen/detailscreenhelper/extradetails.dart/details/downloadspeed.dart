import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/backend/model/torrent/tasktorrent.dart';

class DownloadMoreSpeed extends StatefulWidget {
  const DownloadMoreSpeed({super.key});

  @override
  State<DownloadMoreSpeed> createState() => _DownloadMoreSpeedState();
}

class _DownloadMoreSpeedState extends State<DownloadMoreSpeed> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Provider.of<TaskTorrent?>(context) == null
            ? Text(
                '0 B',
                style: GoogleFonts.comfortaa(
                  textStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey
                        : Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    height: 1.5,
                  ),
                ),
                maxLines: 1,
              )
            : ValueListenableBuilder(
                valueListenable:
                    Provider.of<TaskTorrent?>(context)!.downloadSpeedValue,
                builder: (_, c, __) => Text(
                  '  $c ',
                  style: GoogleFonts.comfortaa(
                    textStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey
                          : Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      height: 1.5,
                    ),
                  ),
                  maxLines: 1,
                ),
              ),
        Icon(
          Icons.download_rounded,
          size: 7.w,
          color: Theme.of(context).colorScheme.brightness == Brightness.dark
              ? Colors.grey
              : Colors.black87,
        ),
      ],
    );
  }
}
