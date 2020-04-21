//
//  IconsView.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 21/04/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit

class IconsView: UIView {
    
    private let icons = [
        "Pain Thunder",
        "Concert",
        "Motorcycle",
        "Diesel Truck",
        "Loud Music",
        "Traffic",
        "Normal Conversation",
        "Rain",
        "Bird Song",
        "Whisper",
        "Leaves",
        "Breathing"
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        for (index, icon) in icons.enumerated() {
            let iconImageView = UIImageView(frame:
                CGRect(
                    x: 0,
                    y: 0,
                    width: ICON_SIZE,
                    height: ICON_SIZE
                )
            )
            iconImageView.center.x = 12
            iconImageView.center.y = CGFloat(index) * (ICON_SIZE + ICONS_SPACING)
            iconImageView.image = UIImage(named: icon)
            iconImageView.tintColor = .black
            addSubview(iconImageView)
        }
    }
}
