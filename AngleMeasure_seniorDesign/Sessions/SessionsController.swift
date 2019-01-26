//
//  SessionsController.swift
//  AngleMeasure_seniorDesign
//
//  Created by Nathan Greene on 1/18/19.
//  Copyright © 2019 Nathan Greene. All rights reserved.
//

import UIKit
import CoreData

class SessionsController: UITableViewController {
    var patient: Patient?
    var sessions = [Session]()
    let cellId = "cellId"
    
//    lazy var summaryButton: UIBarButtonItem = {
//        let button = UIBarButtonItem(title: "Display Patient Summary", style: .plain, target: self, action: #selector(handleSummary))
//        button.tintColor = .orange
//        return button
//    }()
//    @objc func handleSummary() {
//        print("show summary for \(patient?.name ?? "no name")")
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let orderedSessions = patient?.sessions?.sortedArray(using: [NSSortDescriptor(key: "date", ascending: false)]) as? [Session] {
            sessions = orderedSessions
        } else { sessions = [] }
        
        navigationItem.title = patient?.name
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        setupPlusButtonInNavBar(selector: #selector(handleAddSession))
//        navigationController?.toolbar.barTintColor = .lightGray
//        toolbarItems = [summaryButton]
        }
    
    @objc func handleAddSession() {
        
        let currentDate = Date()
        guard let patient = patient else { return }
        
        let tuple = CoreDataManager.shared.createSession(date: currentDate, patient: patient)
        
        if let err = tuple.1 {
            print(err)
        } else {
            self.sessions.insert(tuple.0!, at: 0)
            
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [indexPath], with: .top)
            self.tableView.endUpdates()
        }
    }
    
    // MARK: UITableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.backgroundColor = .paleBlue
        
        let session = sessions[indexPath.row]
        
        if let date = session.date {
            let dateFormattedString = dateToString(date: date)
            cell.textLabel?.text = dateFormattedString
        } else {
            cell.textLabel?.text = "No date found"
        }
        cell.textLabel?.textColor = .darkBrown
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let session = sessions[indexPath.row]
        let measurementsController = MeasurementsController()
        measurementsController.session = session
        
        navigationController?.pushViewController(measurementsController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .grayBlue
        button.setTitle("View Patient Summary", for: .normal)
        button.setTitleColor(.darkBrown, for: .normal)
        button.addTarget(self, action: #selector(handleSummary), for: .touchUpInside)
        button.isHidden = false
        return button
    }
    @objc func handleSummary() { //modal
        let summaryController = SummaryController()
        summaryController.patient = self.patient
        let navController = UINavigationController(rootViewController: summaryController)
        present(navController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
  
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No sessions available..."
        label.textColor = .darkBrown
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.numberOfRows(inSection: 0) == 0 ? 150 : 0
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            let session = self.sessions[indexPath.row]
            
            self.sessions.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic )
            
            let context = CoreDataManager.shared.persistentContainer.viewContext
            context.delete(session)
            do {
                try context.save()
            } catch let saveErr {
                print("Failed to save a session deletion: \(saveErr)")
            }
        }
        deleteAction.backgroundColor = .red
        
        return [deleteAction]
    }
    
    
}

