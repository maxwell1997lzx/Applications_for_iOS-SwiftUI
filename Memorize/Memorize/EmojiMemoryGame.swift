//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by macbook on 25/07/2021.
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    typealias Card = MemoryGame<String>.Card
    
    var theme: Theme {
        didSet {
            restart()
        }
    }
    
    init(theme: Theme) {
        self.theme = theme
        if let url = Autosave.url, let autosavedMemoryGame = try? MemoryGame<String>(url: url) {
            model = autosavedMemoryGame
        } else {
            model = EmojiMemoryGame.createMemoryGame(theme)
        }
    }
    
    
    // MARK: - Autosave
    
    private var autosaveTimer: Timer?
    
    private func scheduleAutosave() {
        autosaveTimer?.invalidate()
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.coalescingInterval, repeats: false) { _ in
            self.autosave()
        }
    }
    
    private struct Autosave {
        static let filename = "Autosaved.memorize"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(filename)
        }
        static let coalescingInterval = 5.0
    }
    
    private func autosave() {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    
    private func save(to url: URL) {
        let thisfunction = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try model.json()
            try data.write(to: url)
        } catch let encodingError where encodingError is EncodingError {
            print("\(thisfunction) couldn't encode Memorize as JSON because \(encodingError.localizedDescription)")
        } catch {
            print("\(thisfunction) error = \(error)")
        }
    }
    
    // MARK: - Game
    
    private static func createMemoryGame(_ theme: Theme) -> MemoryGame<String> {
        return MemoryGame<String>(numberOfPairsOfCards: theme.numberOfPairs) { pairIndex in
            theme.emojis[pairIndex]
        }
    }
    
    @Published private var model: MemoryGame<String> {
        didSet {
            scheduleAutosave()
        }
    }
    
    var cards: Array<Card> {
        model.cards
    }
    
    var score: Int {
        model.score
    }
    
    // MARK: - Intent(s)
    
    func choose(_ card: Card) {
        model.choose(card)
    }
    
    func shuffle() {
        model.shuffle()
    }
    
    func restart() {
        model = EmojiMemoryGame.createMemoryGame(theme)
    }
}
