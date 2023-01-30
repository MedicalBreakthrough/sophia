//
//  EmailLoginVC.swift
//  Sofia
//
//  Created by Admin on 30/01/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MBProgressHUD

class EmailLoginVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
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
    
    //MARK:-  loginBtnAct()
    @IBAction func loginBtnAct(_ sender: UIButton)
    {
        if emailTextField.text != "" && passwordTextField.text != ""
        {
            self.emailSignin()
        }
        else
        {
            self.showToast(message: "Enter details to login.")
        }
    }
    
    //MARK:- emailSignin()
    func emailSignin()
    {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                if error.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted."
                {
                    self?.emailSignUp()
                }
                else
                {
                    self?.SimpleAlert(Alertmessage: error.localizedDescription)
                }
                return
            }
            let userID = authResult?.user.uid as? String ?? ""
            let name = authResult?.user.displayName as? String ?? ""
            let email = authResult?.user.email as? String ?? ""
            let phoneNumber = authResult?.user.phoneNumber as? String ?? ""
            let profilePic = authResult?.user.photoURL?.absoluteString ?? ""
            self?.checkUserDetails(userID: userID, userName: name, userEmail: email, phoneNumber: phoneNumber, profilePic: profilePic)
        }
    }
    
    //MARK:- emailSignUp()
    func emailSignUp()
    {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.SimpleAlert(Alertmessage: error.localizedDescription)
                return
            }
            let userID = authResult?.user.uid as? String ?? ""
            let name = authResult?.user.displayName as? String ?? ""
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
