//
//  OTPVerificationVC.swift
//  Sofia
//
//  Created by Admin on 01/02/23.
//

import UIKit
import FirebaseAuth
import MBProgressHUD
import FirebaseDatabase

class OTPVerificationVC: UIViewController {
    
    @IBOutlet weak var cOneOtpView: UIView!
    @IBOutlet weak var cTwoOtpView: UIView!
    @IBOutlet weak var cThreeOtpView: UIView!
    @IBOutlet weak var cFourOtpView: UIView!
    @IBOutlet weak var cFiveOtpView: UIView!
    @IBOutlet weak var cSixOtpView: UIView!
    
    @IBOutlet weak var tOneOtpField: UITextField!
    @IBOutlet weak var tTwoOtpField: UITextField!
    @IBOutlet weak var tThreeOtpField: UITextField!
    @IBOutlet weak var tFourOtpField: UITextField!
    @IBOutlet weak var tFiveOtpField: UITextField!
    @IBOutlet weak var tSixOtpField: UITextField!
    
    @IBOutlet weak var mobileNumberLabel: UILabel!
    
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var resendCodeTimerLabel: UILabel!
    
    var resendCodeCounter = 30
    var resendCodeTimer = Timer()
    
    var countyCode = String()
    var mobileNumber = String()
    var verificationID = String()
    
    var otpEntred = String()
    
    //MARK:- viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tOneOtpField.delegate = self
        tTwoOtpField.delegate = self
        tThreeOtpField.delegate = self
        tFourOtpField.delegate = self
        tFiveOtpField.delegate = self
        tSixOtpField.delegate = self
        
        tOneOtpField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        tTwoOtpField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        tThreeOtpField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        tFourOtpField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        tFiveOtpField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        tSixOtpField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        tOneOtpField.becomeFirstResponder()
    }
    
    //MARK:- viewWillAppear()
    override func viewWillAppear(_ animated: Bool) {
        mobileNumberLabel.text = "We've sent an SMS with an activation code to your phone \(countyCode) \(mobileNumber)"
        
        setupViewBorder(view: cOneOtpView)
        setupViewBorder(view: cTwoOtpView)
        setupViewBorder(view: cThreeOtpView)
        setupViewBorder(view: cFourOtpView)
        setupViewBorder(view: cFiveOtpView)
        setupViewBorder(view: cSixOtpView)
        
        resendBtn.isEnabled = false
        resendCodeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimerLabel), userInfo: nil, repeats: true)
    }
    
    //MARK:- navBackAct()
    @IBAction func navBackAct(_ sender: UIButton)
    {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- resendBtnAct()
    @IBAction func resendBtnAct(_ sender: UIButton)
    {
        resendCodeCounter = 31
        resendBtn.isEnabled = false
        let phoneNumber = countyCode + mobileNumber
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                self.SimpleAlert(Alertmessage: error.localizedDescription)
            }
            guard let verificationID = verificationID else { return }
            self.verificationID = verificationID
            self.showToast(message: "OTP re-sent successfully.")
            self.resendCodeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimerLabel), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateTimerLabel()
    {
        resendCodeCounter -= 1
        resendCodeTimerLabel.text = "Resend code in \(resendCodeCounter) seconds."
        if resendCodeCounter == 0 {
          resendBtn.isEnabled = true
          resendCodeTimer.invalidate()
        }
      }
    
    //MARK:- ObjC textFieldDidChage()
    @objc func textFieldDidChange(textField: UITextField)
    {
        let text = textField.text
        
        if  text?.count == 1
        {
            switch textField
            {
            case tOneOtpField:
                tTwoOtpField.becomeFirstResponder()
            case tTwoOtpField:
                tThreeOtpField.becomeFirstResponder()
            case tThreeOtpField:
                tFourOtpField.becomeFirstResponder()
            case tFourOtpField:
                tFiveOtpField.becomeFirstResponder()
            case tFiveOtpField:
                tSixOtpField.becomeFirstResponder()
            case tSixOtpField:
                tSixOtpField.resignFirstResponder()
                validateOTP()
            default:
                break
            }
        }
    }
    
    //MARK:- setupViewBorder()
    func setupViewBorder(view: UIView)
    {
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.75
        view.layer.cornerRadius = 8
        view.backgroundColor = .clear
    }
    
    //MARK:- validateOTP()
    func validateOTP()
    {
        view.endEditing(true)
        if tOneOtpField.text != "" && tTwoOtpField.text != "" && tThreeOtpField.text != "" && tFourOtpField.text != "" && tFiveOtpField.text != "" && tSixOtpField.text != ""
        {
            self.otpEntred = "\(tOneOtpField.text!)\(tTwoOtpField.text!)\(tThreeOtpField.text!)\(tFourOtpField.text!)\(tFiveOtpField.text!)\(tSixOtpField.text!)"
            self.verifyOTP()
        }
        else
        {
            self.showToast(message: "Please Enter OTP")
        }
    }
    
    //MARK:- verifyOTP()
    func verifyOTP()
    {
        view.endEditing(true)
        let credential = PhoneAuthProvider.provider().credential(
          withVerificationID: verificationID,
          verificationCode: otpEntred
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
                
                UserDefaults.standard.set(true, forKey: UserDetails.newPhoneNumber)
            }
            else
            {
                self.getUserDetails(userID: userID)
                UserDefaults.standard.set(false, forKey: UserDetails.newPhoneNumber)
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
}

//MARK:- TextFieldDelegates
extension OTPVerificationVC: UITextFieldDelegate
{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
}
