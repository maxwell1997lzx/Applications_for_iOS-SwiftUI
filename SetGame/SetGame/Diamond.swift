//
//  Diamond.swift
//  SetGame
//
//  Created by macbook on 03/09/2021.
//

import SwiftUI

struct Diamond: Shape {
//    var width: CGFloat
//    var height: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let start = CGPoint(
            x: center.x + rect.width / 2,
            y: center.y
        )
        
        var p = Path()
        p.move(to: start)
        p.addLine(to: CGPoint(x: center.x, y: center.y + rect.height / 2))
        p.addLine(to: CGPoint(x: center.x - rect.width / 2, y: center.y))
        p.addLine(to: CGPoint(x: center.x, y: center.y - rect.height / 2))
        p.addLine(to: CGPoint(x: center.x + rect.width / 2, y: center.y))
        
        return p
    }
}
