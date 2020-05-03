//
//  UIExtensions.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 14/03/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit

// MARK: - UIVIEW
extension UIView {
    
    // MARK: Corner Radius
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        } set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    // MARK: Animations
    func highlight(duration: Double, delay: Double) {
        self.layer.removeAllAnimations()
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
    
    func animateZoomContainerView(duration: Double, delay: Double) {
        self.layer.removeAllAnimations()
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                self.backgroundColor = UIColor(named: "Blue")
                self.backgroundColor = UIColor(named: "Map Controls Background")
            }
        )
    }
    
    func animateCenterImageView(duration: Double, delay: Double, enabled: Bool) {
        self.layer.removeAllAnimations()
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                self.backgroundColor = enabled == true ? .systemBlue : UIColor(named: "Map Controls Background")
            }
        )
    }
    
    func rotate360(duration: Double, delay: Double, callback: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration / 4,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        }) { completed in
            if completed {
                UIView.animate(
                    withDuration: duration / 4,
                    delay: 0,
                    options: .curveLinear,
                    animations: {
                        self.transform = CGAffineTransform(rotationAngle: -.pi)
                    }
                ) { completed in
                    if completed {
                        UIView.animate(
                            withDuration: duration / 4,
                            delay: 0,
                            options: .curveLinear,
                            animations: {
                                self.transform = CGAffineTransform(rotationAngle: .pi / 2)
                            }
                        ) { completed in
                            if completed {
                                UIView.animate(
                                   withDuration: duration / 4,
                                   delay: 0,
                                   options: .curveEaseOut,
                                   animations: {
                                       self.transform = CGAffineTransform(rotationAngle: 0)
                                   }
                                ) { completed in
                                    if completed, let unwrappedCallback = callback {
                                        unwrappedCallback()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
