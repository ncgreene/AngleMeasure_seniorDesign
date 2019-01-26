//
//  SummaryController.swift
//  AngleMeasure_seniorDesign
//
//  Created by Nathan Greene on 1/25/19.
//  Copyright © 2019 Nathan Greene. All rights reserved.
//

import UIKit

class SummaryController: UIViewController {
    
    var patient: Patient?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "\(patient?.name ?? "No name's")'s Summary"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
    
    func setupUI() {
        view.backgroundColor = .darkBrown
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))
        
        print("Need to add graphical interface here")
    }
    @objc fileprivate func handleDone() {
        dismiss(animated: true, completion: nil)
    }
}
