// ignore_for_file: constant_identifier_names, prefer_interpolation_to_compose_strings

import 'dart:typed_data';

/// The base number to use for, move right to get the number you want `&` and `|`
///
/// ie: 10000000
const BASE_NUM = 128;

class Bitfield {
  final int? piecesNum;
  final Uint8List? buffer;

  List<int>? _completedIndex;
  Bitfield(this.piecesNum, this.buffer);

  bool getBit(int index) {
    if (index < 0 || index >= piecesNum!) return false;
    var i = index ~/ 8; // Indicates the first number
    var b =
        index.remainder(8); // This indicates the number of bits in the number
    var andNum = BASE_NUM >> b;
    return ((andNum & buffer![i]) !=
        0); // Equal to 0 means that the number on the bit is 0, that is, false
  }

  /// If [index] is not in the range of [0 -piecesNum], no error will be reported, and it will return directly
  void setBit(int index, bool bit) {
    if (index < 0 || index >= piecesNum!) return;
    if (getBit(index) == bit) return;
    var i = index ~/ 8; // Indicates the first number
    var b = index.remainder(8); // This indicates the number of bits in the number
    var orNum = BASE_NUM >> b;
    if (bit) {
      _completedIndex = completedPieces;
      _completedIndex?.add(index);
      buffer![i] = buffer![i] | orNum;
    } else {
      _completedIndex?.remove(index);
      buffer![i] = buffer![i] & (~orNum);
    }
  }

  /// If there is a completed piece, it will return true, not necessarily all of them will be retrieved
  bool haveCompletePiece() {
    for (var i = 0; i < buffer!.length; i++) {
      var a = buffer![i];
      if (a != 0) {
        for (var j = 0; j < 8; j++) {
          var index = i * 8 + j;
          if (getBit(index)) return true;
        }
      }
    }
    return false;
  }

  bool haveAll() {
    for (var i = 0; i < buffer!.length - 1; i++) {
      var a = buffer![i];
      if (a != 255) {
        return false;
      }
    }
    var last = buffer!.length - 1;
    for (var j = 0; j < 8; j++) {
      var index = last * 8 + j;
      if (index >= piecesNum!) break;
      if (!getBit(index)) return false;
    }
    return true;
  }

  bool haveNone() {
    return !haveCompletePiece();
  }

  List<int>? get completedPieces {
    if (_completedIndex == null) {
      _completedIndex = <int>[];
      for (var i = 0; i < buffer!.length; i++) {
        var a = buffer![i];
        if (a != 0) {
          for (var j = 0; j < 8; j++) {
            var index = i * 8 + j;
            if (getBit(index)) {
              _completedIndex!.add(index);
            }
          }
        }
      }
    }
    return _completedIndex;
  }

  int get length => buffer!.length;

  @override
  String toString() {
    return buffer!.fold('Bitfield : ', (previousValue, element) {
      var str = element.toRadixString(2);
      var l = str.length;
      for (var i = 0; i < 8 - l; i++) {
        str = '0' + str;
      }
      return '$previousValue$str-';
    });
  }

  static Bitfield copyFrom(int piecesNum, List<int> list,
      [int offset = 0, int? end]) {
    var b = piecesNum ~/ 8;
    if (b * 8 != piecesNum) b++;
    var mybuffer = Uint8List(b);
    end ??= mybuffer.length;
    var index = 0;
    for (var i = offset; i < end; i++, index++) {
      mybuffer[index] = list[i];
    }
    return Bitfield(piecesNum, mybuffer);
  }

  static Bitfield createEmptyBitfield(int piecesNum) {
    var b = piecesNum ~/ 8;
    if (b * 8 != piecesNum) b++;
    return Bitfield(piecesNum, Uint8List(b));
  }
}
