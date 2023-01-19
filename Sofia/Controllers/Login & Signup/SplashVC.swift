//
//  SplashVC.swift
//  Sofia
//
//  Created by Admin on 19/01/23.
//

import UIKit

class SplashVC: UIViewController {
    
    var userId = String()
    
    //MARK:- viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK:- viewWillAppear()
    override func viewWillAppear(_ animated: Bool) {
        userId = UserDefaults.standard.string(forKey: UserDetails.userId) ?? ""
        
        if userId != ""
        {
            self.navigationToHome()
        }
        else
        {
            self.navigationLogin()
        }
    }
    
    //MARK:- navigationToHome()
    func navigationToHome()
    {
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    //MARK:- navigationLogin()
    func navigationLogin()
    {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
}
