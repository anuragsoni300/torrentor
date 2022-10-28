import '../../dartorrent_common_base.dart';
import 'piece.dart';
import 'piece_provider.dart';
import 'piece_selector.dart';

///
/// `Piece` base selector.
///
/// The basic strategy is:
///
/// -`Piece` has the highest number of `Peers` available
/// -In the case of the same number of `Peers` available, choose the one with the least number of `Sub Pieces`
class BasePieceSelector implements PieceSelector {
  @override
  Piece? selectPiece(
      String? remotePeerId, List<int>? piecesIndexList, PieceProvider? provider,
      [bool random = false]) {
    // random = true;
    var maxList = <Piece>[];
    dynamic a;
    dynamic startIndex;
    for (var i = 0; i < piecesIndexList!.length; i++) {
      var p = provider?[piecesIndexList[i]];
      if (p != null &&
          p.haveAvalidateSubPiece() &&
          p.containsAvalidatePeer(remotePeerId!)) {
        a = p;
        startIndex = i;
        break;
      }
    }
    if (startIndex == null) return null;
    maxList.add(a);
    for (var i = startIndex; i < piecesIndexList.length; i++) {
      var p = provider?[piecesIndexList[i]];
      if (p == null ||
          !p.haveAvalidateSubPiece() ||
          !p.containsAvalidatePeer(remotePeerId!)) {
        continue;
      }
      // Choose a rare piece
      if (a.avalidatePeersCount > p.avalidatePeersCount) {
        if (!random) return p;
        maxList.clear();
        a = p;
        maxList.add(a);
      } else {
        if (a.avalidatePeersCount == p.avalidatePeersCount) {
          // If the same number of downloadable peer pieces have fewer sub pieces, priority will be given to processing
          if (p.avalidateSubPieceCount < a.avalidateSubPieceCount) {
            if (!random) return p;
            maxList.clear();
            a = p;
            maxList.add(a);
          } else {
            if (p.avalidateSubPieceCount == a.avalidateSubPieceCount) {
              if (!random) return p;
              maxList.add(p);
              a = p;
            }
          }
        }
      }
    }
    if (random) {
      return maxList[randomInt(maxList.length)];
    }
    return a;
  }
}
