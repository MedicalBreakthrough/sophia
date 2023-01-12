//
//  SettingsViewController.swift
//  Sofia
//
//  Created by Mac on 06/01/2023.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure want to Logout?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { UIAlertAction in
            self.logoutAct()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- logoutAct()
    func logoutAct()
    {
        UserDefaults.standard.removeObject(forKey: UserDetails.userId)
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(loginVC, animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
