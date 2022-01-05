//
//  CardFace.swift
//  SetGame
//
//  Created by macbook on 03/09/2021.
//

import SwiftUI

struct CardFace<ItemView>: View where ItemView: Shape {
    var color: Color
    let shape: ItemView
    let numberOfShapes: ClosedRange<Int>
    let shapeType: SetModel.CardShape
    let shading: SetModel.CardShading
    
    init(card: SetModel.Card) {
        switch card.color {
        case .red:
            color = Color.red
        case .blue:
            color = Color.blue
        case .green:
            color = Color.green
        }
        
        switch card.shape {
        case .diamond:
            shape = Diamond() as! ItemView
        case .squiggle:
            shape = Rectangle() as! ItemView
        case .oval:
            shape = Ellipse() as! ItemView
        }
        
        if (card.shading == .striped) {
            color = color.opacity(0.6)
        }
        
        numberOfShapes = 1...card.numberOfShapes.rawValue
        shapeType = card.shape
        shading = card.shading
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                ForEach(numberOfShapes, id: \.self) { shapeNumber in
                    if (shading == .open) {
                        shape
                            .stroke(lineWidth: 2.0)
                            .aspectRatio(2, contentMode: .fit)
                    } else {
                        shape.aspectRatio(2, contentMode: .fit)
                    }
                }
                Spacer()
            }
            .padding()
            .foregroundColor(color)
            
        }
    }
    
}
