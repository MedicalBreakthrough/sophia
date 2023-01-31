//
//  OTPLoginVC.swift
//  Sofia
//
//  Created by Admin on 30/01/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MBProgressHUD
import SKCountryPicker

class OTPLoginVC: UIViewController {
    
    @IBOutlet weak var mobileNumberTextField: UITextField!
    
    @IBOutlet weak var countryBtn: UIButton!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var otpTextField: UITextField!
    var countryCode = ""
    var verificationID = String()
    var verificationCode = String()
    
    //MARK:- viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let country = CountryManager.shared.currentCountry else {
            return
        }
        
        self.countryCode = "+1"
        self.countryBtn.setTitle(self.countryCode, for: .normal)
        
        
    }
    
    //MARK:- viewWillAppear()
    override func viewWillAppear(_ animated: Bool) {
        otpView.isHidden = true
        mobileNumberTextField.becomeFirstResponder()
    }
    
    //MARK:- navBackAct()
    @IBAction func navBackAct(_ sender: UIButton)
    {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- countryBtnAction()
    @IBAction func countryBtnAction(_ sender: Any) {

        presentCountryPickerScene(withSelectionControlEnabled: true)
    }
    
    
    //MARK:- getOtpBtnAct()
    @IBAction func getOtpBtnAct(_ sender: UIButton)
    {
        if mobileNumberTextField.text != ""
        {
            sendOTP()
        }
        else
        {
            self.showToast(message: "Enter mobile number to proceed.")
        }
    }
    
    //MARK:- verifyOtpBtnAct()
    @IBAction func verifyOtpBtnAct(_ sender: UIButton)
    {
        if otpTextField.text != ""
        {
            if otpTextField.text!.count == 6
            {
                self.verifyOTP()
            }
            else
            {
                self.showToast(message: "Wrong OTP Enterd.")
            }
        }
        else
        {
            self.showToast(message: "Enter OTP to proceed.")
        }
    }
    
    //MARK:- sendOTP()
    func sendOTP()
    {
        if self.countryCode == ""{
            let alert = UIAlertController(title: "Alert", message: "Please select country code.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { UIAlertAction in
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let phoneNumber = self.countryCode + mobileNumberTextField.text!
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    self.SimpleAlert(Alertmessage: error.localizedDescription)
                }
                guard let verificationID = verificationID else { return }
                self.verificationID = verificationID
                //            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                self.showToast(message: "OTP sent successfully.")
                self.otpView.isHidden = false
                self.otpTextField.becomeFirstResponder()
            }
        }
    }
    
    //MARK:- verifyOTP()
    func verifyOTP()
    {
        view.endEditing(true)
        verificationCode = otpTextField.text!
        let credential = PhoneAuthProvider.provider().credential(
          withVerificationID: verificationID,
          verificationCode: verificationCode
        )
        
        Auth.auth().signIn(with: credential) { authResult, error in
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
        ref.child("users").child(userID).child("userDetails").setValue(["userId": userID, "userName": userName, "userEmail":userEmail, "phoneNumber":phoneNumber, "profilePicUrl": profilePic, "loginType": "phone"]) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                MBProgressHUD.hide(for: self.view, animated: true)
                print("Data could not be saved: \(error).")
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
                UserDefaults.standard.setValue(userID, forKey: UserDetails.userId)
                UserDefaults.standard.setValue(userName, forKey: UserDetails.userName)
                UserDefaults.standard.setValue(userEmail, forKey: UserDetails.userMailID)
                UserDefaults.standard.setValue(phoneNumber, forKey: UserDetails.userPhoneNo)
                self.navigationToHome(status: "new")
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
            UserDefaults.standard.set(value?["phoneNumber"], forKey: UserDetails.userPhoneNo)
            UserDefaults.standard.set(value?["userName"], forKey: UserDetails.userName)
            navigationToHome(status: "old")
        })
    }
    
    //MARK:- navigationToHome()
    func navigationToHome(status: String)
    {
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
        homeVC.status = status
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    func presentCountryPickerScene(withSelectionControlEnabled selectionControlEnabled: Bool = true) {
        switch selectionControlEnabled {
        case true:
            // Present country picker with `Section Control` enabled
            CountryPickerWithSectionViewController.presentController(on: self, configuration: { countryController in
                countryController.configuration.flagStyle = .circular
//                countryController.configuration.isCountryFlagHidden = !showCountryFlagSwitch.isOn
//                countryController.configuration.isCountryDialHidden = !showDialingCodeSwitch.isOn
                countryController.favoriteCountriesLocaleIdentifiers = ["IN", "US"]

            }) { [weak self] country in
                
                guard let self = self else { return }
//                self.countryImageView.isHidden = false
//                self.countryImageView.image = country.flag
                self.countryCode = country.dialingCode ?? ""
                self.countryBtn.setTitle(country.dialingCode, for: .normal)
            }
            
        case false:
            // Present country picker without `Section Control` enabled
            CountryPickerController.presentController(on: self, configuration: { countryController in
                countryController.configuration.flagStyle = .corner
//                countryController.configuration.isCountryFlagHidden = !showCountryFlagSwitch.isOn
//                countryController.configuration.isCountryDialHidden = !showDialingCodeSwitch.isOn
                countryController.favoriteCountriesLocaleIdentifiers = ["IN", "US"]

            }) { [weak self] country in
                
                guard let self = self else { return }
                
//                self.countryImageView.isHidden = false
//                self.countryImageView.image = country.flag
                self.countryCode = country.dialingCode ?? ""
                self.countryBtn.setTitle(country.dialingCode, for: .normal)
            }
        }
    }
}

