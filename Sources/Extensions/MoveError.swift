import ChessCore
import Foundation

extension MoveError: @retroactive LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .ambiguousMove(let candidates):
      let n = candidates.count
      let moveWord = n == 1 ? "move" : "moves"
      let candidatesDescription = candidates.map(\.description).sorted().joined(separator: ", ")
      return "This notation matches \(n) legal \(moveWord): \(candidatesDescription)."

    case .illegalMove:
      return "That move is not legal in this position."
    }
  }
}
