import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/backend/model/storgae/basestorage.dart';
import 'package:torrentor/modules/downloadmodule/downloadtorrent.dart';

class PageTwo extends StatefulWidget {
  const PageTwo({super.key});

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  Map<String, bool> checkMetaFetchRunning = {};
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: ValueListenableBuilder(
        valueListenable: Provider.of<StorageRepository>(context).listenToBox(),
        builder: (_, Box box, __) {
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (_, index) {
              if (box.getAt(index) == null &&
                  checkMetaFetchRunning[box.keyAt(index)] == false) {
                checkMetaFetchRunning[box.keyAt(index)] = true;
                Provider.of<StorageRepository>(context)
                    .addInfoHash(box.keyAt(index));
              }
              return TorrentDownload(
                infoHash: box.keyAt(index),
                metaData: box.getAt(index)?[0],
                infoBuffer: box.getAt(index)?[1],
              );
            },
          );
        }, // ListView.builder(
      ),
    );
  }
}
