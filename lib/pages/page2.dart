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
          return ListView(
            children: box.toMap().entries.map((entry) {
              if (entry.value == null) {
                Provider.of<StorageRepository>(context).addInfoHash(entry.key);
              }
              return TorrentDownload(
                infoHash: entry.key,
                metaData: entry.value?[0],
                infoBuffer: entry.value?[1],
              );
            }).toList(),
          ); // keys.toList();
        }, // ListView.builder(
      ),
    );
  }
}
