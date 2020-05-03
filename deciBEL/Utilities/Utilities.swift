//
//  Utilities.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 15/03/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation

// MARK: - GLOBAL VARIABLES
let noiseLevels = [
    AudioStrings.Level12,
    AudioStrings.Level11,
    AudioStrings.Level10,
    AudioStrings.Level9,
    AudioStrings.Level8,
    AudioStrings.Level7,
    AudioStrings.Level6,
    AudioStrings.Level5,
    AudioStrings.Level4,
    AudioStrings.Level3,
    AudioStrings.Level2,
    AudioStrings.Level1
]

// MARK: - DEVICE
func deviceIsAnIPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

// MARK: - ALERTS
func showAlertForLocationServices(
    title: String,
    message: String,
    style: UIAlertController.Style
) -> UIAlertController {
    
    let alertController = UIAlertController(
        title: title,
        message: message,
        preferredStyle: style
    )
    let settingsAction = UIAlertAction(
        title: GeneralStrings.Settings,
        style: .cancel
    ) { _ in
            
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    let okAction = UIAlertAction(
        title: GeneralStrings.Okay,
        style: .default
    )
    alertController.addAction(okAction)
    alertController.addAction(settingsAction)
    
    return alertController
}

func showAlertForMicrophoneAccess(
    title: String,
    message: String,
    style: UIAlertController.Style,
    navigationController: UINavigationController?
) -> UIAlertController {
   
    let alertController = UIAlertController(
        title: title,
        message: message,
        preferredStyle: style
    )
    let settingsAction = UIAlertAction(
        title: GeneralStrings.Settings,
        style: .cancel
    ) { _ in
            
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    let okAction = UIAlertAction(
        title: GeneralStrings.Okay,
        style: .default
    ) { _ in
        navigationController?.popViewController(animated: true)
    }
    alertController.addAction(okAction)
    alertController.addAction(settingsAction)
    
    return alertController
}

func showAlertForContinuingRecording(callback: ((Bool) -> Void)?) -> UIAlertController {
    let alertController = UIAlertController(
        title: AudioStrings.ResumeRecording,
        message: AudioStrings.RecordingAlertMessage,
        preferredStyle: .alert
    )
    let continueAction = UIAlertAction(
        title: GeneralStrings.Continue,
        style: .default
    ) { _ in
        if let unwrappedCallback = callback {
            unwrappedCallback(false)
        }
    }
    let restartAction = UIAlertAction(
        title: GeneralStrings.Restart,
        style: .cancel
    ) { _ in
        if let unwrappedCallback = callback {
            unwrappedCallback(true)
        }
    }
    alertController.addAction(restartAction)
    alertController.addAction(continueAction)
    
    return alertController
}

// MARK: - LOCATION
var locationServicesAreEnabled: Bool {
    return CLLocationManager.locationServicesEnabled()
}

// MARK: - MATHS
func round(_ value: Double, toNearest: Double, decimals: Int) -> Double {
    let factor = pow(10, Double(decimals))
    let rounded = round(value / toNearest) * toNearest
    return Double(Int(rounded * factor)) / factor
}

// MARK: - DATE
func systemUses24HourFormat() -> Bool {
    let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
    return dateFormat.firstIndex(of: "a") == nil
}
