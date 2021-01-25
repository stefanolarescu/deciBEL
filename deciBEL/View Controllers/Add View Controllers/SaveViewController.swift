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
            if error != nil {
                saveLabel?.text = GeneralStrings.Fail
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.dismiss(animated: true)
                }
            } else {
                sendDataToServer(recording: recording) { error in
                    DispatchQueue.main.async {
                        self.activityIndicator?.stopAnimating()
                        self.activityIndicator?.isHidden = true
                        self.saveLabel?.isHidden = false
                        self.view.isUserInteractionEnabled = false
                    }
                    
                    guard error == nil else {
                        DispatchQueue.main.async {
                            self.saveLabel?.text = GeneralStrings.Fail
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                            self.dismiss(animated: true)
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.saveLabel?.text = GeneralStrings.Success
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        self.dismiss(animated: true) {
                            self.delegate?.segueToHistory()
                        }
                    }
                }
            }
        }
    }
    
    private func sendDataToServer(recording: Recording, completionHandler: @escaping (_ error: Error?) -> Void) {
        let json: [String: Any] = [
            "name": "Stefan",
            "location": "\(recording.longitude) \(recording.latitude)",
            "decibelLevel": recording.decibels
        ]

        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])

        if let url = URL(string: "http://localhost:9999") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                completionHandler(error)
            }

            task.resume()
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
