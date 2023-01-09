//
//  HomeViewController.swift
//  Sofia
//
//  Created by Mac on 05/01/2023.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
}
