//
//  LandingViewController.swift
//  Sofia
//
//  Created by Mac on 06/01/2023.
//

import UIKit

class LandingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        let userId = UserDefaults.standard.string(forKey: UserDetails.userId) ?? ""
        if userId != ""
        {
            self.navHome()
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
