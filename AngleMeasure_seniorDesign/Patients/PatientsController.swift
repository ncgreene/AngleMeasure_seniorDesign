//
//  ViewController.swift
//  AngleMeasure_seniorDesign
//
//  Created by Nathan Greene on 1/16/19.
//  Copyright © 2019 Nathan Greene. All rights reserved.
//

import UIKit

class PatientsController: UITableViewController, CreatePatientControllerDelegate {
    
    let cellId = "cellId"
    var patients = [Patient]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        patients = CoreDataManager.shared.fetchPatients()
        
        setupUI()
    }
    
    func setupUI() {
        navigationItem.title = "Patients"
        setupPlusButtonInNavBar(selector: #selector(handleAddPatient))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    @objc func handleAddPatient() { // Modal
        let createPatientController = CreatePatientController()
        createPatientController.delegate = self
        
        let navController = UINavigationController(rootViewController: createPatientController)
        
        present(navController, animated: true, completion: nil)
    }
    
    // MARK: Delegate
    func didAddPatient(patient: Patient) {
        patients.insert(patient, at: 0)
        
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [indexPath], with: .top)
        self.tableView.endUpdates()
    }
    
    func didEditPatient(patient: Patient) {
        let row = patients.index(of: patient)
        let reloadIndexPath = IndexPath(row: row!, section: 0)
        tableView.reloadRows(at: [reloadIndexPath], with: .middle)
    }
    
    // MARK: UITableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let patient = patients[indexPath.row]
        cell.textLabel?.text = patient.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patients.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let patient = patients[indexPath.row]
        let sessionsController = SessionsController()
        sessionsController.patient = patient
        
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
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            let patient = self.patients[indexPath.row]
            
            self.patients.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic )
            
            let context = CoreDataManager.shared.persistentContainer.viewContext
            context.delete(patient)
            do {
                try context.save()
            } catch let saveErr {
                print("Failed to save a deletion: \(saveErr)")
            }
        }
        deleteAction.backgroundColor = .red
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: editHandler)
        editAction.backgroundColor = .black
        
        return [deleteAction, editAction]
    }
    fileprivate func editHandler(action: UITableViewRowAction, indexPath: IndexPath) {
        let editPatientController = CreatePatientController()
        editPatientController.delegate = self
        editPatientController.patient = patients[indexPath.row]
        let navController = UINavigationController(rootViewController: editPatientController)
        present(navController, animated: true, completion: nil)
        
    }
    

}

