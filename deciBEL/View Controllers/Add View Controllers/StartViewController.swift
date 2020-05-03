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
    @IBOutlet weak var grayMaskView: GrayMaskView?
    @IBOutlet weak var outerCircleView: UIView?
    @IBOutlet weak var innerCircleView: UIView?
    @IBOutlet weak var playImageView: UIImageView?
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView?
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
    
    // MARK: - LIFE CYCLE METHODS
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoLabel?.text = GeneralStrings.Decibel
        
        grayMaskView?.drawShape(dropRadius: 55)
        
        outerCircleView?.backgroundColor = UIColor(named: "Blue")?.withAlphaComponent(0.3)
        innerCircleView?.backgroundColor = UIColor(named: "Blue")
        
        activityIndicatorView?.isHidden = true
        activityIndicatorView?.stopAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        playImageView?.isHidden = false
        activityIndicatorView?.isHidden = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.grayMaskView?.drawShape(dropRadius: 55)
        }, completion: nil)
    }
    
    // MARK: - TOUCH EVENTS
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: view)
            if let tapGestureView = highlightView?.superview {
                if tapGestureView.frame.contains(position) {
                    highlightView?.highlight(duration: 0.4, delay: 0)
                    playImageView?.isHidden = true
                    activityIndicatorView?.isHidden = false
                    activityIndicatorView?.startAnimating()
                }
            }
        }
    }
    
    // MARK: - SEGUE HANDLER
    @IBAction func tapGestureViewHandler(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: SegueStrings.Record, sender: self)
    }
}
