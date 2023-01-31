//
//  EmailSignupVC.swift
//  Sofia
//
//  Created by Admin on 31/01/23.
//

import UIKit
import FirebaseAuth
import MBProgressHUD
import FirebaseDatabase

class EmailSignupVC: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var cnfmPasswordTextField: UITextField!
    
    //MARK:- viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK:- viewWillAppear()
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //MARK:- navBackAct()
    @IBAction func navBackAct(_ sender: UIButton)
    {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- signupBtnAct()
    @IBAction func signupBtnAct(_ sender: UIButton)
    {
        if userNameTextField.text != "" && emailTextField.text != "" && passwordTextField.text != "" && cnfmPasswordTextField.text != ""
        {
            if passwordTextField.text! == cnfmPasswordTextField.text!
            {
                self.emailSignUp()
            }
            else
            {
                self.showToast(message: "Password didn't match.")
            }
        }
        else
        {
            self.showToast(message: "Enter details to signup.")
        }
    }
    
    //MARK:- emailSignUp()
    func emailSignUp()
    {
        let name = userNameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.SimpleAlert(Alertmessage: error.localizedDescription)
                return
            }
            let userID = authResult?.user.uid as? String ?? ""
            let email = authResult?.user.email as? String ?? ""
            let phoneNumber = authResult?.user.phoneNumber as? String ?? ""
            let profilePic = authResult?.user.photoURL?.absoluteString ?? ""
            self.checkUserDetails(userID: userID, userName: name, userEmail: email, phoneNumber: phoneNumber, profilePic: profilePic)
        }
    }
    
    //MARK:- checkUserDetails()
    func checkUserDetails(userID: String, userName: String, userEmail: String, phoneNumber: String, profilePic: String)
    {
        let ref = Database.database(url: "https://sofia-67890-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
        ref.child("users").child(userID).child("userDetails").getData(completion:  { [self] error, snapshot in
            guard error == nil else {
                MBProgressHUD.hide(for: self.view, animated: true)
                print(error!.localizedDescription)
                return
            }
            MBProgressHUD.hide(for: self.view, animated: true)
            let value = snapshot?.value as? NSDictionary
            if value?["userId"] == nil
            {
                self.saveUserDetails(userID: userID, userName: userName, userEmail: userEmail, phoneNumber: phoneNumber, profilePic: profilePic)
            }
            else
            {
                self.getUserDetails(userID: userID)
            }
        })
    }
    
    //MARK:- saveUserDetails()
    func saveUserDetails(userID: String, userName: String, userEmail: String, phoneNumber: String, profilePic: String)
    {
        let ref = Database.database(url: "https://sofia-67890-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
        ref.child("users").child(userID).child("userDetails").setValue(["userId": userID, "userName": userName, "userEmail":userEmail, "phoneNumber":phoneNumber, "profilePicUrl": profilePic, "loginType": "email"]) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                MBProgressHUD.hide(for: self.view, animated: true)
                print("Data could not be saved: \(error).")
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
                UserDefaults.standard.setValue(userID, forKey: UserDetails.userId)
                UserDefaults.standard.setValue(userName, forKey: UserDetails.userName)
                UserDefaults.standard.setValue(userEmail, forKey: UserDetails.userMailID)
                self.navigationToHome()
            }
        }
    }
    
    //MARK:- getUserDetails()
    func getUserDetails(userID: String)
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let ref = Database.database(url: "https://sofia-67890-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
        ref.child("users").child(userID).child("userDetails").getData(completion:  { [self] error, snapshot in
            guard error == nil else {
                MBProgressHUD.hide(for: self.view, animated: true)
                print(error!.localizedDescription)
                return
            }
            MBProgressHUD.hide(for: self.view, animated: true)
            let value = snapshot?.value as? NSDictionary
            UserDefaults.standard.set(value?["userId"], forKey: UserDetails.userId)
            UserDefaults.standard.set(value?["userEmail"], forKey: UserDetails.userMailID)
            UserDefaults.standard.set(value?["userName"], forKey: UserDetails.userName)
            navigationToHome()
        })
    }
    
    //MARK:- navigationToHome()
    func navigationToHome()
    {
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
}
