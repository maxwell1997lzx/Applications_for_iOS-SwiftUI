//
//  SetGame.swift
//  SetGame
//
//  Created by macbook on 03/09/2021.
//

import SwiftUI

class SetGame: ObservableObject {
    typealias Card = SetModel.Card
    
    init() {
        model = SetGame.createMemoryGame()
    }
    
    private static func createMemoryGame() -> SetModel {
        return SetModel()
    }
    
    @Published private var model: SetModel
    
    var cards: Array<Card> {
        model.getCards()
    }
    
    var cardsInGame: Int {
        model.cardsInGame
    }
    
    // MARK: - Intent(s)
    
    func choose(_ card: Card) {
        model.choose(card)
    }
    
    func dealThreeMore() {
        model.dealThreeMore()
    }
    
    func restart() {
        model = SetGame.createMemoryGame()
    }
}
