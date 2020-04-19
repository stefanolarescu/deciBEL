//
//  NumbersView.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 19/04/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit

class NumbersView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        for number in 0...200 {
            let numberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
            numberLabel.text = "\(number)"
            numberLabel.font = UIFont.systemFont(ofSize: 24)
            numberLabel.textColor = .black
            numberLabel.center.x = CGFloat(number) * 5 * RULER_SPACING
            numberLabel.center.y = frame.midY
            numberLabel.textAlignment = .center
            addSubview(numberLabel)
        }
    }
}
