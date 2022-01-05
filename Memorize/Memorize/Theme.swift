//
//  Theme.swift
//  Memorize
//
//  Created by macbook on 01/09/2021.
//

import Foundation

struct Theme: Identifiable, Codable, Hashable, Equatable {
    var name: String
    var emojis: [String]
    var numberOfPairs: Int
    var color: RGBAColor
    var id: Int
    
    init(name: String, emojis: [String], numberOfPairs: Int, color: RGBAColor, id: Int) {
        self.name = name
        self.emojis = Array(Set(emojis)).shuffled()
        self.numberOfPairs = min(numberOfPairs, emojis.count-1)
        self.color = color
        self.id = id
    }
}
