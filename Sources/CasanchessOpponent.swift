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
private enum Tablebases {
  static var didLoad = false

  static func loadIfNeeded(into engine: CasanchessEngine) {
    guard !didLoad else {
      return
    }

    didLoad = true
    guard let path = Bundle.module.path(forResource: "syzygy", ofType: nil) else {
      return
    }

    _ = engine.loadSyzygy(path: path, probeLimit: 5)
  }
}

@MainActor
func casanchessMove(fen: String, depth: Int) async throws -> String {
  let engine = CasanchessEngine.shared
  Tablebases.loadIfNeeded(into: engine)
  engine.setPosition(fen: fen)

  for await move in engine.bestMove(depth: depth).values {
    guard let move else {
      throw EngineError.noMove
    }

    return move
  }

  throw EngineError.noMove
}
