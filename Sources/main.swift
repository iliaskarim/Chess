// The Swift Programming Language
// https://docs.swift.org/swift-book
import ChessCore
import Darwin

var game = Game()
print(game)

while case .toMove = game.status {
  print("\n?", terminator: " ")
  guard let line = readLine() else {
    continue
  }

  do {
    try game.play(line)
    print(game)
  } catch {
    fputs("\u{7}", stderr)
    print(error.localizedDescription)
  }
}
