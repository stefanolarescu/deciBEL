//
//  HistoryViewController.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 08/03/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        tabBarItem = UITabBarItem(
            title: GeneralStrings.History,
            image: UIImage(systemName: "clock.fill"),
            selectedImage: UIImage(systemName: "clock.fill")
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
