//
//  HomeTabBarController.swift
//  Sofia
//
//  Created by Mac on 06/01/2023.
//

import UIKit
import FirebaseAuth

class HomeTabBarController: UITabBarController,UITabBarControllerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController)!
            if selectedIndex == 1{
                if UIImagePickerController.isSourceTypeAvailable(.camera)
                {
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera
                    imagePicker.allowsEditing = true
                    present(imagePicker, animated: true, completion: nil)
                }
            }
        }
}
