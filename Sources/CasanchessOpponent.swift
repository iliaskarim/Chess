import Casanchess
import Combine
import Foundation

enum EngineError: Error, LocalizedError {
  case noMove

  var errorDescription: String? {
    switch self {
    case .noMove:
      "Casanchess did not return a move."
    }
  }
}

@MainActor
func casanchessMove(fen: String, depth: Int) async throws -> String {
  let engine = CasanchessEngine.shared
  engine.setPosition(fen: fen)

  for await move in engine.bestMove(depth: depth).values {
    guard let move else {
      throw EngineError.noMove
    }

    return move
  }

  throw EngineError.noMove
}
