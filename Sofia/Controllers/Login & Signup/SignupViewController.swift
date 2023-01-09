//
//  SignupViewController.swift
//  Sofia
//
//  Created by Mac on 05/01/2023.
//

import UIKit
import FirebaseAuth
import MBProgressHUD

class SignupViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
//        setNeedsStatusBarAppearanceUpdate()
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        .lightContent
//    }
    
    @IBAction func siginupBtnClicked(_ sender: Any) {
        
        if (self.emailTF.text  == "" || self.passwordTF.text == "" || self.confirmPasswordTF.text == "" ) {
            let alert = UIAlertController(title: "Error", message: "please enter email and password", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        else{
            
            if (self.passwordTF.text !=  self.confirmPasswordTF.text) {
                let alert = UIAlertController(title: "Error", message: "Confirm Password didn't match", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            else
            {
                let email = emailTF.text!
                let password = passwordTF.text!
                MBProgressHUD.showAdded(to: self.view, animated: true)
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                  
                    let userId = authResult?.user.uid as? String ?? ""
                    UserDefaults.standard.setValue(userId, forKey: UserDetails.userId)
                    
                    if error != nil
                    {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        let errorMsg = error!.localizedDescription
                        let alert = UIAlertController(title: "Error", message: errorMsg, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    else
                    {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        let homeTabVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
                        self.navigationController?.pushViewController(homeTabVC, animated: true)
                    }
                    
                }
            }
        }
    }
    
    
    @IBAction func loginClicked(_ sender: Any) {
        
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
}
