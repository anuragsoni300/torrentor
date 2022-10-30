import 'piece.dart';
import 'piece_provider.dart';

/// Piece selector.
///
/// When the client starts downloading, select the appropriate Piece to download through this class
abstract class PieceSelector {
  /// Choose the appropriate Piece should Peer download.
  ///
  /// [remotePeerId] is the identifier of the `Peer` to be downloaded. This identifier is not necessarily the `peer_id` in the protocol.
  /// Rather, it is the identifier that distinguishes `Peer` in the `Piece` class.
  /// This method obtains the corresponding `Piece` object through [provider] and [piecesIndexList], and stores it in [piecesIndexList]
  /// Filter the collection.
  ///
  Piece? selectPiece(
      String? remotePeerId, List<int>? piecesIndexList, PieceProvider? provider,
      [bool first = false]);
}
