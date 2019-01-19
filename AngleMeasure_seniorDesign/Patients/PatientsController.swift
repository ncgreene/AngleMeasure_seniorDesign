//
//  ViewController.swift
//  AngleMeasure_seniorDesign
//
//  Created by Nathan Greene on 1/16/19.
//  Copyright © 2019 Nathan Greene. All rights reserved.
//

import UIKit

class PatientsController: UITableViewController {

    let cellId = "cellId"
    let samplePatients = ["Nathan", "Mandy", "Josh"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        navigationItem.title = "Patients"
        setupPlusButtonInNavBar(selector: #selector(handleAddPatient))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    @objc func handleAddPatient() { // Modal
        let createPatientController = CreatePatientController()
        
        let navController = UINavigationController(rootViewController: createPatientController)
        
        present(navController, animated: true, completion: nil)
        
    }
    
    // MARK: UITableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = samplePatients[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return samplePatients.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let patientName = samplePatients[indexPath.row]
        let sessionsController = SessionsController()
        sessionsController.patientName = patientName
        
        navigationController?.pushViewController(sessionsController, animated: true)
    }
    
    
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No patients available..."
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.numberOfRows(inSection: 0) == 0 ? 150 : 0
    }

}

