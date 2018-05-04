//
//  ColoredDisclosureIndicator.swift
//  Todoey
//
//  Created by Steven Loker on 5/2/18.
//  Copyright © 2018 Steven M. Loker. All rights reserved.
//

import UIKit

class ColoredDisclosureIndicator: UIView {
    
    override func draw(_ rect: CGRect) {
        let x = rect.maxX - 3.0
        let y = rect.midY
        let R = CGFloat(4.5)
        let ctxt = UIGraphicsGetCurrentContext()!
        if let backgroundColor = backgroundColor {
            backgroundColor.setStroke()
            backgroundColor.setFill()
            ctxt.addRect(rect)
            ctxt.strokePath()
        }
        tintColor.setStroke()
        ctxt.move(to: CGPoint(x: x - R, y: y - 1.25 * R))
        ctxt.addLine(to: CGPoint(x: x, y: y))
        ctxt.addLine(to: CGPoint(x: x - R, y: y + 1.25 * R))
        ctxt.setLineCap(.square)
        ctxt.setLineJoin(.miter)
        ctxt.setLineWidth(CGFloat(2))
        ctxt.strokePath()
    }
}
