//
//  SettingsViewController.swift
//  Sofia
//
//  Created by Mac on 06/01/2023.
//

import UIKit
import FirebaseAuth
import Kingfisher
import FirebaseDatabase
import MBProgressHUD

class SettingsViewController: UIViewController, UITextFieldDelegate  {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var emailTF: UITextField!
    
    var userId = String()
    var userName = String()
    var userEmail = String()
    var profilePic = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
        self.nameTF.delegate = self
        self.emailTF.delegate = self
        
        userId = UserDefaults.standard.string(forKey: UserDetails.userId) ?? ""
        
        getUserDetails()
        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
           print("TextField did begin editing method called")
       }
       func textFieldDidEndEditing(_ textField: UITextField) {
           
           
                      
           print("TextField did end editing method called\(self.nameTF.text!)")
           
       }
       func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
           print("TextField should begin editing method called")
           return true
       }
       func textFieldShouldClear(_ textField: UITextField) -> Bool {
           print("TextField should clear method called")
           return true
       }
       func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
           

           print("TextField should end editing method called,\(self.nameTF.text!)")
           
           if textField == self.nameTF{
               self.nameTF.text = textField.text
           }
           else{
               self.emailTF.text = textField.text
           }
           return true
       }
       func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           print("While entering the characters this method gets called")
           return true
       }
       func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           print("TextField should return method called")
           textField.resignFirstResponder()
           return true
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
    
    @IBAction func saveButtonAction(_ sender: Any) {
        
        if self.nameTF.text == "" || self.emailTF.text == ""{
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            let alert = UIAlertController(title: "Alert", message: "Name and Email should not ne empty.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { UIAlertAction in
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            updateUserDetails(userName: self.nameTF.text!, userEmail: self.emailTF.text!)
        }
        
        
    }
    
    
    @IBAction func logoutAction(_ sender: Any) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.openAlert(title: "Alert", message: "Are you sure want to Logout?",alertStyle: .alert,
                              actionTitles: ["Cancel", "Ok"],actionStyles: [.cancel, .default],
                              actions: [
                                  {_ in
                                       print("cancel click")
                                  },
                                  {_ in
                                       print("Okay click")
                                      self.logoutAct()
                                  }
                             ])
        
    }
    
     //MARK:- getUserDetails()
    func getUserDetails()
    {
       
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let ref = Database.database(url: "https://sofia-67890-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
        ref.child("users").child(userId).child("userDetails").getData(completion:  { [self] error, snapshot in
            guard error == nil else {
                MBProgressHUD.hide(for: self.view, animated: true)
                print(error!.localizedDescription)
                return
            }
            MBProgressHUD.hide(for: self.view, animated: true)
            let value = snapshot?.value as? NSDictionary
            self.userName = value?["userName"] as? String ?? ""
            self.userEmail = value?["userEmail"] as? String ?? ""
            self.profilePic = value?["profilePicUrl"] as? String ?? ""
            
            self.nameTF.text = self.userName
            self.emailTF.text = userEmail
            
            if self.profilePic != ""{
                let imageUrl = URL(string: self.profilePic)
                self.profileImageView.kf.setImage(with: imageUrl)
            }
            else{
                self.profileImageView.image = UIImage(named: "ProfileDefultImage")
            }
        })
        
    }
    
    //MARK:- updateUserDetails()
        func updateUserDetails(userName: String, userEmail: String)
        {
            let updates = ["userId": userId, "userName": userName, "userEmail":userEmail, "profilePicUrl": profilePic] as [String : Any]
            let ref = Database.database(url: "https://sofia-67890-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
            ref.child("users").child(userId).child("userDetails").updateChildValues(updates);
        }
    
}
