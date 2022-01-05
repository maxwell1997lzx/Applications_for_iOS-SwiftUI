//
//  SetGameApp.swift
//  SetGame
//
//  Created by macbook on 03/09/2021.
//

import SwiftUI

@main
struct SetGameApp: App {
    private let game = SetGame()
    var body: some Scene {
        WindowGroup {
            SetGameView(game: game)
        }
    }
}
