//
//  SetGameView.swift
//  SetGame
//
//  Created by macbook on 03/09/2021.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject var game: SetGame
    
    @Namespace private var dealingNamespace
    @Namespace private var undealingNamespace
    
    var body: some View {
        VStack {
            VStack {
                gameBody
            }
            HStack {
                startDeckBody
                Spacer()
                discardedDeckBody
            }
            restart
        }
        .padding()
    }
    
    var gameBody: some View {
        AspectVGrid(items: game.cards.filter({ $0.inGame && !isUndealt($0) }), aspectRatio: 2/3) { card in
            CardView(card: card)
                .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                .matchedGeometryEffect(id: card.id, in: undealingNamespace)
                .padding(4)
                .onTapGesture {
                    withAnimation {
                        game.choose(card)
                    }
                }.foregroundColor(.blue)
            
        }
    }
    
    var discardedDeckBody: some View {
        ZStack {
            ForEach(game.cards.filter({ !$0.inGame && !isUndealt($0) })) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: undealingNamespace)
                    .zIndex(zIndex(of: card))
            }
        }
        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
        .foregroundColor(.blue)
    }
    
    var startDeckBody: some View {
        ZStack {
            ForEach(game.cards.filter({ !$0.inGame && isUndealt($0) })) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .zIndex(zIndex(of: card))
            }
        }
        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
        .foregroundColor(.blue)
        .onTapGesture {
            // "deal" cards
            withAnimation {
                
                if dealt != [] {
                    game.dealThreeMore()
                }
                
                for card in game.cards.filter({ $0.inGame }) {
                    deal(card)
                }
            }
        }
    }
    
    var restart: some View {
        Button("Restart") {
            withAnimation {
                dealt = []
                game.restart()
            }
        }
    }
    
    @State private var dealt = Set<Int>()
    
    private func deal(_ card: SetModel.Card) {
        dealt.insert(card.id)
    }
    
    private func isUndealt(_  card: SetModel.Card) -> Bool {
        !dealt.contains(card.id)
    }
    
    private func dealAnimation(for card: SetModel.Card) -> Animation {
        var delay = 0.0
        if let index = game.cards.firstIndex(where: { $0.id == card.id }) {
            delay = Double(index) * (CardConstants.totalDealDuration / Double(game.cards.count))
        }
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }
    
    private func zIndex(of card: SetModel.Card) -> Double {
        -Double(game.cards.firstIndex(where: { $0.id == card.id }) ?? 0)
    }
    
    private struct CardConstants {
        static let color = Color.red
        static let aspectRatio: CGFloat = 2/3
        static let dealDuration: Double = 0.5
        static let totalDealDuration: Double = 2
        static let undealtHeight: CGFloat = 90
        static let undealtWidth = undealtHeight * aspectRatio
    }
}

struct CardView: View {
    let card: SetGame.Card
    
    @State var size: CGFloat = 1.0
        
    var repeatingAnimation: Animation {
        Animation
            .easeInOut(duration: 2) //.easeIn, .easyOut, .linear, etc...
            .repeatForever()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                
                if card.inGame || (!card.inGame && card.isSet){
                    
                    if !card.isSelected {
                        shape.fill().foregroundColor(.white)
                        shape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
                    } else {
                       
                        shape.fill().foregroundColor(.gray)
                        shape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
                    }
                    
                    if card.isSet {
                        shape.fill().foregroundColor(.orange)
                        shape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
                    }
                    
                    if card.notSet {
                        shape.fill().foregroundColor(.yellow)
                        shape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
                    }
                    
                    switch card.shape {
                    case .diamond:
                        CardFace<Diamond>(card: card)
                    case .squiggle:
                        CardFace<Rectangle>(card: card)
                    case .oval:
                        CardFace<Ellipse>(card: card)
                    }
                    
                } else {
                    shape.fill()
                }
            }
            .scaleEffect(card.isSet ? 1.1 : 1.0)
            .scaleEffect(card.notSet ? 0.9 : 1.0)
        }
    }
    
    private func font(in size: CGSize) -> Font {
        Font.system(size: min(size.width, size.height) * DrawingConstants.fontScale)
    }
    
    private struct DrawingConstants {
        static let cornerRadius: CGFloat = 10
        static let lineWidth: CGFloat = 3
        static let fontScale: CGFloat = 0.7
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SetGameView(game: SetGame())
    }
}
