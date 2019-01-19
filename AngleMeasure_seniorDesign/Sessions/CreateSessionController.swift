//
//  CreateSessionsController.swift
//  AngleMeasure_seniorDesign
//
//  Created by Nathan Greene on 1/19/19.
//  Copyright © 2019 Nathan Greene. All rights reserved.
//

import UIKit

// Custom Delegation
protocol CreateSessionControllerDelegate {
    //    func didAddPatient(patient: Patient)
    //    func didEditPatient(patient: Patient)
}

class CreateSessionController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        navigationItem.title = patient == nil ? "Create Patient" : "Edit Patient"
        navigationItem.title = "Create Session"
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
        let nameLabel = setupNameLabel()
        _ = setupNameTextField(nameLabel: nameLabel, name: nil)
    }
    
    @objc func handleSave() {
        print("still need to add save functionality -> CreateSessionController")
    }
}



