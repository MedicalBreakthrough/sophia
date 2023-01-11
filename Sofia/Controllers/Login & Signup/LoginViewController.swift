//
//  ViewController.swift
//  Sofia
//
//  Created by Mac on 05/01/2023.
//

import UIKit
import FirebaseAuth
import MBProgressHUD
import FirebaseCore
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import CryptoKit
import AuthenticationServices

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var gmailSigninBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
//        setNeedsStatusBarAppearanceUpdate()
        let siwaButton = ASAuthorizationAppleIDButton()
        
        // set this so the button will use auto layout constraint
        siwaButton.translatesAutoresizingMaskIntoConstraints = false
        
        // add the button to the view controller root view
        self.view.addSubview(siwaButton)
        
        // set constraint
        NSLayoutConstraint.activate([
            siwaButton.topAnchor.constraint(equalTo: gmailSigninBtn.bottomAnchor, constant: +20 ),
            siwaButton.heightAnchor.constraint(equalToConstant: 40.0),
            siwaButton.widthAnchor.constraint(equalToConstant: 180),
            siwaButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            
        ])
        
        // the function that will be executed when user tap the button
        siwaButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
        
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
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        .lightContent
//    }
    
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        if (self.emailTextField.text  == "" || self.passwordTextField.text == "")
        {
            let alert = UIAlertController(title: "Error", message: "please enter email and password", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        else{
            
            let email = emailTextField.text!
            let password = passwordTextField.text!
            MBProgressHUD.showAdded(to: self.view, animated: true)
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
              guard let strongSelf = self else { return }
                
                let userId = authResult?.user.uid as? String ?? ""
                UserDefaults.standard.setValue(userId, forKey: UserDetails.userId)
                
                if error != nil
                {
                    MBProgressHUD.hide(for: self!.view, animated: true)
                    let errorMsg = error!.localizedDescription
                    let alert = UIAlertController(title: "Error", message: errorMsg, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
                else
                {
                    MBProgressHUD.hide(for: self!.view, animated: true)
                    let homeVC = self?.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
                    self?.navigationController?.pushViewController(homeVC, animated: true)
                }

            }
            
            
        }
        
        
    }
    
    @IBAction func googleBtnClicked(_ sender: Any) {
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            
            // If sign in succeeded, display the app's main content View.
            print("Sucesssss")
            print((signInResult?.user.userID ?? "N/A") as String)
            print((signInResult?.user.profile?.name ?? "N/A") as String)
            print((signInResult?.user.profile?.email ?? "N/A") as String)
            
            print(signInResult?.user.idToken! as Any)
            //
            print(signInResult?.user.accessToken as Any)
            
            
            if let error = error {
                
                
                return
            }
            
            guard
                let authentication = signInResult?.user.accessToken.tokenString,
                let idToken = signInResult?.user.idToken?.tokenString
            else {
                return
            }
            
            //            print("Authentication: \(authentication)")
            //            print("IdToken: \(idToken)")
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,accessToken: authentication)
            
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            Auth.auth().signIn(with: credential ) { authResult, error in
                MBProgressHUD.showAdded(to: self.view, animated: true)
                if let error = error {
                    let authError = error as NSError
                    if  authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                        // The user is a multi-factor user. Second factor challenge is required.
                        let resolver = authError
                            .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                        var displayNameString = ""
                        for tmpFactorInfo in resolver.hints {
                            displayNameString += tmpFactorInfo.displayName ?? ""
                            displayNameString += " "
                        }
                        self.popupAlert(title: "Worning", message: "Select factor to sign in\n\(displayNameString)", actionTitles: ["Cancel", "OK"], actions: [{action1 in
                            
                        },{action2 in
                            
                        }, nil])
                        
                        
                        
                        //                    self.showTextInputPrompt(
                        //                      withMessage: "Select factor to sign in\n\(displayNameString)",
                        //                      completionBlock: { userPressedOK, displayName in
                        //                        var selectedHint: PhoneMultiFactorInfo?
                        //                        for tmpFactorInfo in resolver.hints {
                        //                          if displayName == tmpFactorInfo.displayName {
                        //                            selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                        //                          }
                        //                        }
                        //                        PhoneAuthProvider.provider()
                        //                          .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                        //                                             multiFactorSession: resolver
                        //                                               .session) { verificationID, error in
                        //                            if error != nil {
                        //                              print(
                        //                                "Multi factor start sign in failed. Error: \(error.debugDescription)"
                        //                              )
                        //                            } else {
                        //                              self.showTextInputPrompt(
                        //                                withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                        //                                completionBlock: { userPressedOK, verificationCode in
                        //                                  let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                        //                                    .credential(withVerificationID: verificationID!,
                        //                                                verificationCode: verificationCode!)
                        //                                  let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                        //                                    .assertion(with: credential!)
                        //                                  resolver.resolveSignIn(with: assertion!) { authResult, error in
                        //                                    if error != nil {
                        //                                      print(
                        //                                        "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                        //                                      )
                        //                                    } else {
                        //                                      self.navigationController?.popViewController(animated: true)
                        //                                    }
                        //                                  }
                        //                                }
                        //                              )
                        //                            }
                        //                          }
                        //                      }
                        //                    )
                    } else {
                        //                    self.showMessagePrompt(error.localizedDescription)
                        return
                    }
                    
                    return
                }
                else{
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    let useraAccessToken = authResult?.user.uid as? String ?? ""
                    UserDefaults.standard.setValue(useraAccessToken, forKey: UserDetails.gmailAccessToken)
                    
                    let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
                    self.navigationController?.pushViewController(homeVC, animated: true)
                }
            }
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    @IBAction func facebookLoginBtnClicked(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
            MBProgressHUD.showAdded(to: self.view, animated: true)
            if let error = error {
                print("Encountered Erorr: \(error)")
            } else if let result = result, result.isCancelled {
                print("Cancelled")
            } else {
                print("Logged In")
                
                self.getUserProfile(token: result?.token, userId: result?.token?.userID)
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                let userFaceBookUserID = result?.token?.userID as? String ?? ""
                UserDefaults.standard.setValue(userFaceBookUserID, forKey: UserDetails.faceBookUserID)
                let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
                self.navigationController?.pushViewController(homeVC, animated: true)
            }
            
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
    }
    
    func getUserProfile(token: AccessToken?, userId: String?) {
        let graphRequest: GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, middle_name, last_name, name, picture, email"])
        graphRequest.start { _, result, error in
            if error == nil {
                let data: [String: AnyObject] = result as! [String: AnyObject]
                
                // Facebook Id
                if let facebookId = data["id"] as? String {
                    print("Facebook Id: \(facebookId)")
                } else {
                    print("Facebook Id: Not exists")
                }
                
                // Facebook First Name
                if let facebookFirstName = data["first_name"] as? String {
                    print("Facebook First Name: \(facebookFirstName)")
                } else {
                    print("Facebook First Name: Not exists")
                }
                
                // Facebook Middle Name
                if let facebookMiddleName = data["middle_name"] as? String {
                    print("Facebook Middle Name: \(facebookMiddleName)")
                } else {
                    print("Facebook Middle Name: Not exists")
                }
                
                // Facebook Last Name
                if let facebookLastName = data["last_name"] as? String {
                    print("Facebook Last Name: \(facebookLastName)")
                } else {
                    print("Facebook Last Name: Not exists")
                }
                
                // Facebook Name
                if let facebookName = data["name"] as? String {
                    print("Facebook Name: \(facebookName)")
                } else {
                    print("Facebook Name: Not exists")
                }
                
                // Facebook Profile Pic URL
                let facebookProfilePicURL = "https://graph.facebook.com/\(userId ?? "")/picture?type=large"
                print("Facebook Profile Pic URL: \(facebookProfilePicURL)")
                
                // Facebook Email
                if let facebookEmail = data["email"] as? String {
                    print("Facebook Email: \(facebookEmail)")
                } else {
                    print("Facebook Email: Not exists")
                }
                
                print("Facebook Access Token: \(token?.tokenString ?? "")")
            } else {
                print("Error: Trying to get user's info")
            }
        }
    }
    
    func navHome()
    {
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    func isLoggedIn() -> Bool {
        let accessToken = AccessToken.current
        let isLoggedIn = accessToken != nil && !(accessToken?.isExpired ?? false)
        return isLoggedIn
    }
    
    @objc func appleSignInTapped() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        // request full name and email from the user's Apple ID
        request.requestedScopes = [.fullName, .email]
        
        // pass the request to the initializer of the controller
        let authController = ASAuthorizationController(authorizationRequests: [request])
        
        // similar to delegate, this will ask the view controller
        // which window to present the ASAuthorizationController
        authController.presentationContextProvider = self
        
        // delegate functions will be called when user data is
        // successfully retrieved or error occured
        authController.delegate = self
        
        // show the Sign-in with Apple dialog
        authController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}



extension LoginViewController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // return the current view window
        return self.view.window!
    }
}

extension LoginViewController : ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("authorization error")
        guard let error = error as? ASAuthorizationError else {
            return
        }
        
        switch error.code {
        case .canceled:
            // user press "cancel" during the login prompt
            print("Canceled")
        case .unknown:
            // user didn't login their Apple ID on the device
            print("Unknown")
        case .invalidResponse:
            // invalid response received from the login
            print("Invalid Respone")
        case .notHandled:
            // authorization request not handled, maybe internet failure during login
            print("Not handled")
        case .failed:
            // authorization failed
            print("Failed")
        @unknown default:
            print("Default")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // unique ID for each user, this uniqueID will always be returned
            
            UserDefaults.standard.set(appleIDCredential.user, forKey: UserDetails.appleUserId)
            let userID = appleIDCredential.user
            
            // optional, might be nil
            let email = appleIDCredential.email
            
            // optional, might be nil
            let givenName = appleIDCredential.fullName?.givenName
            
            // optional, might be nil
            let familyName = appleIDCredential.fullName?.familyName
            
            // optional, might be nil
            let nickName = appleIDCredential.fullName?.nickname
            
            /*
             useful for server side, the app can send identityToken and authorizationCode
             to the server for verification purpose
             */
            var identityToken : String?
            if let token = appleIDCredential.identityToken {
                identityToken = String(bytes: token, encoding: .utf8)
            }
            
            var authorizationCode : String?
            if let code = appleIDCredential.authorizationCode {
                authorizationCode = String(bytes: code, encoding: .utf8)
            }
            
            // do what you want with the data here
        }
    }
}




