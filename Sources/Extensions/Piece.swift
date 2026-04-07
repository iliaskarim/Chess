import ChessCore
import Foundation

extension Piece.Figure {
  /// Creates a figure from a single uppercase letter `R`, `N`, `B`, `Q`, or
  /// `K`.
  ///
  /// Returns `nil` if `character` is not one of `R`, `N`, `B`, `Q`, or `K`.
  init?(_ character: Character) {
    self.init(rawValue: String(character))
  }
}
