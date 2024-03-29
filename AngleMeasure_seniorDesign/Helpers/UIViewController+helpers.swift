//
//  UIViewController+helpers.swift
//  AngleMeasure_seniorDesign
//
//  Created by Nathan Greene on 1/18/19.
//  Copyright © 2019 Nathan Greene. All rights reserved.
//

import UIKit

extension UIViewController {
    func setupPlusButtonInNavBar(selector: Selector) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus"), style: .plain, target: self, action: selector)
    }
    
    func setupCancelButtonInNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelModal))
    }
    @objc func handleCancelModal() {
        dismiss(animated: true, completion: nil)
    }
    
    func setupSaveButtonInNavBar(selector: Selector) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: selector)
    }
    
    func setupPaleBlueBackground(height: CGFloat) -> UIView {
        let paleBlueBackgroundView = UIView()
        paleBlueBackgroundView.backgroundColor = .paleBlue
        paleBlueBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(paleBlueBackgroundView)
        paleBlueBackgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        paleBlueBackgroundView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        paleBlueBackgroundView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        paleBlueBackgroundView.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        return paleBlueBackgroundView
    }
    
    func setupNameLabel() -> UILabel {
        let nameLabel = UILabel()
        nameLabel.text = "Name: "
        nameLabel.translatesAutoresizingMaskIntoConstraints = false //enable autolayout
        
        view.addSubview(nameLabel)
        _ = nameLabel.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 50)
        
        return nameLabel
    }
    
    func setupNameTextField(nameLabel: UILabel, name: String?) -> UITextField {
        let nameTextField = UITextField()
        if let nameText = name {
            nameTextField.text = nameText
        }
        nameTextField.placeholder = "Enter name here"
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.textAlignment = .left
        
        view.addSubview(nameTextField)
        _ = nameTextField.anchor(nameLabel.topAnchor, left: nameLabel.rightAnchor, bottom: nameLabel.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        return nameTextField
    }
    
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter() // MMM/DD/YYYY
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let dateFormattedString = dateFormatter.string(from: date)
        return dateFormattedString
    }
}
