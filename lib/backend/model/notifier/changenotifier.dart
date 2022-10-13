import 'package:flutter/material.dart';

class Change with ChangeNotifier {
  String _infoHash = '';
  String get infoHash => _infoHash;

  getchanged(String infoHash) {
    _infoHash = infoHash.split(':btih:').last.split('&').first;
    notifyListeners();
  }
}
