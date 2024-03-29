import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/backend/model/storgae/basestorage.dart';
import 'package:torrentor/lottie/nothing.dart';
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
          return box.length == 0
              ? const Nothing()
              : ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (_, index) {
                    String infoHash = box.keyAt(index);
                    dynamic data = box.getAt(index);
                    dynamic metaData = data?[0];
                    List<int>? infoBuffer = data?[1];
                    return TorrentDownload(
                      infoHash: infoHash,
                      metaData: metaData,
                      infoBuffer: infoBuffer,
                    );
                  },
                );
        },
      ),
    );
  }
}
