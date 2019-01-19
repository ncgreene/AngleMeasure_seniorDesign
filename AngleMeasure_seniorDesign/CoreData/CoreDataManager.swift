//
//  CoreDataManager.swift
//  AngleMeasure_seniorDesign
//
//  Created by Nathan Greene on 1/19/19.
//  Copyright © 2019 Nathan Greene. All rights reserved.
//

import CoreData

struct CoreDataManager {
    static let shared = CoreDataManager() //singleton instance

    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PatientManagerModels") //name needs to match the data model file
        container.loadPersistentStores { (storeDescription, err) in
            if let err = err {
                fatalError("Loading of Persistent Store failed: \(err)")
            }
        }
        return container
    }()
    
    func fetchPatients() -> [Patient] {
        //attempt core data fetch
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Patient>(entityName: "Patient")
        
        do {
            let patients = try context.fetch(fetchRequest)
            return patients
            
        } catch let fetchErr {
            print("Failed to fetch company: \(fetchErr)")
            return []
        }
    }
}
