//
//  Recording+CoreDataProperties.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 02/05/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//
//

import Foundation
import CoreData

extension Recording {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Recording> {
        return NSFetchRequest<Recording>(entityName: "Recording")
    }

    @NSManaged public var date: Date
    @NSManaged public var decibels: Int16
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
}
