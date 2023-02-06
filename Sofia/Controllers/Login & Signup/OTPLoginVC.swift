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
    var countryCode = ""
    var verificationID = String()
    
    //MARK:- viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let country = CountryManager.shared.currentCountry else {
            return
        }
        
        self.countryCode = country.dialingCode ?? ""
        self.countryBtn.setTitle(self.countryCode, for: .normal)
    }
    
    //MARK:- viewWillAppear()
    override func viewWillAppear(_ animated: Bool) {
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
    
    //MARK:- sendOTP()
    func sendOTP()
    {
        if self.countryCode == ""{
            let alert = UIAlertController(title: "Alert", message: "Please select country code.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { UIAlertAction in
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            let phoneNumber = self.countryCode + mobileNumberTextField.text!
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.SimpleAlert(Alertmessage: error.localizedDescription)
                }
                guard let verificationID = verificationID else { return }
                self.verificationID = verificationID
                //            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                self.showToast(message: "OTP sent successfully.")
                MBProgressHUD.hide(for: self.view, animated: true)
                self.navOtpVC()
            }
        }
    }
    
    //MARK:- navOtpVC()
    func navOtpVC()
    {
        let otpVC = storyboard?.instantiateViewController(withIdentifier: "OTPVerificationVC") as! OTPVerificationVC
        otpVC.countyCode = countryCode
        otpVC.mobileNumber = mobileNumberTextField.text!
        otpVC.verificationID = verificationID
        navigationController?.pushViewController(otpVC, animated: true)
    }
    
    func presentCountryPickerScene(withSelectionControlEnabled selectionControlEnabled: Bool = false) {
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

