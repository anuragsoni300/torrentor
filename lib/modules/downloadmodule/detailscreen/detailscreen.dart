import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/modules/downloadmodule/detailscreen/detailscreenhelper/files.dart';
import 'package:torrentor/modules/downloadmodule/detailscreen/detailscreenhelper/name.dart';
import 'package:torrentor/modules/downloadmodule/detailscreen/detailscreenhelper/piecemap.dart';
import '../../../backend/model/torrent/tasktorrent.dart';
import 'detailscreenhelper/extradetails.dart/extradetails.dart';

class DetailScreen extends StatelessWidget {
  final String name;
  const DetailScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(top: 5.h, left: 4.w, right: 4.w),
                  child: Column(
                    children: [
                      MyName(name: name),
                      const SizedBox(height: 20),
                      const Files(),
                      const PieceMap(),
                    ],
                  ),
                ),
              ),
              MoreDetails(width: 92.w),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButton(
                color:
                    Theme.of(context).colorScheme.brightness == Brightness.dark
                        ? Colors.grey
                        : Colors.black,
              ),
              Provider.of<TaskTorrent?>(context) == null
                  ? CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.brightness ==
                              Brightness.dark
                          ? Colors.grey
                          : Colors.black,
                    )
                  : ValueListenableBuilder<bool>(
                      valueListenable:
                          Provider.of<TaskTorrent?>(context)!.isPaused,
                      builder: (_, c, __) => IconButton(
                        onPressed: () {
                          c
                              ? Provider.of<TaskTorrent?>(context,
                                      listen: false)!
                                  .resume()
                              : Provider.of<TaskTorrent?>(context,
                                      listen: false)!
                                  .pause();
                        },
                        icon: Icon(
                          c ? Icons.play_arrow_rounded : Icons.pause,
                          color: Theme.of(context).colorScheme.brightness ==
                                  Brightness.dark
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
