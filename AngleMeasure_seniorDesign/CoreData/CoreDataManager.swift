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
        let container = NSPersistentContainer(name: "PatientManagerModels")
        container.loadPersistentStores { (storeDescription, err) in
            if let err = err {
                fatalError("Loading of Persistent Store failed: \(err)")
            }
        }
        return container
    }()
    
    func fetchPatients() -> [Patient] {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Patient>(entityName: "Patient")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)] 
        
        do {
            let patients = try context.fetch(fetchRequest)
            return patients
            
        } catch let fetchErr {
            print("Failed to fetch patients: \(fetchErr)")
            return []
        }
    }
    
    func fetchSessions() -> [Session] {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Session>(entityName: "Session")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let sessions = try context.fetch(fetchRequest)
            return sessions
            
        } catch let fetchErr {
            print("Failed to fetch session: \(fetchErr)")
            return []
        }
    }
    
    func fetchMeasurements() -> [Measurement] {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Measurement>(entityName: "Measurement")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let measurements = try context.fetch(fetchRequest)
            return measurements
            
        } catch let fetchErr {
            print("Failed to fetch session: \(fetchErr)")
            return []
        }
    }
    
    func createSession(date: Date, patient: Patient) -> (Session?, Error?) {
    
        let context = persistentContainer.viewContext
        
        let session = NSEntityDescription.insertNewObject(forEntityName: "Session", into: context) as! Session
        
        session.date = date
        session.patient = patient
        
        do {
            try context.save()
            
            // success
            return(session, nil)
            
        } catch let saveErr {
            print("Failed to save session: \(saveErr)")
            return (nil, saveErr)
        }
    }
    
}
