//
//  RecordingTableViewCell.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 02/05/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit
import MapKit

class RecordingTableViewCell: UITableViewCell {

    // MARK: - OUTLETS
    @IBOutlet weak var dayNameLabel: UILabel?
    @IBOutlet weak var dayNumberLabel: UILabel?
    
    @IBOutlet weak var timeLabel: UILabel?
    
    @IBOutlet weak var averageDecibelsLabel: UILabel?
    @IBOutlet weak var decibelsLabel: UILabel?
    
    @IBOutlet weak var mapView: MKMapView?
    
    // MARK: - PROPERTIES
    let regionMeters: Double = 1000
    
    // MARK: - LIFE CYCLE METHODS
    override func awakeFromNib() {
        super.awakeFromNib()
        
        decibelsLabel?.text = AudioStrings.DecibelsA
    }
    
    // MARK: - OTHER METHODS
    
    // MARK: - Configure Methods
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
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(
            center: location,
            latitudinalMeters: regionMeters,
            longitudinalMeters: regionMeters
        )
        mapView?.setRegion(region, animated: false)
    }
}
