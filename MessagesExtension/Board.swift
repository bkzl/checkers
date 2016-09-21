//
//  Board.swift
//  Checkers
//
//  Created by bkzl on 26/08/16.
//  Copyright © 2016 bkzl. All rights reserved.
//

import Messages

class Board {
    private var pieces: Array2D<Piece>!
    private var _setup: String!

    var setup: String {
        get {
            return _setup
        }

        set {
            setUpBoard(with: newValue)
            _setup = newValue
        }
    }
    var setupValue: String {
        var setup: [String] = []
        for row in 0..<Settings.boardSize.dimension {
            for column in 0..<Settings.boardSize.dimension {
                if let piece = pieces[column, row] {
                    setup.append("\(piece.symbol)\(piece.column)\(piece.row)")
                }
            }
        }
        return setup.joined(separator: ",")
    }

    var size: BoardSize {
        get {
            return Settings.boardSize
        }

        set {
            Settings.boardSize = newValue
        }
    }
    var sizeValue: String {
        switch size {
        case .small:
            return BoardSize.small.symbol
        case .large:
            return BoardSize.large.symbol
        }
    }

    var activePieceSet = PieceSet.white
    var activePieceSetValue: String {
        switch activePieceSet {
        case .white:
            return PieceSet.red.symbol
        case .red:
            return PieceSet.white.symbol
        }
    }

    func pieceAt(column: Int, row: Int) -> Piece? {
        guard column >= 0 && column < Settings.boardSize.dimension else { return nil }
        guard row >= 0 && row < Settings.boardSize.dimension else { return nil }

        return pieces[column, row]
    }

    func isPieceAt(column: Int, row: Int) -> Bool {
        return pieceAt(column: column, row: row) != nil
    }

    func move(piece: Piece, to: (column: Int, row: Int)) {
        pieces[piece.column, piece.row] = nil
        piece.column = to.column
        piece.row = to.row
        pieces[to.column, to.row] = piece
    }

    func capture(piece: Piece) {
        pieces[piece.column, piece.row] = nil
    }

    init(message: MSMessage?) {
        guard let message = message, let url = message.url else {
            setup = Settings.boardSize.newGameSetup
            return
        }

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            for item in components.queryItems! {
                if item.name == "board" {
                    setup = item.value!
                    continue
                }

                if item.name == "size" {
                    size = BoardSize.symbol(item.value!)!
                    continue
                }

                if item.name == "set" {
                    activePieceSet = PieceSet.symbol(item.value!)!
                }
            }
        }
    }

    private func setUpBoard(with setup: String) {
        pieces = Array2D<Piece>(columns: Settings.boardSize.dimension, rows: Settings.boardSize.dimension)

        for piece in setup.components(separatedBy: ",") {
            let characters = Array(piece.characters)
            let pieceType = PieceType.symbol(String(characters[0]))!
            let pieceSet = PieceSet.symbol(String(characters[1]))!
            let column = Int(String(characters[2]))!
            let row = Int(String(characters[3]))!

            pieces[column, row] = Piece(column: column, row: row, pieceType: pieceType, pieceSet: pieceSet)
        }
    }
}
