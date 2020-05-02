//
//  SaveViewController.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 02/05/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit

protocol SaveViewControllerDelegate {
    func setOffsetsDelegate(decibels: Double)
    func segueToHistory()
}

class SaveViewController: UIViewController {

    // MARK: - OUTLETS
    
    @IBOutlet weak var blurContainer: UIView?
    
    @IBOutlet weak var decibelsAverageLabel: UILabel?
    @IBOutlet weak var decibelsLabel: UILabel?
    @IBOutlet weak var saveLabel: UILabel?
    @IBOutlet weak var tapGestureView: UIView?
    @IBOutlet weak var saveHighlightView: UIView?
    
    // MARK: - PROPERTIES
    var averageDecibels = 30
    
    var delegate: SaveViewControllerDelegate?
        
    // MARK: LIFE CYCLE METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBlur()
        
        decibelsAverageLabel?.text = "\(averageDecibels)"
        decibelsLabel?.text = AudioStrings.DecibelsA
        saveLabel?.text = GeneralStrings.Save
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.setOffsetsDelegate(decibels: Double(averageDecibels))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        dismiss(animated: false)
    }
    
    // MARK: - OTHER METHODS
    
    // MARK: Navigation Methods
    @IBAction func closeAction(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        saveHighlightView?.highlight(duration: 0.4, delay: 0)
        delegate?.segueToHistory()
    }
    
    // MARK: UI Methods
    private func addBlur() {
        let blur = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.alpha = 1
        if let unwrappedBlurContainer = blurContainer {
            blurView.frame = unwrappedBlurContainer.bounds
        }
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurContainer?.addSubview(blurView)
    }
}
