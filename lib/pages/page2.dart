import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:torrentor/backend/model/storgae/basestorage.dart';

class PageTwo extends StatefulWidget {
  const PageTwo({super.key});

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  final StorageRepository storageRepository = StorageRepository();
  List<String> infoHash = [];
  @override
  void initState() {
    getListofInfoHash();
    super.initState();
  }

  getListofInfoHash() async {
    Box box = await storageRepository.openBox();
    List<String> list = storageRepository.getInfoHash(box);
    setState(() {
      infoHash = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: infoHash.length,
      itemBuilder: (_, index) => Text(infoHash[index]),
    );
  }
}
