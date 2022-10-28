import 'dart:async';
import '../../model/torrent.dart';
import '../peer/bitfield.dart';
import 'piece.dart';
import 'piece_provider.dart';
import 'piece_selector.dart';

typedef PieceCompleteHandle = void Function(int pieceIndex);

class PieceManager implements PieceProvider {
  bool _isFirst = true;

  final Map<int, Piece> _pieces = {};

  // final Set<int> _completedPieces = <int>{};

  final List<PieceCompleteHandle> _pieceCompleteHandles = [];

  final Set<int> _donwloadingPieces = <int>{};

  final PieceSelector _pieceSelector;

  PieceManager(this._pieceSelector, int piecesNumber);

  static PieceManager createPieceManager(
      PieceSelector pieceSelector, Torrent metaInfo, Bitfield bitfield) {
    var p = PieceManager(pieceSelector, metaInfo.pieces.length);
    p.initPieces(metaInfo, bitfield);
    return p;
  }

  void initPieces(Torrent metaInfo, Bitfield bitfield) {
    for (var i = 0; i < metaInfo.pieces.length; i++) {
      var byteLength = metaInfo.pieceLength;
      if (i == metaInfo.pieces.length - 1) {
        byteLength = metaInfo.lastPriceLength;
      }
      var piece = Piece(metaInfo.pieces[i], i, byteLength);
      if (!bitfield.getBit(i)) _pieces[i] = piece;
    }
  }

  void onPieceComplete(PieceCompleteHandle handle) {
    _pieceCompleteHandles.add(handle);
  }

  void offPieceComplete(PieceCompleteHandle handle) {
    _pieceCompleteHandles.remove(handle);
  }

  /// This interface is used for FIleManager callbacks.
  ///
  /// The Piece is considered complete only when all sub Pieces have been written.
  ///
  /// Because if you modify the bitfield only after the download is complete, it will cause the child piece requested by the other party to not be there after you send have to the other party.
  /// In the file system, the wrong data will be read
  void processSubPieceWriteComplete(int pieceIndex, int begin, int length) {
    var piece = _pieces[pieceIndex];
    if (piece != null) {
      piece.subPieceWriteComplete(begin);
      if (piece.isCompleted) _processCompletePiece(pieceIndex);
    }
  }

  Piece? selectPiece(String? remotePeerId, List<int>? remoteHavePieces,
      PieceProvider? provider, final Set<int>? suggestPieces) {
    // Check whether the peer can be used in the currently downloaded piece
    var avalidatePiece = <int>[];
    // Download Suggest Pieces first
    if (suggestPieces != null && suggestPieces.isNotEmpty) {
      for (var i = 0; i < suggestPieces.length; i++) {
        var p = _pieces[suggestPieces.elementAt(i)];
        if (p != null && p.haveAvalidateSubPiece()) {
          processDownloadingPiece(p.index!);
          return p;
        }
      }
    }
    var candidatePieces = remoteHavePieces;
    for (var i = 0; i < _donwloadingPieces.length; i++) {
      var p = _pieces[_donwloadingPieces.elementAt(i)];
      if (p == null) continue;
      if (p.containsAvalidatePeer(remotePeerId!) && p.haveAvalidateSubPiece()) {
        avalidatePiece.add(p.index!);
      }
    }

    // If the piece being downloaded can be downloaded, download the piece (the principle that multiple peers download a piece at the same time to make it complete as soon as possible)
    if (avalidatePiece.isNotEmpty) {
      candidatePieces = avalidatePiece;
    }
    var piece = _pieceSelector.selectPiece(
        remotePeerId!, candidatePieces, this, _isFirst);
    _isFirst = false;
    if (piece == null) return null;
    processDownloadingPiece(piece.index!);
    return piece;
  }

  void processDownloadingPiece(int pieceIndex) {
    _donwloadingPieces.add(pieceIndex);
  }

  /// The finished Piece needs some processing
  /// -removed from `_pieces` list
  /// -removed from `_downloadingPieces` list
  /// -notification listener
  void _processCompletePiece(int index) {
    var piece = _pieces.remove(index);
    _donwloadingPieces.remove(index);
    if (piece != null) {
      piece.dispose();
      for (var handle in _pieceCompleteHandles) {
        Timer.run(() => handle(index));
      }
    }
  }

  bool _disposed = false;

  bool get isDisposed => _disposed;

  void dispose() {
    if (isDisposed) return;
    _disposed = true;
    _pieces.forEach((key, value) {
      value.dispose();
    });
    _pieces.clear();
    _pieceCompleteHandles.clear();
    _donwloadingPieces.clear();
  }

  @override
  Piece? operator [](index) {
    return _pieces[index];
  }

  // @override
  // Piece getPiece(int index) {
  //   return _pieces[index];
  // }

  @override
  int get length => _pieces.length;
}
