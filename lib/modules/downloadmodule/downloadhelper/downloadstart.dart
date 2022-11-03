import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/modules/downloadmodule/downloadhelper/details/divider.dart';
import 'package:torrentor/modules/downloadmodule/downloadhelper/details/extradetails.dart/extradetails.dart';
import 'package:torrentor/modules/downloadmodule/downloadhelper/details/name.dart';

import '../../../backend/model/torrent/tasktorrent.dart';

class DownloadStart extends StatefulWidget {
  final String infoHash;
  final String name;
  const DownloadStart({Key? key, required this.infoHash, required this.name})
      : super(key: key);

  @override
  State<DownloadStart> createState() => _DownloadStartState();
}

class _DownloadStartState extends State<DownloadStart> {
  bool isPaused = false;
  @override
  Widget build(BuildContext context) {
    var backC = Theme.of(context).colorScheme.background;
    return ClayContainer(
      height: 130,
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
                Name(name: widget.name, width: 75.w),
                MyDivider(width: 75.w),
                ExtraDetails(width: 75.w)
              ],
            ),
            const MyVerticalDivider(),
            SizedBox(
              width: 9.w,
              child: Provider.of<TaskTorrent?>(context) == null
                  ? const CircularProgressIndicator()
                  : IconButton(
                      onPressed: () {
                        isPaused
                            ? Provider.of<TaskTorrent?>(context,
                                    listen: false)!
                                .resume()
                            : Provider.of<TaskTorrent?>(context,
                                    listen: false)!
                                .pause();
                        setState(() {
                          isPaused = !isPaused;
                        });
                      },
                      icon: Icon(
                        isPaused ? Icons.play_arrow_rounded : Icons.pause,
                        color: Theme.of(context).colorScheme.brightness ==
                                Brightness.dark
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
