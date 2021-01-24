//
//  RecordingTableViewCell.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 02/05/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit
import MapKit

protocol RecordingTableViewCellDelegate {
    func showAlert(_ alert: UIAlertController)
}

class RecordingTableViewCell: UITableViewCell {

    // MARK: - OUTLETS
    @IBOutlet weak var dayNameLabel: UILabel?
    @IBOutlet weak var dayNumberLabel: UILabel?
    
    @IBOutlet weak var timeLabel: UILabel?
    
    @IBOutlet weak var averageDecibelsLabel: UILabel?
    @IBOutlet weak var decibelsLabel: UILabel?
    
    @IBOutlet weak var tapGestureView: UIView?
    @IBOutlet weak var mapView: MKMapView?
    @IBOutlet weak var highlightView: UIView?
    
    // MARK: - PROPERTIES
    let application = UIApplication.shared
    let regionMeters: Double = 1000
    var latitude: Double = 0
    var longitude: Double = 0
    
    let googleMapsURL = "comgooglemaps://"
    let appleMapsURL = "maps://"
    
    var delegate: RecordingTableViewCellDelegate?
    
    // MARK: - LIFE CYCLE METHODS
    override func awakeFromNib() {
        super.awakeFromNib()
        
        decibelsLabel?.text = AudioStrings.DecibelsA
    }
    
    // MARK: - OTHER METHODS
    
    // MARK: Configure Methods
    func configure(
        date: Date,
        decibels: Int,
        latitude: Double,
        longitude: Double
    ) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        
        dateFormatter.dateFormat = "EE"
        let dayName = dateFormatter.string(from: date)
        dayNameLabel?.text = dayName
        
        dateFormatter.dateFormat = "d"
        let dayNumber = dateFormatter.string(from: date)
        dayNumberLabel?.text = dayNumber
        
        dateFormatter.dateFormat = "H:mm"
        let time = dateFormatter.string(from: date)
        if systemUses24HourFormat() {
            timeLabel?.text = time
        } else {
            if let indexOfSpace = time.firstIndex(of: " ") {
                let hour = time.prefix(upTo: indexOfSpace)
                let period = String(time.suffix(from: indexOfSpace).dropFirst())
                timeLabel?.text = hour + "\n" + period
            } else {
                timeLabel?.text = time
            }
        }
        
        averageDecibelsLabel?.text = "\(decibels)"
        
        self.latitude = latitude
        self.longitude = longitude
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(
            center: location,
            latitudinalMeters: regionMeters,
            longitudinalMeters: regionMeters
        )
        mapView?.setRegion(region, animated: false)
        
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(tapMapAction)
        )
        tapGestureView?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: Gesture Recognizer Methods
    @objc private func tapMapAction() {
        highlightView?.highlight(duration: 0.4, delay: 0)
        
        var googleMapsIsInstalled = false
        var appleMapsIsInstalled = false
        
        if application.canOpenURL(URL(string: googleMapsURL)!) {
            googleMapsIsInstalled = true
        }
        if application.canOpenURL(URL(string: appleMapsURL)!) {
            appleMapsIsInstalled = true
        }
        
        if googleMapsIsInstalled, appleMapsIsInstalled {
            delegate?.showAlert(
                showAlertForOpeningMapsApp(
                    callback: { mapsApp in
                        if mapsApp == .googleMaps {
                            self.openGoogleMaps()
                        } else {
                            self.openMaps()
                        }
                    }
                )
            )
        } else if googleMapsIsInstalled {
            openGoogleMaps()
        } else {
            openMaps()
        }
    }
    
    private func openGoogleMaps() {
        let url = googleMapsURL + "?center=\(latitude),\(longitude)&q=\(latitude),\(longitude)"
        application.open(URL(string: url)!)
    }
    
    private func openMaps() {
        let regionDistance = regionMeters
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Place Name"
        mapItem.openInMaps(launchOptions: options)
    }
}
