import ChessCore
import Foundation

extension Square {
  /// Creates a square from algebraic notation (for example `"e4"`).
  ///
  /// - Parameter notation: Exactly two characters: a file letter `a`–`h` and a
  ///   rank digit `1`–`8`.
  /// - Returns: `nil` if `notation` is not valid square notation.
  init?(notation: String) {
    guard notation.count == 2,
          let file = notation.first.flatMap(File.init),
          let rank = notation.last.flatMap(Rank.init)
    else {
      return nil
    }

    self.init(file: file, rank: rank)
  }
}

extension Square.File {
  /// Creates a file from a single character.
  /// - Parameter character: A lowercase letter `a` through `h`.
  /// - Returns: `nil` if `character` is not a valid file letter.
  init?(_ character: Character) {
    guard let ascii = character.asciiValue else {
      return nil
    }

    self.init(rawValue: Int(ascii) - 96)
  }
}

extension Square.Rank {
  /// Creates a rank from a single character.
  /// - Parameter character: A digit `1` through `8`.
  /// - Returns: `nil` if `character` is not a valid rank digit.
  init?(_ character: Character) {
    guard let int = Int(String(character)) else {
      return nil
    }

    self.init(rawValue: int)
  }
}
