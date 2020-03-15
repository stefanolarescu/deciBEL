//
//  GrayMaskView.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 15/03/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit

class GrayMaskView: UIView {
    
    func createBezierPath(dropRadius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        
        guard let superview = self.superview else {
            return path
        }
        
        let yForTopOfShape: CGFloat = 55
        let width = superview.frame.width
        let height = superview.bounds.maxY
        let xForFirstPairOfControlPoints = width / 2 - dropRadius
        let xForSecondPairOfControlPoints = width / 2 + dropRadius
        
        path.move(to: CGPoint(x: 0, y: yForTopOfShape))
        path.addLine(to: CGPoint(x: width / 2 - 2 * dropRadius, y: yForTopOfShape))
        path.addCurve(
            to: CGPoint(x: width / 2, y: 0),
            controlPoint1: CGPoint(x: xForFirstPairOfControlPoints, y: yForTopOfShape),
            controlPoint2: CGPoint(x: xForFirstPairOfControlPoints, y: 0)
        )
        path.addCurve(
            to: CGPoint(x: width / 2 + 2 * dropRadius, y: yForTopOfShape),
            controlPoint1: CGPoint(x: xForSecondPairOfControlPoints, y: 0),
            controlPoint2: CGPoint(x: xForSecondPairOfControlPoints, y: yForTopOfShape)
        )
        path.addLine(to: CGPoint(x: width, y: yForTopOfShape))
               path.addLine(to: CGPoint(x: width, y: height))
               path.addLine(to: CGPoint(x: 0, y: height))
               path.close()
        
        return path
    }
    
    func drawShape(dropRadius: CGFloat) {
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let maskLayer = CAShapeLayer()
        maskLayer.path = createBezierPath(dropRadius: dropRadius).cgPath
        maskLayer.fillColor = UIColor.maskGray().cgColor
        self.layer.addSublayer(maskLayer)
    }

}
