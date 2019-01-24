//
//  MeasurementsController.swift
//  AngleMeasure_seniorDesign
//
//  Created by Nathan Greene on 1/18/19.
//  Copyright © 2019 Nathan Greene. All rights reserved.
//

import UIKit

class MeasurementsController: UITableViewController, CreateMeasurementControllerDelegate {
    
    var session: Session?
    var measurements = [Measurement]()
    let cellId = "cellId"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let date = session?.date {
            let stringDate = dateToString(date: date)
            navigationItem.title = stringDate
        } else {
            navigationItem.title = "No date"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let orderedMeasurements = session?.measurements?.sortedArray(using: [NSSortDescriptor(key: "date", ascending: false)]) as? [Measurement] {
            measurements = orderedMeasurements
        } else { measurements = [] }
        
        setupUI()
    }
    
    func setupUI() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        setupPlusButtonInNavBar(selector: #selector(handleAdd))
    }
    @objc fileprivate func handleAdd() {
        let createMeasurementController = CreateMeasurementController()
        createMeasurementController.delegate = self
        createMeasurementController.session = session
        let navController = UINavigationController(rootViewController: createMeasurementController)
        present(navController, animated: true, completion: nil)
    }
    
    // MARK: UITableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.backgroundColor = .paleBlue
        cell.textLabel?.text = measurements[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return measurements.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let measurementController = MeasurementController()
        navigationController?.pushViewController(measurementController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No measurements available..."
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.numberOfRows(inSection: 0) == 0 ? 150 : 0
    }
    
    // MARK: Delegate
    func didAddMeasurement(measurement: Measurement) {
        measurements.insert(measurement, at: 0)
        
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [indexPath], with: .top)
        self.tableView.endUpdates()
    }
    
    func didEditMeasurement(measurement: Measurement) {
        print("Edited measurement with name: \(measurement.name ?? "no name found")")
    }
}

