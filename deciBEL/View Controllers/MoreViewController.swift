//
//  MoreViewController.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 08/03/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        tabBarItem = UITabBarItem(
            title: GeneralStrings.More,
            image: UIImage(systemName: "ellipsis.circle.fill"),
            selectedImage: UIImage(systemName: "ellipsis.circle.fill")
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
