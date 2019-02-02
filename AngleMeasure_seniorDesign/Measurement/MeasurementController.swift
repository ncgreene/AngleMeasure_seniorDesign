//
//  MeasurementController.swift
//  AngleMeasure_seniorDesign
//
//  Created by Nathan Greene on 1/18/19.
//  Copyright © 2019 Nathan Greene. All rights reserved.
//

import UIKit

class MeasurementController: UIViewController {
    
    var measurement: Measurement?
    
    lazy var rangeOfMotionLabel: UILabel = {
        let label = UILabel()
        if let rangeOfMotion = measurement?.rangeOfMotion {
            let formattedRoM = String(format: "%.2f", rangeOfMotion)
            label.text = "Range of Motion: \(formattedRoM)"
        } else {
            label.text = "Range of Motion: n/a)"
        }
        label.textColor = .darkBrown
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Information"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .blackBrown
        let paleBlueBackground = setupPaleBlueBackground(height: 70)
        
        view.addSubview(rangeOfMotionLabel)
        rangeOfMotionLabel.anchor(paleBlueBackground.topAnchor, left: paleBlueBackground.leftAnchor, bottom: nil, right: paleBlueBackground.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 50)
    }
}
