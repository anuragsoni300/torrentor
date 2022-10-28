// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import '../../bencode_base.dart';
import '../../dartorrent_common_base.dart';
import 'peer_event.dart';
import 'http_tracker_base.dart';
import 'tracker.dart';

/// Torrent http/https tracker implement.
///
/// Torrent http tracker protocol specification :
/// [HTTP/HTTPS Tracker Protocol](https://wiki.theory.org/index.php/BitTorrentSpecification#Tracker_HTTP.2FHTTPS_Protocol).
///
class HttpTracker extends Tracker with HttpTrackerBase {
  String? _trackerId;
  String? _currentEvent;
  HttpTracker(Uri? _uri, Uint8List? infoHashBuffer,
      {AnnounceOptionsProvider? provider})
      : super(
            'http:${_uri?.host}:${_uri?.port}${_uri?.path}', _uri, infoHashBuffer,
            provider: provider);

  String? get currentTrackerId {
    return _trackerId;
  }

  String? get currentEvent {
    return _currentEvent;
  }

  @override
  Future<PeerEvent?> stop([bool force = false]) async {
    await close();
    var f = super.stop(force);
    return f;
  }

  @override
  Future<PeerEvent?> complete() async {
    await close();
    var f = super.complete();
    return f;
  }

  @override
  Future dispose([dynamic reason]) async {
    await close();
    return super.dispose(reason);
  }

  @override
  Future<PeerEvent?> announce(String? eventType, Map<String, dynamic> options) {
    _currentEvent = eventType; // Modifying the current event, stop and complete will also call this method, so record the current event type here
    return httpGet<PeerEvent?>(options);
  }

  ///
  /// Create a URL string to access the announcement,
  /// More information can be found at [HTTP/HTTPS Tracker Request Parameters](https://wiki.theory.org/index.php/BitTorrentSpecification#Tracker_Request_Parameters)
  ///
  /// Regarding the access query parameters:
  /// -compact : I always set bit 1
  /// -downloaded : number of bytes downloaded
  /// -uploaded : number of bytes uploaded
  /// -left : remaining undownloaded bytes
  /// -numwant : optional. The default value here is 50. It is best not to set it to -1. When accessing some addresses, the other party will think it is an illegal number.
  /// -info_hash : Required. from torrent files. It should be noted here that the urlencode of *Uri*is not used to obtain,
  /// This is because this class uses UTF-8 encoding when generating the query string, which causes the info_hash that cannot have some special characters to be encoded correctly, so it is handled manually here.
  /// -port : Required. TCP listening port
  /// -peer_id : Required. A randomly generated string with a length of 20 should be encoded by query string, but currently I use numbers and English letters, so I use it directly
  /// -event : must be one of stopped, started, completed. To do it according to the protocol, the first access must be started. If not specified, the other party will consider it an ordinary announcement visit
  /// -trackerid : optional, should be set if the last request included trackerid. Some responses will contain tracker id. Some responses will carry trackerid, then I will set this field.
  /// -ip : optional
  /// -key : optional
  /// -no_peer_id : This field is ignored if compact is specified. My compact here is always 1, so this value is not set
  ///
  @override
  Map<String?, dynamic> generateQueryParameters(Map<String?, dynamic>? options) {
    var params = <String?, String?>{};
    params['compact'] = options?['compact'].toString();
    params['downloaded'] = options?['downloaded'].toString();
    params['uploaded'] = options?['uploaded'].toString();
    params['left'] = options?['left'].toString();
    params['numwant'] = options?['numwant'].toString();
    // infohash value usually can not be decode by utf8, because some special character,
    // so I transform them with String.fromCharCodes , when transform them to the query component, use latin1 encoding
    params['info_hash'] = Uri.encodeQueryComponent(
        String.fromCharCodes(infoHashBuffer!),
        encoding: latin1);
    params['port'] = options?['port'].toString();
    params['peer_id'] = options?['peerId'];
    var event = currentEvent;
    if (event != null) {
      params['event'] = event;
    } else {
      params['event'] = EVENT_STARTED;
    }
    if (currentTrackerId != null) params['trackerid'] = currentTrackerId;
    // params['no_peer_id']
// params['ip'] ; optional
// params['key'] ; optional
    return params;
  }

  ///
  /// Decode the return bytebuffer with bencoder.
  ///
  /// - Get the 'interval' value , and make sure the return Map contains it(or null), because the Tracker
  /// will check the return Map , if it has 'interval' value , Tracker will update the interval timer.
  /// - If it has 'tracker id' , need to store it , use it next time.
  /// - parse 'peers' informations. the peers usually is a List<int> , need to parse it to 'n.n.n.n:p' formate
  /// ip address.
  /// - Sometimes , the remote will return 'failer reason', then need to throw a exception
  @override
  PeerEvent processResponseData(Uint8List data) {
    var result = decode(data) as Map;
    // You cuo wu , jiu tao chu qu
    if (result['failure reason'] != null) {
      var errorMsg = String.fromCharCodes(result['failure reason']);
      throw errorMsg;
    }
    // If 'tracker id' is existed, record it
    if (result['tracker id'] != null) {
      _trackerId = result['tracker id'];
    }

    var event = PeerEvent(infoHash, url);
    result.forEach((key, value) {
      if (key == 'min interval') {
        event.minInterval = value;
        return;
      }
      if (key == 'interval') {
        event.interval = value;
        return;
      }
      if (key == 'warning message' && value != null) {
        event.warning = String.fromCharCodes(value);
        return;
      }
      if (key == 'complete') {
        event.complete = value;
        return;
      }
      if (key == 'incomplete') {
        event.incomplete = value;
        return;
      }
      if (key == 'downloaded') {
        event.downloaded = value;
        return;
      }
      if (key == 'peers' && value != null) {
        _fillPeers(event, value);
        return;
      }
      // BEP0048
      if (key == 'peers6' && value != null) {
        _fillPeers(event, value, InternetAddressType.IPv6);
        return;
      }
      // record the values don't process
      event.setInfo(key, value);
    });
    return event;
  }

  void _fillPeers(PeerEvent event, dynamic value,
      [InternetAddressType type = InternetAddressType.IPv4]) {
    if (value is Uint8List) {
      if (type == InternetAddressType.IPv6) {
        try {
          var peers = CompactAddress.parseIPv6Addresses(value);
          for (var peer in peers) {
            event.addPeer(peer);
          }
        } catch (e) {
          //
        }
      } else if (type == InternetAddressType.IPv4) {
        try {
          var peers = CompactAddress.parseIPv4Addresses(value);
          for (var peer in peers) {
            event.addPeer(peer);
          }
        } catch (e) {
          //
        }
      }
    } else {
      if (value is List) {
        for (var peer in value) {
          var ip = peer['ip'];
          var port = peer['port'];
          var address = InternetAddress.tryParse(ip);
          if (address != null) {
            try {
              event.addPeer(CompactAddress(address, port));
            } catch (e) {
              log('parse peer address error',
                  error: e, name: runtimeType.toString());
            }
          }
        }
      }
    }
  }

  @override
  Uri? get url => announceUrl;
}
