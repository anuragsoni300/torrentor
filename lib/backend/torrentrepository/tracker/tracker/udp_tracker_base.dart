// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import '../../dartorrent_common_base.dart';

/// When connecting for the first time, the connection id is set by itself, and all documents mention using this number, saying that it is a magic number
const START_CONNECTION_ID_NUMER = 0x41727101980;

/// The connection id at the beginning of the connection, which is a fixed value of 0x41727101980
const START_CONNECTION_ID = [0, 0, 4, 23, 39, 16, 25, 128];
const ACTION_CONNECT = [0, 0, 0, 0];
const ACTION_ANNOUNCE = [0, 0, 0, 1];
const ACTION_SCRAPE = [0, 0, 0, 2];
const ACTION_ERROR = [0, 0, 0, 3];

/// The timeout for the socket to receive messages, 15 seconds
const TIME_OUT = Duration(seconds: 15);

const EVENTS = <String, int>{'completed': 1, 'started': 2, 'stopped': 3};

///
/// The access steps of announce and scrap are exactly the same, but the data sent and returned are different, so here is a mixin,
/// With the function of UDP connecting to the host, the tracker and scraper need to send data and process the returned data.
mixin UDPTrackerBase {
  /// UDP sockets.
  ///
  /// Basically one connection -after the response it is closed. The second connection creates a new
  RawDatagramSocket? _socket;

  /// session id. A set of bytebuffers of length 4, randomly generated
  List<int>? _transcationId;

  /// Connection ID. After sending a message to the remote for the first time, the remote will return a connection id, and send the message the second time
  /// Need to carry this ID
  Uint8List? _connectionId;

  /// Distance URL
  // Uri get uri;

  Future<List<CompactAddress?>?> get addresses;

  bool _closed = false;

  bool get isClosed => _closed;

  /// Get the current transcation id, and return if there is one, indicating that the current communication has not been completed. Regenerate if not
  List<int> get transcationId {
    _transcationId ??= _generateTranscationId();
    return _transcationId!;
  }

  /// Convert transaction id to number
  int get transcationIdNum {
    return ByteData.view(Uint8List.fromList(transcationId).buffer).getUint32(0);
  }

  /// Generate a random 4-byte bytebuffer
  List<int> _generateTranscationId() {
    return randomBytes(4);
  }

  int maxConnectRetryTimes = 3;

  /// First connection with Remote communication
  ///
  /// When Announce and Scrape communicate, this first step must be taken, which is fixed.
  ///
  /// The parameter completer is a `Completer` instance. Used to intercept the exception that occurs, and intercepted by completeError
  Future<void> _connect(
      Map? options, List<CompactAddress?>? address, Completer completer) async {
    if (isClosed) {
      try {
        if (!completer.isCompleted) completer.completeError('Tracker closed');
      } catch (e) {
        log(e.toString());
      }
      return;
    }
    var list = <int>[];
    list.addAll(START_CONNECTION_ID); //it's a magic id
    list.addAll(ACTION_CONNECT);
    list.addAll(transcationId);
    var messageBytes = Uint8List.fromList(list);
    try {
      _sendMessage(messageBytes, address);
      return;
    } catch (e) {
      if (!completer.isCompleted) completer.completeError(e);
      await close();
    }
  }

  /// Entry function for communicating with remote. return a future
  Future<T?> contactAnnouncer<T>(Map? options) async {
    if (isClosed) return null;
    var completer = Completer<T>();
    var adds = await addresses;
    if (adds == null || adds.isEmpty) {
      await close();
      if (!completer.isCompleted) {
        completer.completeError('InternetAddress cant be null');
      }
      return completer.future;
    }
    _socket?.close();
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    _socket?.listen((event) async {
      if (event == RawSocketEvent.read) {
        var datagram = _socket?.receive();
        if (datagram == null || datagram.data.length < 8) {
          await close();
          completer.completeError('Wrong datas');
          return;
        }
        _processAnnounceResponseData(datagram.data, options, adds, completer);
      }
    }, onError: (e) async {
      await close();
      handleSocketError(e);
      if (!completer.isCompleted) completer.completeError(e);
    }, onDone: () {
      handleSocketDone();
      if (!completer.isCompleted) completer.completeError('Socket closed');
    });

    // The first step is to connect
    await _connect(options, adds, completer);
    return completer.future;
  }

  void handleSocketDone();

  void handleSocketError(e);

  /// Process the data finally obtained from the remote for a communication.
  ///
  dynamic processResponseData(
      Uint8List? data, int? action, Iterable<CompactAddress?>? addresses);

  ///
  /// When communicating with announce and scrape, after the first connection is successful, the data sent the second time is different.
  /// This method is to let subclasses implement different sending data of annouce and scrape respectively
  Uint8List? generateSecondTouchMessage(Uint8List? connectionId, Map? options);

  ///
  /// After the first connection is successful, send the second message
  Future<void> _announce(Uint8List? connectionId, Map? options,
      List<CompactAddress?>? addresses) async {
    var message = generateSecondTouchMessage(connectionId, options);
    if (message == null || message.isEmpty) {
      throw 'Send data cannot be empty';
    } else {
      _sendMessage(message, addresses);
    }
  }

  /// Process the information read from the socket.
  ///
  /// This method does not directly process the final message returned by Remote, and fixes the entire communication process.
  /// This method will handle the whole process of receiving the message after the first sending of the message, and then receiving the second message
  Future<void> _processAnnounceResponseData(Uint8List? data, Map? options,
      List<CompactAddress?>? address, Completer completer) async {
    try {
      if (!completer.isCompleted) completer.completeError('Tracker closed');
    } catch (e) {
      log(e.toString());
    }
    var view = ByteData.view(data!.buffer);
    var tid = view.getUint32(4);
    if (tid == transcationIdNum) {
      var action = view.getUint32(0);
      // Indicates that the connection is successful and can be announced
      if (action == 0) {
        _connectionId = data.sublist(8,
            16); // The 8-16th bit of the returned information is the connection id of the next connection
        await _announce(
            _connectionId, options, address); // keep going, don't stop
        return;
      }
      // An error occurred
      if (action == 3) {
        var errorMsg = 'Unknown error';
        try {
          errorMsg = String.fromCharCodes(data.sublist(8));
        } catch (e) {
          //
        }
        if (!completer.isCompleted) {
          completer.completeError(errorMsg);
        }
        await close();
        return;
      }
      // Announce get return result
      try {
        var result = processResponseData(data, action, address);
        if (!completer.isCompleted) completer.complete(result);
      } catch (e) {
        if (!completer.isCompleted) {
          completer.completeError('Response Announce Result Data error');
        }
      }
      await close();
    } else {
      if (!completer.isCompleted) {
        if (!completer.isCompleted) {
          completer.completeError('Transacation ID incorrect');
        }
      }
      await close();
    }
  }

  /// Close the connection and clear the settings
  Future? close() {
    _closed = true;
    _socket?.close();
    _socket = null;
    return null;
  }

  /// Send packets to the specified ip address
  void _sendMessage(Uint8List message, List<CompactAddress?>? addresses) {
    if (isClosed) return;
    var success = false;
    addresses?.forEach((element) {
      var bytes = _socket?.send(message, element!.address!, element.port!);
      if (bytes != 0) success = true;
    });
    if (!success) {
      Timer.run(() => _sendMessage(message, addresses));
    }
  }
}
