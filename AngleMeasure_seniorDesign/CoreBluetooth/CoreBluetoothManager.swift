//
//  CoreBluetoothManager.swift
//  AngleMeasure_seniorDesign
//
//  Created by Nathan Greene on 2/1/19.
//  Copyright © 2019 Nathan Greene. All rights reserved.
//

import CoreBluetooth

protocol CoreBluetoothDelegate : NSObjectProtocol {
    func didReadValueForCharacteristic(_ peripheral: CBPeripheral, characteristic: CBCharacteristic)
}

class CoreBluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager : CBCentralManager?
    static var shared : CoreBluetoothManager {
        return sharedInstance
    }
    private static let sharedInstance = CoreBluetoothManager()
    
    var delegate : CoreBluetoothDelegate?
    var doReading = false
    
    var state: CBManagerState? {
        guard centralManager != nil else {
            return nil
        }
        return CBManagerState(rawValue: (centralManager?.state.rawValue)!)
    }
    
    private override init() {
        super.init()
        initCBCentralManager()
    }
    
    func initCBCentralManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    // MARK: - Properties
    let imuCBUUID = CBUUID(string: "FFE0")
    let imuCBUUIDpostConnected = CBUUID(string: "FFE1")
    
    var connectingPeripheral: CBPeripheral!
    var myPeripherals = [String:CBPeripheral]()
    var discoveredPeripheral:CBPeripheral!
    
    // MARK: - Delegate
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
        }
        print(central.state)
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        guard let peripheralName = peripheral.name else { return }
        if (( peripheralName == "SH-HC-08") && (myPeripherals[peripheralName] == nil)) {
            myPeripherals[peripheralName] = peripheral
            myPeripherals[peripheralName]?.delegate = self
            centralManager?.connect(myPeripherals[peripheralName]!, options: nil)
        } else if (( peripheral.name == "DSD TECH")  && (myPeripherals[peripheral.name!] == nil)) {
            myPeripherals[peripheralName] = peripheral
            myPeripherals[peripheralName]?.delegate = self
            centralManager?.connect(myPeripherals[peripheralName]!, options: nil)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Bluetooth Manager --> didConnectPeripheral \(peripheral.name ?? "No name")")
        guard let peripheralName = peripheral.name else { return }
        myPeripherals[peripheralName]?.discoverServices([imuCBUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print("Service:: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("Bluetooth Manager --> Fail to discover characteristics! Error: \(error?.localizedDescription ?? "")")
            return
        }
        
        if doReading {
            print("didDiscoverCharacteristicsFor -->> READING")
            guard let characteristics = service.characteristics else { return }
            
            for characteristic in characteristics {
                print(characteristic)
                if characteristic.properties.contains(.read) {
                    print("\(characteristic.uuid): properties contains .read")
                    peripheral.readValue(for: characteristic)
                }
                if characteristic.properties.contains(.notify) {
                    print("\(characteristic.uuid): properties contains .notify")
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        } else {
            print("didDiscoverCharacteristicsFor -->> NOT READING YET")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("Bluetooth Manager --> Failed to read value for the characteristic. Error:\(error!.localizedDescription)")
            return
        }
        delegate?.didReadValueForCharacteristic(peripheral, characteristic: characteristic)
    }
    
    // MARK: Custom functions
    func startScanPeripheral() {
        print("Starting to scan for peripheral bluetooth devices")
        centralManager?.scanForPeripherals(withServices: [imuCBUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
    }
    
    func stopScanPeripheral() {
        print("Stop scanning for peripheral bluetooth devices")
        centralManager?.stopScan()
    }
    
    func disconnectPeripherals() {
        print("disconnecting peripherals")
        for peripheral in myPeripherals.values {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        myPeripherals = [String: CBPeripheral]()
    }
    
    func discoverCharacteristics() {
        for peripheral in myPeripherals.values {
            let services = peripheral.services
            if services == nil || services!.count < 1 { // Validate service array
                return;
            }
            for service in services! {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
}

