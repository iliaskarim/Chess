import ChessCore
import Foundation

extension Move {
  /// Convenience initializer.
  /// - Parameter notation: Move notation.
  init(notation: String) throws {
    switch notation {
    case .castleLongNotation:
      self = .castle(.long)

    case .castleShortNotation:
      self = .castle(.short)

    default:
      // SAN move text: optional piece, optional disambiguation file/rank, optional "x", destination, optional "=Q".
      let pattern = "([KQRBN])?([a-h])?([1-8])?([x])?([a-h][1-8])(?:=([QRBN]))?$"
      let regex = try! NSRegularExpression(pattern: pattern)
      let searchRange = NSRange(notation.startIndex..., in: notation)
      guard let match = regex.firstMatch(in: notation, range: searchRange) else {
        throw NotationError.unparseable
      }

      // Group 1: moving piece letter; omitted means pawn.
      let figure = (Range(match.range(at: 1), in: notation).flatMap { captureRange in
        Piece.Figure(String(notation[captureRange]).first!)
      }) ?? .pawn

      // Group 2: disambiguation file when two pieces could reach the square (e.g. "Nbd2").
      let squareFile = Range(match.range(at: 2), in: notation).flatMap { captureRange in
        Square.File(String(notation[captureRange]).first!)
      }

      // Group 3: disambiguation rank (e.g. "R1e2").
      let squareRank = Range(match.range(at: 3), in: notation).flatMap { captureRange in
        Square.Rank(String(notation[captureRange]).first!)
      }

      // Group 4: presence of "x" marks a capture.
      let captureXRange = Range(match.range(at: 4), in: notation)
      let isCapture = captureXRange != nil

      // Group 5: destination square (required).
      guard let targetSquareRange = Range(match.range(at: 5), in: notation),
            let targetSquare = Square(notation: String(notation[targetSquareRange]))
      else {
        throw NotationError.unparseable
      }

      // Group 6: promotion piece after "=" (e.g. "=Q").
      let promotion = Range(match.range(at: 6), in: notation).flatMap { captureRange in
        Piece.Figure(rawValue: String(notation[captureRange]))
      }

      self = .translation(.init(
        figure: figure,
        isCapture: isCapture,
        promotion: promotion,
        disambiguationFile: squareFile,
        disambiguationRank: squareRank,
        targetSquare: targetSquare
      ))
    }
  }
}
