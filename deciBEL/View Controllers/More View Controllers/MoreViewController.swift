//
//  MoreViewController.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 08/03/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var aboutButton: UIButton?
    @IBOutlet weak var legalButton: UIButton?
    
    // MARK: - PROPERTIES
    let showAboutSegueIdentifier = "showAbout"
    let showLegalSegueIdentifier = "showLegal"
    
    // MARK: - INIT METHOD
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if #available(iOS 13.0, *) {
            tabBarItem = UITabBarItem(
                title: GeneralStrings.More,
                image: UIImage(systemName: "ellipsis.circle.fill"),
                selectedImage: UIImage(systemName: "ellipsis.circle.fill")
            )
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - LIFE CYCLE METHODS
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = GeneralStrings.More
        
        aboutButton?.setTitle(GeneralStrings.About, for: .normal)
        legalButton?.setTitle(GeneralStrings.Legal, for: .normal)
    }
    
    // MARK: - OTHER METHODS
    
    // MARK: - Segue Methods
    @IBAction func aboutButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: showAboutSegueIdentifier, sender: self)
    }
    
    @IBAction func legalButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: showLegalSegueIdentifier, sender: self)
    }
}
