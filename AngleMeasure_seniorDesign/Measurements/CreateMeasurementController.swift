//
//  CreateMeasurementController.swift
//  AngleMeasure_seniorDesign
//
//  Created by Nathan Greene on 1/21/19.
//  Copyright © 2019 Nathan Greene. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

//UI Elements for Real Time Measurement
    // Bar: Cancel and Save
    // Start -> Stop -> nameLabel/TextField
    // Current angle display (only if applicable)
    // Acheived range of motion (only if applicable)

//UI Elements for Download Measurement
    // Bar: Cancel and Save
    // Start -> Stop -> Download -> nameLabel/TextField

protocol CreateMeasurementControllerDelegate {
    func didAddMeasurement(measurement: Measurement, session: Session)
    func didEditMeasurement(measurement: Measurement)
}

class CreateMeasurementController: UIViewController, CoreBluetoothDelegate, AngleCalculatorDelegate {
    
    var bluetoothManager : CoreBluetoothManager = CoreBluetoothManager.shared
    var angleCalculator = AngleCalculator()
    var delegate: CreateMeasurementControllerDelegate?
    var angles = [Double]()
    var measurement: Measurement?
    var session: Session?
    var currentRangeOfMotion: Double = 0.0

    lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .navyBlue
        button.setTitle("Start!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleStart), for: .touchUpInside)
        button.isHidden = false
        return button
    }()
    @objc func handleStart() {
        if bluetoothManager.myPeripherals.count == 2 { //both HM10s are connected
            bluetoothManager.doReading = true
            bluetoothManager.discoverCharacteristics()
            stopButton.isHidden = false //show stop button after we have started
            startButton.isHidden = true
        } else {
            showError(title: "HM10 not connected", message: "Please make sure both HM10's are powered on")
            return
        }
    }
    
    lazy var stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .red
        button.setTitle("Stop!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleStop), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    @objc func handleStop() {
        bluetoothManager.stopScanPeripheral()
        bluetoothManager.disconnectPeripherals()
        bluetoothManager.doReading = false
        nameLabel.isHidden = false
        nameTextField.isHidden = false
        stopButton.isHidden = true
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name:"
        label.translatesAutoresizingMaskIntoConstraints = false //enable autolayout
        label.isHidden = true
        return label
    }()
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter measurement name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isHidden = true
        return textField
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        initBluetooth()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = measurement == nil ? "Take Measurement" : "Edit Measurement"
        if measurement == nil {
            bluetoothManager.startScanPeripheral()
        }
        setupUI()
    }
    
    fileprivate func initBluetooth() {
        bluetoothManager.delegate = self
        angleCalculator.delegate = self
    }
    
    fileprivate func setupUI() {
        
        view.backgroundColor = .blackBrown
        
        if let existingMeasurement = measurement {
            nameTextField.text = existingMeasurement.name
            nameTextField.isHidden = false
            nameLabel.isHidden = false
            startButton.isHidden = true
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        setupSaveButtonInNavBar(selector: #selector(handleSave))
        
        _ = setupPaleBlueBackground(height: 76)
        
        view.addSubview(startButton)
        _ = startButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 60)
        
        view.addSubview(stopButton)
        _ = stopButton.anchor(startButton.topAnchor, left: startButton.leftAnchor, bottom: startButton.bottomAnchor, right: startButton.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        view.addSubview(nameLabel)
        nameLabel.centerYAnchor.constraint(equalTo: startButton.centerYAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: startButton.leftAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        view.addSubview(nameTextField)
        nameTextField.centerYAnchor.constraint(equalTo: startButton.centerYAnchor).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: nameLabel.rightAnchor).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: startButton.rightAnchor).isActive = true
    }
    @objc func handleCancel() {
        bluetoothManager.stopScanPeripheral()
        bluetoothManager.disconnectPeripherals()
        bluetoothManager.doReading = false
        dismiss(animated: true, completion: nil)
    }
    @objc fileprivate func handleSave() {
        if measurement == nil {
            createMeasurement()
        } else {
            saveMeasurementChanges()
        }
    }
    
    fileprivate func createMeasurement() {
        guard let measurementName = nameTextField.text else { return }
        guard let session = session else { return }
        let date = Date()
        let values = angles.compactMap { $0 } //eliminate nil elements
        
        if measurementName.isEmpty {
            showError(title: "No name found", message: "Please enter a name in the text field.")
        } else {
            let context = CoreDataManager.shared.persistentContainer.viewContext
            
            let measurement = NSEntityDescription.insertNewObject(forEntityName: "Measurement", into: context)
            
            measurement.setValue(measurementName, forKey: "name")
            measurement.setValue(session, forKey: "session")
            measurement.setValue(date, forKey: "date")
            measurement.setValue(values, forKey: "angles")
            measurement.setValue(currentRangeOfMotion, forKey: "rangeOfMotion")
            
            //ALERTT : BIG CHANGE HERE
            if currentRangeOfMotion > session.maxRangeOfMotion {
                session.maxRangeOfMotion = currentRangeOfMotion
            }
            
            do {
                try context.save()
                
                // success
                dismiss(animated: true) {
                    self.delegate?.didAddMeasurement(measurement: measurement as! Measurement, session: session)
                }
            } catch let saveErr {
                print("Failed to save measurement: \(saveErr)")
            }
        }
    }
    fileprivate func saveMeasurementChanges() {
        guard let measurementName = nameTextField.text else { return }
        
        if measurementName.isEmpty {
            showError(title: "No name found", message: "Please enter a name in the text field.")
        } else {
            let context = CoreDataManager.shared.persistentContainer.viewContext
            
            measurement?.name = measurementName
            
            do {
                try context.save()
                
                // success
                dismiss(animated: true) {
                    self.delegate?.didEditMeasurement(measurement: self.measurement!)
                }
            } catch let saveErr {
                print("Failed to save measurement: \(saveErr)")
            }
        }
    }
    
    fileprivate func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Delegates
    func didReadValueForCharacteristic(_ peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        angleCalculator.calculateAngle(peripheral, characteristic: characteristic)
    }
    
    func didCalculateAngle(angle: Double) {
        let angleAdjustedByThirty = angle - 30.5
        let doubleStr = String(format: "%.2f", angleAdjustedByThirty)
//        print(doubleStr)
        self.angles.append(angleAdjustedByThirty)
        checkRangeOfMotion(currentAngle: angleAdjustedByThirty)
    }
    
    //MARK: - Custom Functions
    func checkRangeOfMotion(currentAngle: Double) {
        if currentAngle > currentRangeOfMotion {
            currentRangeOfMotion = currentAngle
            let doubleStr = String(format: "%.2f", currentAngle)
            stopButton.setTitle(doubleStr, for: .normal)
        }
//        let doubleStr = String(format: "%.2f", currentAngle)
//        stopButton.setTitle(doubleStr, for: .normal)
    }
}







//angular move
