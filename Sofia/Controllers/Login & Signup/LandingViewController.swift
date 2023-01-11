//
//  LandingViewController.swift
//  Sofia
//
//  Created by Mac on 06/01/2023.
//

import UIKit
import AuthenticationServices

class LandingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        let userId = UserDefaults.standard.string(forKey: UserDetails.userId) ?? ""
        let useraGmailAccessToken = UserDefaults.standard.string(forKey: UserDetails.gmailAccessToken) ?? ""
        let userFaceBookUserID = UserDefaults.standard.string(forKey: UserDetails.faceBookUserID) ?? ""
        
        if userId != "" || useraGmailAccessToken != "" || userFaceBookUserID != ""
        {
            self.navHome()
        }
        if let appleuserID = UserDefaults.standard.string(forKey: UserDetails.appleUserId) {
                    
            // get the login status of Apple sign in for the app
            // asynchronous
            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: appleuserID, completion: {
                credentialState, error in

                switch(credentialState){
                case .authorized:
                    print("user remain logged in, proceed to another view")
                    self.performSegue(withIdentifier: "LoginToUserSegue", sender: nil)
                case .revoked:
                    print("user logged in before but revoked")
                case .notFound:
                    print("user haven't log in before")
                default:
                    print("unknown state")
                }
            })
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    @IBAction func signUpBtnAct(_ sender: UIButton)
    {
        let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.navigationController?.pushViewController(signupVC, animated: true)
    }
    
    @IBAction func signInBtnAct(_ sender: UIButton)
    {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    func navHome()
    {
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
}

extension LandingViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
