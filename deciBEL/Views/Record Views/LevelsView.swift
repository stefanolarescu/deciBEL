//
//  LevelsView.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 21/04/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit

class LevelsView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        for (index, level) in noiseLevels.enumerated() {
            let levelLabel = UILabel(frame:
                CGRect(
                    x: 0,
                    y: 0,
                    width: frame.width,
                    height: ICON_SIZE
                )
            )
            levelLabel.text = level
            levelLabel.font = UIFont.boldSystemFont(ofSize: 16)
            levelLabel.textColor = .black
            levelLabel.center.y = CGFloat(index) * (ICON_SIZE + ICONS_SPACING)
            addSubview(levelLabel)
        }
    }
}
