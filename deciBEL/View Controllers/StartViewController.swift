//
//  StartViewController.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 08/03/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var logoLabel: UILabel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        tabBarItem = UITabBarItem(
            title: GeneralStrings.Add,
            image: UIImage(systemName: "plus.circle.fill"),
            selectedImage: UIImage(systemName: "plus.circle.fill")
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoLabel?.text = GeneralStrings.Decibel
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
