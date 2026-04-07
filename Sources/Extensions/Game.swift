import ChessCore

extension Game {
  func play(_ notation: String) throws {
    switch notation {
    case .whiteVictoryNotation:
      try endGame(victor: .white)

    case .blackVictoryNotation:
      try endGame(victor: .black)

    case .drawNotation:
      try endGame(victor: nil)

    default:
      var notation = notation

      let last = notation.last
      let isCheck = last == "+"
      let isCheckmate = last == "#"

      if isCheck || isCheckmate {
        notation = String(notation.dropLast())
      }

      try play(.init(notation: notation))

      let (actualCheck, actualCheckmate): (Bool, Bool) = switch board.status {
      case .check?:
        (true, false)

      case .checkmate?:
        (false, true)

      case .stalemate?, nil:
        (false, false)
      }

      if isCheck != actualCheck || isCheckmate != actualCheckmate {
        print("Punctuation was corrected to match the position.")
      }
    }
  }
}
