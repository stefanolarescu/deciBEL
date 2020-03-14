//
//  StartViewController.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 08/03/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var logoLabel: UILabel?
    @IBOutlet weak var outerCircleView: UIView?
    @IBOutlet weak var innerCircleView: UIView?
    @IBOutlet weak var highlightView: UIView?
    
    // MARK: - INIT METHOD
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        tabBarItem = UITabBarItem(
            title: GeneralStrings.Add,
            image: UIImage(systemName: "plus.circle.fill"),
            selectedImage: UIImage(systemName: "plus.circle.fill")
        )
    }
    
    //MARK: - LIFE CYCLE METHODS
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoLabel?.text = GeneralStrings.Decibel
        
        outerCircleView?.backgroundColor = .outerCircleBlue()
        innerCircleView?.backgroundColor = .innerCircleBlue()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - SEGUE HANDLER
    @IBAction func tapGestureViewHandler(_ sender: UITapGestureRecognizer) {
        highlightView?.highlight(duration: 0.2, delay: 0)
        performSegue(withIdentifier: SegueIdentifiers.Record, sender: self)
    }
    
    //MARK: - OTHER METHODS
    
}
