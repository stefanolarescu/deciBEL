//
//  ScaleView.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 19/04/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit

class RulerView: UIView {
    
    private func createBezierPath() -> UIBezierPath {
        let path = UIBezierPath()
        
        guard let superview = self.superview else {
            return path
        }
        
        let height = superview.bounds.height
        var x: CGFloat
        var y: CGFloat
        
        for (index, bar) in stride(from: 0, through: 200, by: 0.2).enumerated() {
            x = CGFloat(index) * RULER_SPACING
            if bar == floor(bar) {
                y = height - 25.0
            } else {
                y = height - 15.0
            }
            
            path.move(to: CGPoint(x: x, y: height - RULER_BAR_WIDTH / 2))
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.move(to: CGPoint(x: 0, y: 0))
        path.close()
        
        return path
    }
    
    override func draw(_ rect: CGRect) {
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                
        let path = createBezierPath().cgPath
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.lineWidth = RULER_BAR_WIDTH
        shapeLayer.lineCap = .round
        if let barColor = UIColor(named: "Bar") {
            shapeLayer.strokeColor = barColor.cgColor
        } else {
            shapeLayer.strokeColor = UIColor.gray.cgColor
        }
        self.layer.addSublayer(shapeLayer)
    }
}
