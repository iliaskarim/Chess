# Chess

An example of how to implement [ChessCore](https://github.com/iliaskarim/ChessCore) as a command-line game.

## Requirements

- Swift 6+
- macOS 14+

## Quick start

```bash
swift run
```

Type each move in standard algebraic notation at the `?` prompt.

Play White against [Casanchess](https://github.com/iliaskarim/CasanchessSwift) at a fixed search depth:

```bash
swift run Chess --casanchess 4
```

Add `--black` to take Black. Casanchess plays White:

```bash
swift run Chess --casanchess 4 --black
```

Start from a FEN. Quote the string:

```bash
swift run Chess --fen '8/8/8/2p5/k7/8/2N5/KN6 w - - 0 1' --casanchess 5 --black
```

## Syzygy tablebases

Casanchess probes 3-5 piece Syzygy WDL files during search. Those files are large, so they are not in git. After a checkout, download them into `Sources/syzygy/`:

```bash
cd Sources/syzygy
base=https://tablebase.lichess.ovh/tables/standard/3-4-5-wdl
curl -fsSL "$base/" \
  | sed -n 's/.*href="\([^"]*\.rtbw\)".*/\1/p' \
  | xargs -I{} curl -fL -O "$base/{}"
```

The next `swift build` or `swift run` copies every `.rtbw` file in that directory into the app bundle. DTZ files (`.rtbz`) are not used. Without the WDL files, Casanchess still plays, and endgames are evaluated by the network alone.

## Example output

Scholar's mate:

```text
White to move.

8 r n b q k b n r
7 p p p p p p p p
6                
5                
4                
3                
2 P P P P P P P P
1 R N B Q K B N R
  a b c d e f g h

? f3
1. f3

Black to move.

8 r n b q k b n r
7 p p p p p p p p
6                
5                
4                
3           P    
2 P P P P P   P P
1 R N B Q K B N R
  a b c d e f g h

? e6
1. f3 e6

White to move.

8 r n b q k b n r
7 p p p p   p p p
6         p      
5                
4                
3           P    
2 P P P P P   P P
1 R N B Q K B N R
  a b c d e f g h

? g4
1. f3 e6
2. g4

Black to move.

8 r n b q k b n r
7 p p p p   p p p
6         p      
5                
4             P  
3           P    
2 P P P P P     P
1 R N B Q K B N R
  a b c d e f g h

? Qh4#
1. f3 e6
2. g4 Qh4#

Black wins.

8 r n b   k b n r
7 p p p p   p p p
6         p      
5                
4             P q
3           P    
2 P P P P P     P
1 R N B Q K B N R
  a b c d e f g h
```
