// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import '../../../dartorrent_common/dartorrent_common.dart';

/// 第一次连接的时候，connection id是自己设置的，所有文档都提到使用该数字，说它是个magic number
const START_CONNECTION_ID_NUMER = 0x41727101980;

/// 连接起始的connection id，是个固定值 0x41727101980
const START_CONNECTION_ID = [0, 0, 4, 23, 39, 16, 25, 128];
const ACTION_CONNECT = [0, 0, 0, 0];
const ACTION_ANNOUNCE = [0, 0, 0, 1];
const ACTION_SCRAPE = [0, 0, 0, 2];
const ACTION_ERROR = [0, 0, 0, 3];

/// 套接字接收消息的超时时间，15秒
const TIME_OUT = Duration(seconds: 15);

const EVENTS = <String, int>{'completed': 1, 'started': 2, 'stopped': 3};

///
/// announce和scrapt的访问步骤完全一致，只是发送和返回数据不同，所以这里做一个mixin，
/// 具有UDP连接到host的功能，tracker和scrapter各自实现需要发送数据以及处理返回数据即可
mixin UDPTrackerBase {
  /// UDP 套接字。
  ///
  /// 基本上一次连接-响应过后就会被关闭。第二次连接再创建新的
  RawDatagramSocket? _socket;

  /// 会话ID。长度为4的一组bytebuffer，随机生成的
  List<int>? _transcationId;

  /// 连接ID。在第一次发送消息到remote后，remote会返回一个connection id，第二次发送消息
  /// 需要携带该ID
  Uint8List? _connectionId;

  /// 远程URL
  // Uri get uri;

  Future<List<CompactAddress>?>? get addresses;

  bool _closed = false;

  bool get isClosed => _closed;

  /// 获取当前transcation id，如果有就返回，表示当前通信还未完结。如果没有就重新生成
  List<int>? get transcationId {
    _transcationId ??= _generateTranscationId();
    return _transcationId;
  }

  /// 将trancation id 转成数字
  int get transcationIdNum {
    return ByteData.view(Uint8List.fromList(transcationId!).buffer)
        .getUint32(0);
  }

  /// 生成一个随机4字节的bytebuffer
  List<int> _generateTranscationId() {
    return randomBytes(4);
  }

  int maxConnectRetryTimes = 3;

  /// 与Remote通讯的第一次连接
  ///
  /// Announce 和 Scrape通讯的时候，都必须要走这第一步，是固定的。
  ///
  /// 参数completer是一个`Completer`实例。用于截获发生的异常，并通过completeError截获
  void _connect(
      Map options, List<CompactAddress> address, Completer completer) async {
    if (isClosed) {
      if (!completer.isCompleted) completer.completeError('Tracker closed');
      return;
    }
    var list = <int>[];
    list.addAll(START_CONNECTION_ID); //这是个magic id
    list.addAll(ACTION_CONNECT);
    list.addAll(transcationId!);
    var messageBytes = Uint8List.fromList(list);
    try {
      _sendMessage(messageBytes, address);
      return;
    } catch (e) {
      if (!completer.isCompleted) completer.completeError(e);
      await close();
    }
  }

  /// 和Remote通信的入口函数。返回一个Future
  Future<T?> contactAnnouncer<T>(Map options) async {
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

    // 第一步，连接对方
    _connect(options, adds, completer);
    return completer.future;
  }

  void handleSocketDone();

  void handleSocketError(e);

  /// 处理一次通信最终从remote获得的数据.
  ///
  dynamic processResponseData(
      Uint8List data, int action, Iterable<CompactAddress> addresses);

  ///
  /// 与announce和scrape通信的时候，在第一次连接成功后，第二次发送的数据是不同的。
  /// 这个方法就是让子类分别实现annouce和scrape不同的发送数据
  Uint8List? generateSecondTouchMessage(Uint8List? connectionId, Map options);

  ///
  /// 第一次连接成功后，发送第二次信息
  void _announce(Uint8List? connectionId, Map options,
      List<CompactAddress> addresses) async {
    var message = generateSecondTouchMessage(connectionId, options);
    if (message == null || message.isEmpty) {
      throw '发送数据不能为空';
    } else {
      _sendMessage(message, addresses);
    }
  }

  /// 处理从套接字处读出到的信息。
  ///
  /// 该方法并不会直接去处理Remote返回的最终消息，而且固定了整个通信流程。
  /// 该方法会去处理在第一次发送信息后收到消息，然后到接收到第二次消息的整个过程
  void _processAnnounceResponseData(Uint8List data, Map options,
      List<CompactAddress> address, Completer completer) async {
    if (isClosed) {
      if (!completer.isCompleted) completer.completeError('Tracker Closed');
      return;
    }
    var view = ByteData.view(data.buffer);
    var tid = view.getUint32(4);
    if (tid == transcationIdNum) {
      var action = view.getUint32(0);
      // 表明连接成功，可以进行announce
      if (action == 0) {
        _connectionId = data.sublist(8, 16); // 返回信息的第8-16位是下次连接的connection id
        _announce(_connectionId, options, address); // 继续，不要停
        return;
      }
      // 发生错误
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
      // announce获得返回结果
      try {
        var result = processResponseData(data, action, address);
        completer.complete(result);
      } catch (e) {
        completer.completeError('Response Announce Result Data error');
      }
      await close();
    } else {
      if (!completer.isCompleted) {
        completer.completeError('Transacation ID incorrect');
      }
      await close();
    }
  }

  /// 关闭连接以及清楚设置
  Future? close() {
    _closed = true;
    _socket?.close();
    _socket = null;
    return null;
  }

  /// 发送数据包到指定的ip地址
  void _sendMessage(Uint8List message, List<CompactAddress> addresses) {
    if (isClosed) return;
    var success = false;
    for (var element in addresses) {
      var bytes = _socket?.send(message, element.address!, element.port!);
      if (bytes != 0) success = true;
    }
    if (!success) {
      Timer.run(() => _sendMessage(message, addresses));
    }
  }
}
