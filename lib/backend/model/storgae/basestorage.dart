import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../common/commonmodel.dart';

abstract class BaseStorageRepository {
  Future<Box> openBox();
  List<dynamic> getInfoHash();
  Future<void> addInfoHash(String infoHash);
  Future<void> removeInfoHash(String infoHash);
  ValueListenable<Box<dynamic>> listenToBox();
}

class StorageRepository extends BaseStorageRepository {
  Box? box;
  String boxname = 'infohash';
  CommonModel commonModel = CommonModel();

  StorageRepository() {
    openBox();
  }

  @override
  Future<Box> openBox() async {
    box = await Hive.openBox<dynamic>(boxname);
    return box!;
  }

  @override
  List<dynamic> getInfoHash() {
    return box!.values.toList();
  }

  @override
  Future<void> addInfoHash(String infoHash) async {
    String info = infoHash.split(':btih:').last.split('&').first;
    if (box!.get(info) == null) {
      await box!.put(info, null);
      // ReceivePort myReceivePort = ReceivePort();
      // Isolate.spawn<SendPort>(heavyComputationTask, myReceivePort.sendPort);
      // SendPort mikeSendPort = await myReceivePort.first;
      // ReceivePort mikeResponseReceivePort = ReceivePort();
      // mikeSendPort.send([info, mikeResponseReceivePort.sendPort]);
      // final metaData = await mikeResponseReceivePort.first;
      List<dynamic> metaData = await commonModel.metaData(info);
      await box!.put(info, metaData);
    }
  }

  @override
  Future<void> removeInfoHash(String infoHash) async {
    await box!.delete(infoHash);
  }

  @override
  ValueListenable<Box> listenToBox() {
    var data = box!.listenable();
    return data;
  }
}

// Future<void> heavyComputationTask(SendPort mySendPort) async {
//   CommonModel commonModel = CommonModel();
//   ReceivePort mikeReceivePort = ReceivePort();
//   mySendPort.send(mikeReceivePort.sendPort);
//   await for (var message in mikeReceivePort) {
//     final String info = message[0];
//     final SendPort mikeResponseSendPort = message[1];
//     List<dynamic> metaData = await commonModel.metaData(info);
//     mikeResponseSendPort.send(metaData);
//   }
// }
