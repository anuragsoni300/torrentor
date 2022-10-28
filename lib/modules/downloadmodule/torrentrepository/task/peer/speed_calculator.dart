// ignore_for_file: constant_identifier_names

import 'dart:math';

/// 5 seconds
const RECORD_TIME = 5000000;

/// Upload Download Speed ​​Calculator
mixin SpeedCalculator {
  final List<List<int>> _downloadedHistory = <List<int>>[];

  /// Average download speed over the current 5 seconds
  double get currentDownloadSpeed {
    if (_downloadedHistory.isEmpty) return 0.0;
    var now = DateTime.now().microsecondsSinceEpoch;
    var d = 0;
    int? s;
    for (var i = 0; i < _downloadedHistory.length;) {
      var dd = _downloadedHistory[i];
      if ((now - dd[1]) > RECORD_TIME) {
        _downloadedHistory.removeAt(i);
      } else {
        d += dd[0];
        s ??= dd[1];
        s = min(dd[1], s);
        i++;
      }
    }
    if (d == 0) return 0.0;
    var passed = now - s!;
    if (passed == 0) return 0.0;
    return (d / 1024) / (passed / 1000000);
  }

  /// Average download speed from peer connection to current
  double get averageDownloadSpeed {
    var passed = livingTime;
    if (passed == null || passed == 0) return 0.0;
    return (_downloaded / 1024) / (passed / 1000000);
  }

  /// Average upload speed from peer connection to current
  double get averageUploadSpeed {
    var passed = livingTime;
    if (passed == null || passed == 0) return 0.0;
    return (_uploaded / 1024) / (passed / 1000000);
  }

  /// The duration from the start of the connection until the peer is destroyed
  int? get livingTime {
    if (_startTime == null) return null;
    var e = _endTime;
    e ??= DateTime.now().microsecondsSinceEpoch;
    return e - _startTime!;
  }

  int? _startTime;

  int? _endTime;

  int _downloaded = 0;

  /// The total amount of data downloaded from the remote, in bytes
  int get downloaded => _downloaded;

  int _uploaded = 0;

  /// The total amount of data uploaded to the remote, in bytes
  int get uploaded => _uploaded;

  /// Update download
  void updateDownload(List<List<int>>? requests) {
    if (requests == null || requests.isEmpty) return;
    var downloaded = 0;
    for (var request in requests) {
      if (request[4] != 0) continue; // Re-time does not count
      downloaded += request[2];
    }
    _downloadedHistory.add([downloaded, DateTime.now().microsecondsSinceEpoch]);
    _downloaded += downloaded;
  }

  void updateUpload(int uploaded) {
    _uploaded += uploaded;
  }

  /// Speed ​​calculation starts timing
  void startSpeedCalculator() {
    _startTime = DateTime.now().microsecondsSinceEpoch;
  }

  /// Speed ​​calculation stops timing
  void stopSpeedCalculator() {
    _endTime = DateTime.now().microsecondsSinceEpoch;
    _downloadedHistory.clear();
  }
}
