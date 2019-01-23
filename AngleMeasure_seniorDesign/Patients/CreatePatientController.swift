//
//  AddPatientsController.swift
//  AngleMeasure_seniorDesign
//
//  Created by Nathan Greene on 1/19/19.
//  Copyright © 2019 Nathan Greene. All rights reserved.
//

import UIKit
import CoreData

// Custom Delegation
protocol CreatePatientControllerDelegate {
    func didAddPatient(patient: Patient)
    func didEditPatient(patient: Patient)
}

class CreatePatientController: UIViewController {
    
    var nameLabel: UILabel = UILabel()
    var nameTextField: UITextField = UITextField()
    var delegate: CreatePatientControllerDelegate?
    var patient: Patient?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = patient == nil ? "Create Patient" : "Edit Patient"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

        view.backgroundColor = .black
    }
    
    func setupUI() {
        setupCancelButtonInNavBar()
        setupSaveButtonInNavBar(selector: #selector(handleSave))
        
        _ = setupWhiteBackground(height: 50)
        nameLabel = setupNameLabel()
        nameTextField = setupNameTextField(nameLabel: nameLabel, name: patient?.name)
    }
    
    @objc func handleSave() {
        if patient == nil {
            createPatient()
        } else {
            savePatientChanges()
        }
    }
    
    fileprivate func savePatientChanges() {
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        patient?.name = nameTextField.text
        
        do {
            try context.save()
            
            //success
            dismiss(animated: true) {
                self.delegate?.didEditPatient(patient: self.patient!)
            }
        }catch let saveErr {
            print("failed to save edit to patient: ", saveErr)
        }
        
    }
    
    fileprivate func createPatient() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let patient = NSEntityDescription.insertNewObject(forEntityName: "Patient", into: context)
        
        patient.setValue(nameTextField.text, forKey: "name")
        
        do {
            try context.save()
            
            // success
            dismiss(animated: true) {
                self.delegate?.didAddPatient(patient: patient as! Patient) //cast to Patient from NSManagedObject
            }
        } catch let saveErr {
            print("Failed to save patient: \(saveErr)")
        }
    }
    
}


