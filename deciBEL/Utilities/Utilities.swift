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

// MARK: - DEVICE
func deviceIsAnIPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

// MARK: - ALERTS
func showAlertForLocationServices(title: String, message: String, style: UIAlertController.Style) -> UIAlertController {
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

// MARK: - LOCATION
var locationServicesAreEnabled: Bool {
    return CLLocationManager.locationServicesEnabled()
}
