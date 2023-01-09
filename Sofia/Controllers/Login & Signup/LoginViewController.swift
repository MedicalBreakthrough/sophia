//
//  ViewController.swift
//  Sofia
//
//  Created by Mac on 05/01/2023.
//

import UIKit
import FirebaseAuth
import MBProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
//        setNeedsStatusBarAppearanceUpdate()
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        .lightContent
//    }
    
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        if (self.emailTextField.text  == "" || self.passwordTextField.text == "")
        {
            let alert = UIAlertController(title: "Error", message: "please enter email and password", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        else{
            
            let email = emailTextField.text!
            let password = passwordTextField.text!
            MBProgressHUD.showAdded(to: self.view, animated: true)
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
              guard let strongSelf = self else { return }
                
                let userId = authResult?.user.uid as? String ?? ""
                UserDefaults.standard.setValue(userId, forKey: UserDetails.userId)
                
                if error != nil
                {
                    MBProgressHUD.hide(for: self!.view, animated: true)
                    let errorMsg = error!.localizedDescription
                    let alert = UIAlertController(title: "Error", message: errorMsg, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
                else
                {
                    MBProgressHUD.hide(for: self!.view, animated: true)
                    let homeVC = self?.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
                    self?.navigationController?.pushViewController(homeVC, animated: true)
                }

            }
            
            
        }
        
        
    }
}



