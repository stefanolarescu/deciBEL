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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var saveHighlightView: UIView?
    
    // MARK: - PROPERTIES
    var averageDecibels = 30
    var date = Date()
    var latitude = 0.0
    var longitude = 0.0
    
    var delegate: SaveViewControllerDelegate?
    
    var coreDataModel = CoreDataModel.shared
        
    // MARK: LIFE CYCLE METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBlur()
        
        decibelsAverageLabel?.text = "\(averageDecibels)"
        decibelsLabel?.text = AudioStrings.DecibelsA
        saveLabel?.text = GeneralStrings.Save
        
        saveLabel?.isHidden = false
        activityIndicator?.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.setOffsetsDelegate(decibels: Double(averageDecibels))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        activityIndicator?.stopAnimating()
        view.isUserInteractionEnabled = true
//        dismiss(animated: false)
    }
    
    // MARK: - OTHER METHODS
    
    // MARK: Navigation Methods
    @IBAction func closeAction(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    // MARK: Core Data Methods
    @IBAction func saveAction(_ sender: Any) {
        saveHighlightView?.highlight(duration: 0.4, delay: 0)
        saveLabel?.isHidden = true
        activityIndicator?.isHidden = false
        activityIndicator?.startAnimating()
        
        let recording = Recording(context: coreDataModel.container.viewContext)
        configureRecording(recording)
        coreDataModel.saveContext() { error in
            activityIndicator?.stopAnimating()
            activityIndicator?.isHidden = true
            saveLabel?.isHidden = false
            view.isUserInteractionEnabled = false
            
            if error != nil {
                saveLabel?.text = GeneralStrings.Fail
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.dismiss(animated: true)
                }
            } else {
                saveLabel?.text = GeneralStrings.Success
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.dismiss(animated: true) {
                        self.delegate?.segueToHistory()
                    }
                }
            }
        }
    }
    
    private func configureRecording(_ recording: Recording) {
        recording.date = date
        recording.decibels = Int16(averageDecibels)
        recording.latitude = latitude
        recording.longitude = longitude
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
