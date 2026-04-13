import Foundation

enum NotationError: Error, LocalizedError {
  case unparseable

  var errorDescription: String? {
    switch self {
    case .unparseable:
      return "Could not parse move notation. Use castling (O-O or O-O-O) or standard algebraic notation (SAN), e.g. e4, Nf3, exd5."
    }
  }
}
