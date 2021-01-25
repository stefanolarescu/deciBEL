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
    
    var timer: Timer?
    var shouldStopGeneratingData = false
    
    var requestNumber: UInt64 = 19433
    
    // MARK: - INIT METHOD
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        tabBarItem = UITabBarItem(
            title: GeneralStrings.More,
            image: UIImage(systemName: "ellipsis.circle.fill"),
            selectedImage: UIImage(systemName: "ellipsis.circle.fill")
        )
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
    @IBAction func generateDataButtonAction(_ sender: UIButton) {
        if sender.currentTitle == "Generate Data" {
            sender.setTitle("Stop", for: .normal)
//            timer = Timer.scheduledTimer(timeInterval: 10, target: self,
//                                         selector: #selector(sendDataToServer),
//                                         userInfo: nil, repeats: true)
            shouldStopGeneratingData = false
            sendDataToServer()
        } else {
            sender.setTitle("Generate Data", for: .normal)
            shouldStopGeneratingData = true
//            timer?.invalidate()
//            timer = nil
        }
    }
    
    @objc private func sendDataToServer() {
//        for _ in 1...1000 {
            let coordinates = generateRandomCoordinates()
            let decibels = generateRandomDecibelValue()
            
            let json: [String: Any] = [
                "name": "Stefan",
                "location": "\(coordinates.0) \(coordinates.1)",
                "decibelLevel": decibels
            ]

            let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])

            if let url = URL(string: "http://localhost:9999") {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                request.httpBody = jsonData

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    print("\(self.requestNumber):\t\(coordinates.0) \(coordinates*-.1)")
                    self.requestNumber += 1
                    if self.requestNumber < 100000, !self.shouldStopGeneratingData {
                        self.sendDataToServer()
                    }
                }

                task.resume()
            }
//        }
    }
    
    private func generateRandomCoordinates() -> (Double, Double) {
        let longitude = Double.random(in: -180.0...180.0)
        let latitude = Double.random(in: -90.0...90.0)
        return (longitude, latitude)
    }
    
    private func generateRandomDecibelValue() -> Int {
        return Int.random(in: 0..<130)
    }
    
    // MARK: - Segue Methods
    @IBAction func aboutButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: showAboutSegueIdentifier, sender: self)
    }
    
    @IBAction func legalButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: showLegalSegueIdentifier, sender: self)
    }
}
