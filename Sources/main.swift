// The Swift Programming Language
// https://docs.swift.org/swift-book
import ChessCore

var game = Game()
print(game)

while !game.isGameOver {
  print("\n?", terminator: " ")
  guard let line = readLine() else { continue }
  do {
    try game.move(line)
    print(game)
  } catch {
    print(error.localizedDescription)
  }
}
