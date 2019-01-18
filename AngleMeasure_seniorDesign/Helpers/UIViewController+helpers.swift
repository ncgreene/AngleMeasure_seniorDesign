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
    
    func setupWhiteBackground(height: CGFloat) -> UIView {
        let whiteBackgroundView = UIView()
        whiteBackgroundView.backgroundColor = .white
        whiteBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(whiteBackgroundView)
        whiteBackgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        whiteBackgroundView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        whiteBackgroundView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        whiteBackgroundView.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        return whiteBackgroundView
    }
}
