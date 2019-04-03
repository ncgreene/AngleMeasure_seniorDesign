//
//  AngleCalculator.swift
//  AngleMeasure_seniorDesign
//
//  Created by Nathan Greene on 2/1/19.
//  Copyright © 2019 Nathan Greene. All rights reserved.
//

import UIKit
import CoreBluetooth
import GLKit

protocol AngleCalculatorDelegate {
    func didCalculateAngle(angle: Double)
}

class AngleCalculator {
    
    var delegate: AngleCalculatorDelegate?
    
    let imuCBUUIDpostConnected = CBUUID(string: "FFE1")
    
    var LL_value : String = "ENDL"
    var UL_value : String = "ENDL"
    var LL_strQuat : [String] = ["0", "0", "0", "0"]
    var UL_strQuat : [String] = ["0", "0", "0", "0"]
    
    var LL_quaternion: GLKQuaternion = GLKQuaternionMake(0.0,0.0,0.0,0.0)
    var UL_quaternion: GLKQuaternion = GLKQuaternionMake(0.0,0.0,0.0,0.0)
    var UL_inv_quaternion: GLKQuaternion = GLKQuaternionMake(0.0,0.0,0.0,0.0)
    var angle_quaternion: GLKQuaternion = GLKQuaternionMake(0.0,0.0,0.0,0.0)
    var angle: Double = 0.00
    
    func calculateAngle(_ peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        
        if characteristic.uuid == imuCBUUIDpostConnected {
            
            guard let characteristicValue = characteristic.value else { return }
            let characteristicData = Data(characteristicValue)
            if let unfilteredLine = String(data: characteristicData) {
                
                if (peripheral.name == "SH-HC-08") {
                    LL_value += unfilteredLine
                    
                } else if ( peripheral.name == "DSD TECH") {
                    UL_value += unfilteredLine
                }
                
                if ((LL_value.range(of:"ENDL") != nil) && (peripheral.name == "SH-HC-08")) {
                    LL_value.removeLast(5)
                    LL_value = String(LL_value.filter { !"\r\n".contains($0) })
                    print(LL_value)
                    LL_strQuat = strToQuat(text: LL_value)
                    angle = calcAngle(LLstrQuat: LL_strQuat, ULstrQuat: UL_strQuat, oldAngle: angle)
                    delegate?.didCalculateAngle(angle: angle)
                    //                    print("RESETTING lower leg")
                    LL_value = ""
                } else if ((UL_value.range(of:"ENDL") != nil) && (peripheral.name == "DSD TECH")) {
                    UL_value.removeLast(5)
                    UL_value = String(UL_value.filter { !"\r\n".contains($0) })
                    print(UL_value)
                    UL_strQuat = strToQuat(text: UL_value)
                    angle = calcAngle(LLstrQuat: LL_strQuat, ULstrQuat: UL_strQuat, oldAngle: angle)
                    delegate?.didCalculateAngle(angle: angle)
                    //                    print("RESETTING upper leg")
                    UL_value = ""
                }
            } else { print("empty data for characteristic") }
        } else {
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    func strToQuat(text: String) -> [String] {
        guard let x_index = text.firstIndex(of: "X") else {return ["0.0", "0.0", "0.0", "0.0"]}
        guard let y_index = text.firstIndex(of: "Y") else {return ["0.0", "0.0", "0.0", "0.0"]}
        guard let z_index = text.firstIndex(of: "Z") else {return ["0.0", "0.0", "0.0", "0.0"]}
        guard let w_index = text.firstIndex(of: "W") else {return ["0.0", "0.0", "0.0", "0.0"]}
        
        let x_range = text.index((x_index), offsetBy: 3)..<(text.index((y_index), offsetBy: 0))
        let x = String(text[x_range])
        let y_range = text.index((y_index), offsetBy: 3)..<(text.index((z_index), offsetBy: 0))
        let y = String(text[y_range])
        let z_range = text.index((z_index), offsetBy: 3)..<(text.index((w_index), offsetBy: 0))
        let z = String(text[z_range])
        let w_range = text.index((w_index), offsetBy: 3)..<(text.endIndex)
        let w = String(text[w_range])
        
        return [x, y, z, w]
    }
    
    func calcAngle(LLstrQuat: [String], ULstrQuat: [String], oldAngle: Double) -> Double {
        
        guard let LL_xValue = Float(LLstrQuat[0])else { return oldAngle }
        guard let LL_yValue = Float(LLstrQuat[1]) else { return oldAngle }
        guard let LL_zValue = Float(LLstrQuat[2]) else { return oldAngle }
        guard let LL_wValue = Float(LLstrQuat[3]) else { return oldAngle }
        
        guard let UL_xValue = Float(ULstrQuat[0]) else { return oldAngle }
        guard let UL_yValue = Float(ULstrQuat[1]) else { return oldAngle }
        guard let UL_zValue = Float(ULstrQuat[2]) else { return oldAngle }
        guard let UL_wValue = Float(ULstrQuat[3]) else { return oldAngle }
        
        let LL_quaternion = GLKQuaternionMake(LL_xValue, LL_yValue, LL_zValue, LL_wValue)
        let UL_quaternion = GLKQuaternionMake(UL_xValue, UL_yValue, UL_zValue, UL_wValue)
        
        let UL_invQuaternion = GLKQuaternionInvert(UL_quaternion)
        let angleQuaternion = GLKQuaternionMultiply(LL_quaternion, UL_invQuaternion)
        
        let newAngle = Double(GLKQuaternionAngle(angleQuaternion)) * 180 / .pi
        
        return newAngle
    }
}

// MARK: Data -> String
protocol DataConvertible {
    init?(data: Data)
    var data: Data { get }
}

extension DataConvertible {
    
    init?(data: Data) {
        guard data.count == MemoryLayout<Self>.size else { return nil }
        self = data.withUnsafeBytes { $0.pointee }
    }
    
    var data: Data {
        return withUnsafeBytes(of: self) { Data($0) }
    }
}

extension String: DataConvertible {
    init?(data: Data) {
        self.init(data: data, encoding: .utf8)
    }
    var data: Data {
        // Note: a conversion to UTF-8 cannot fail.
        return self.data(using: .utf8)!
    }
}
