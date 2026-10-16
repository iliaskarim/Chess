import ChessCore
import Foundation

extension AnyMove {
  /// Creates a move from castling notation or standard algebraic notation.
  /// - Parameter notation: Move notation, without a check or checkmate suffix.
  init(notation: String) throws {
    switch notation {
    case Castling.queenside.rawValue:
      self.init(Castling.queenside)

    case Castling.kingside.rawValue:
      self.init(Castling.kingside)

    default:
      try self.init(Translation(notation: notation))
    }
  }

  /// Creates the legal move described by a UCI string such as `e2e4` or `e7e8q`.
  init(uci: String, on board: Board) throws {
    guard (4 ... 5).contains(uci.count),
          let origin = Square(notation: String(uci.prefix(2))),
          let target = Square(notation: String(uci.dropFirst(2).prefix(2))) else {
      throw NotationError.unparseable
    }

    let promotion = try Self.promotion(in: uci)
    let matches = (board.moves(from: origin)[target] ?? []).filter { move in
      move.promotion == promotion
    }

    guard matches.count == 1, let legal = matches.first else {
      throw matches.isEmpty ? MoveError.illegalMove : MoveError.ambiguousMove(candidates: matches)
    }

    if legal.figure == .king,
       origin.file == .e,
       origin.rank == target.rank,
       target.file == .g || target.file == .c {
      self.init(target.file == .g ? Castling.kingside : Castling.queenside)
      return
    }

    self.init(Translation(
      figure: legal.figure,
      targetSquare: target,
      isCapture: legal.isCapture,
      promotion: legal.promotion,
      disambiguationFile: Self.disambiguationFile(for: legal, from: origin, to: target, on: board),
      disambiguationRank: Self.disambiguationRank(for: legal, from: origin, to: target, on: board)
    ))
  }

  private static func disambiguationFile(
    for legal: AnyMove,
    from origin: Square,
    to target: Square,
    on board: Board
  ) -> Square.File? {
    if legal.figure == .pawn, legal.isCapture {
      return origin.file
    }

    let others = otherMoves(matching: legal, from: origin, to: target, on: board)
    guard !others.isEmpty else {
      return nil
    }

    if others.allSatisfy({ $0.disambiguationFile != origin.file }) ||
      !others.allSatisfy({ $0.disambiguationRank != origin.rank }) {
      return origin.file
    }

    return nil
  }

  private static func disambiguationRank(
    for legal: AnyMove,
    from origin: Square,
    to target: Square,
    on board: Board
  ) -> Square.Rank? {
    let others = otherMoves(matching: legal, from: origin, to: target, on: board)
    guard !others.isEmpty,
          !others.allSatisfy({ $0.disambiguationFile != origin.file }) else {
      return nil
    }

    return origin.rank
  }

  private static func otherMoves(
    matching legal: AnyMove,
    from origin: Square,
    to target: Square,
    on board: Board
  ) -> [AnyMove] {
    board.flatMap { square, _ in
      (board.moves(from: square)[target] ?? []).filter { move in
        move.figure == legal.figure
          && move.isCapture == legal.isCapture
          && move.promotion == legal.promotion
          && (move.disambiguationFile != origin.file || move.disambiguationRank != origin.rank)
      }
    }
  }

  private static func promotion(in uci: String) throws -> Piece.Figure? {
    guard uci.count == 5 else {
      return nil
    }

    guard let figure = Piece.Figure(rawValue: String(uci.suffix(1)).uppercased()) else {
      throw NotationError.unparseable
    }

    return figure
  }
}

extension Translation {
  /// Creates a non-castling move from standard algebraic notation.
  /// - Parameter notation: SAN text such as `e4`, `Nf3`, or `exd5`.
  init(notation: String) throws {
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

    // SAN requires a pawn capture to include the source file (e.g. "exd5", not "xd5").
    if figure == .pawn, isCapture, squareFile == nil {
      throw NotationError.unparseable
    }

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

    self.init(
      figure: figure,
      targetSquare: targetSquare,
      isCapture: isCapture,
      promotion: promotion,
      disambiguationFile: squareFile,
      disambiguationRank: squareRank
    )
  }
}
