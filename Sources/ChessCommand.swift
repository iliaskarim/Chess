import ChessCore
import Darwin
import Foundation

private let usage = """
Usage: Chess [--casanchess <depth>] [--black]

Type each move in standard algebraic notation at the ? prompt.
--casanchess <depth>  Play against Casanchess. <depth> is the search depth, 1 or more.
--black               Play Black. Casanchess plays White and moves first.
"""

private struct UsageError: Error, LocalizedError {
  var errorDescription: String? {
    usage
  }
}

private struct Options {
  var engineDepth: Int?
  var humanColor: Piece.Color

  init(arguments: [String]) throws {
    var engineDepth: Int?
    var humanColor: Piece.Color = .white
    var index = arguments.startIndex

    while index < arguments.endIndex {
      let argument = arguments[index]
      index += 1

      switch argument {
      case "--help", "-h":
        throw UsageError()

      case "--casanchess":
        guard engineDepth == nil,
              index < arguments.endIndex,
              let depth = Int(arguments[index]),
              depth > 0 else {
          throw UsageError()
        }

        engineDepth = depth
        index += 1

      case "--black":
        humanColor = .black

      default:
        throw UsageError()
      }
    }

    if humanColor == .black, engineDepth == nil {
      throw UsageError()
    }

    self.engineDepth = engineDepth
    self.humanColor = humanColor
  }
}

@main
@MainActor
enum ChessCommand {
  static func main() async {
    let options: Options
    do {
      options = try Options(arguments: Array(CommandLine.arguments.dropFirst()))
    } catch {
      fputs("\(error.localizedDescription)\n", stderr)
      Darwin.exit(1)
    }

    let game = Game()
    print(game)

    while case let .toMove(side) = game.status {
      if let depth = options.engineDepth, side != options.humanColor {
        do {
          try await playCasanchessMove(depth: depth, in: game)
        } catch {
          fputs("\u{7}", stderr)
          print(error.localizedDescription)
          return
        }

        continue
      }

      print("\n?", terminator: " ")
      fflush(stdout)
      guard let line = readLine() else {
        return
      }

      do {
        try game.play(line)
        print(game)
      } catch {
        fputs("\u{7}", stderr)
        print(error.localizedDescription)
      }
    }
  }

  private static func playCasanchessMove(depth: Int, in game: Game) async throws {
    let uci = try await casanchessMove(fen: game.board.fen, depth: depth)
    try game.play(AnyMove(uci: uci, on: game.board))
    print(game)
  }
}
