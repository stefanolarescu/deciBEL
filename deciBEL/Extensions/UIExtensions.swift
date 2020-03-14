//
//  UIExtensions.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 14/03/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit

//MARK: - UICOLOR
extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    class func outerCircleBlue() -> UIColor {
        return UIColor(red: 0, green: 124, blue: 232).withAlphaComponent(0.3)
    }
    
    class func innerCircleBlue() -> UIColor {
        return UIColor(red: 0, green: 124, blue: 232)
    }
    
}

//MARK: - UIVIEW
extension UIView {
    
    //MARK: Corner Radius
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        } set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    //MARK: Animations
     func highlight(duration: Double, delay: Double) {
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: .curveLinear,
            animations: {
                self.backgroundColor = .init(white: 1.0, alpha: 0.8)
                self.backgroundColor = .clear
            }
        )
    }
}
