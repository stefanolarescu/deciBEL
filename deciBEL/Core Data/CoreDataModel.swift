//
//  CoreDataModel.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 02/05/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import CoreData

class CoreDataModel {
    
    static let shared = CoreDataModel()
  
    var container: NSPersistentContainer!
    
    private init() {
        container = NSPersistentContainer(name: GeneralStrings.Decibel)
        
        container.loadPersistentStores { storeDescription, error in
            if let unwrappedError = error {
                print("Unresolved error: \(unwrappedError)")
            }
        }
    }
    
    func saveContext(callback: (Error?) -> Void) {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
                callback(nil)
            } catch {
                print("An error occurred while saving: \(error)")
                callback(error)
            }
        }
    }
}
