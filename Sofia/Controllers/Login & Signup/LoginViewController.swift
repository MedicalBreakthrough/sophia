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
import FirebaseDatabase
import CryptoKit
import AuthenticationServices

class LoginViewController: UIViewController {
    
    @IBOutlet weak var gmailSigninBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        appleSigninSetUp()
    }
    
    //MARK:- googleBtnClicked()
    @IBAction func googleBtnClicked(_ sender: Any)
    {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            
            print((signInResult?.user.userID ?? "N/A") as String)
            print((signInResult?.user.profile?.name ?? "N/A") as String)
            print((signInResult?.user.profile?.email ?? "N/A") as String)
            print(signInResult?.user.idToken! as Any)
            print(signInResult?.user.accessToken as Any)
            
            if let error = error {
                print("Google SignIn Error: \(error.localizedDescription)")
                return
            }
            guard
                let authentication = signInResult?.user.accessToken.tokenString,
                let idToken = signInResult?.user.idToken?.tokenString
            else {
                return
            }
            
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
                        self.showAlert(title: "Worning", message: "Select factor to sign in\n\(displayNameString)", actionTitles: ["Cancel", "OK"], actions: [{action1 in
                            
                        },{action2 in
                            
                        }, nil])
                    } else {
                        return
                    }
                    return
                }
                else{
                    MBProgressHUD.hide(for: self.view, animated: true)
                    let useraAccessToken = authResult?.user.uid as? String ?? ""
                    let name = authResult?.user.displayName as? String ?? ""
                    let email = authResult?.user.email as? String ?? ""
                    let profilePic = authResult?.user.photoURL?.absoluteString
//                    UserDefaults.standard.setValue(useraAccessToken, forKey: UserDetails.userId)
//                    UserDefaults.standard.setValue(name, forKey: UserDetails.userName)
//                    UserDefaults.standard.setValue(email, forKey: UserDetails.userMailID)
//                    self.saveUserDetails(userID: useraAccessToken, userName: name, userEmail: email, profilePic: profilePic ?? "")
                    self.checkUserDetails(userID: useraAccessToken, userName: name, userEmail: email, profilePic: profilePic ?? "")
                }
            }
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    //MARK:- facebookLoginBtnClicked()
    @IBAction func facebookLoginBtnClicked(_ sender: Any)
    {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
            MBProgressHUD.showAdded(to: self.view, animated: true)
            if let error = error {
                print("FB Login Encountered Erorr: \(error)")
            } else if let result = result, result.isCancelled {
                print("FB Login Cancelled")
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
                let userFaceBookUserID = result?.token?.userID as? String ?? ""
                UserDefaults.standard.setValue(userFaceBookUserID, forKey: UserDetails.userId)
                self.getUserProfile(token: result?.token, userId: userFaceBookUserID)
            }
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    //MARK:- appleSigninSetUp()
    func appleSigninSetUp()
    {
        let appleSigninBtn = ASAuthorizationAppleIDButton()
        appleSigninBtn.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(appleSigninBtn)
        NSLayoutConstraint.activate([
            appleSigninBtn.topAnchor.constraint(equalTo: gmailSigninBtn.bottomAnchor, constant: +20 ),
            appleSigninBtn.heightAnchor.constraint(equalToConstant: 38.0),
            appleSigninBtn.widthAnchor.constraint(equalToConstant: 160),
            appleSigninBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
            appleSigninBtn.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
    }
    
    //MARK:- getUserProfile()
    func getUserProfile(token: AccessToken?, userId: String?)
    {
        let graphRequest: GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, middle_name, last_name, name, picture, email"])
        graphRequest.start { _, result, error in
            if error == nil {
                let data: [String: AnyObject] = result as! [String: AnyObject]
                
                if let facebookId = data["id"] as? String {
                    print("Facebook Id: \(facebookId)")
                } else {
                    print("Facebook Id: Not exists")
                }
                
                if let facebookFirstName = data["first_name"] as? String {
                    print("Facebook First Name: \(facebookFirstName)")
                } else {
                    print("Facebook First Name: Not exists")
                }
                
                if let facebookMiddleName = data["middle_name"] as? String {
                    print("Facebook Middle Name: \(facebookMiddleName)")
                } else {
                    print("Facebook Middle Name: Not exists")
                }
                
                if let facebookLastName = data["last_name"] as? String {
                    print("Facebook Last Name: \(facebookLastName)")
                } else {
                    print("Facebook Last Name: Not exists")
                }
                
                if let facebookName = data["name"] as? String {
                    print("Facebook Name: \(facebookName)")
                } else {
                    print("Facebook Name: Not exists")
                }
                
                let facebookProfilePicURL = "https://graph.facebook.com/\(userId ?? "")/picture?type=large"
                print("Facebook Profile Pic URL: \(facebookProfilePicURL)")
                
                if let facebookEmail = data["email"] as? String {
                    print("Facebook Email: \(facebookEmail)")
                } else {
                    print("Facebook Email: Not exists")
                }
                
                print("Facebook Access Token: \(token?.tokenString ?? "")")
                
                let facebookName = data["name"] as? String ?? ""
                let facebookEmail = data["email"] as? String ?? ""
                
//                UserDefaults.standard.setValue(userId, forKey: UserDetails.userId)
//                UserDefaults.standard.setValue(facebookName, forKey: UserDetails.userName)
//                UserDefaults.standard.setValue(facebookEmail, forKey: UserDetails.userMailID)
//                self.saveUserDetails(userID: userId ?? "", userName: facebookName, userEmail: facebookEmail, profilePic: facebookProfilePicURL)
                self.checkUserDetails(userID: userId ?? "", userName: facebookName, userEmail: facebookEmail, profilePic: facebookProfilePicURL)
                
            } else {
                print("Error: Trying to get user's info")
            }
        }
    }
    
    //MARK:- checkUserDetails()
    func checkUserDetails(userID: String, userName: String, userEmail: String, profilePic: String)
    {
        let ref = Database.database(url: "https://sofia-67890-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
        ref.child("users").child(userID).child("userDetails").getData(completion:  { [self] error, snapshot in
            guard error == nil else {
                MBProgressHUD.hide(for: self.view, animated: true)
                print("Error")
                print(error!.localizedDescription)
                return
            }
            print("Success")
            MBProgressHUD.hide(for: self.view, animated: true)
            let value = snapshot?.value as? NSDictionary
            if value?["userId"] == nil
            {
                self.saveUserDetails(userID: userID, userName: userName, userEmail: userEmail, profilePic: profilePic)
            }
            else
            {
                self.getUserDetails(userID: userID)
            }
        })
    }
    
    //MARK:- saveUserDetails()
    func saveUserDetails(userID: String, userName: String, userEmail: String, profilePic: String)
    {
        let ref = Database.database(url: "https://sofia-67890-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
        ref.child("users").child(userID).child("userDetails").setValue(["userId": userID, "userName": userName, "userEmail":userEmail, "profilePicUrl": profilePic]) {
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
    
    //MARK:- navigationToHome()
    func navigationToHome()
    {
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    //MARK:- isLoggedIn()
    func isLoggedIn() -> Bool
    {
        let accessToken = AccessToken.current
        let isLoggedIn = accessToken != nil && !(accessToken?.isExpired ?? false)
        return isLoggedIn
    }
    
    //MARK:- appleSignInTapped()
    @objc func appleSignInTapped()
    {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.presentationContextProvider = self
        authController.delegate = self
        authController.performRequests()
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

}




//MARK:- Apple SignIn Code

//        if let appleuserID = UserDefaults.standard.string(forKey: UserDetails.userId) {
//
//            // get the login status of Apple sign in for the app
//            // asynchronous
//            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: appleuserID, completion: {
//                credentialState, error in
//
//                switch(credentialState){
//                case .authorized:
//                    print("user remain logged in, proceed to another view")
////                    self.performSegue(withIdentifier: "LoginToUserSegue", sender: nil)
//                case .revoked:
//                    print("user logged in before but revoked")
//                case .notFound:
//                    print("user haven't log in before")
//                default:
//                    print("unknown state")
//                }
//            })
//        }

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

private func sha256(_ input: String) -> String
{
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
    }.joined()
    return hashString
}

extension LoginViewController : ASAuthorizationControllerDelegate
{
 
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error)
    {
        print("authorization error")
        
        guard let error = error as? ASAuthorizationError else {
            return
        }
        switch error.code
        {
        case .canceled:
            print("Canceled")
        case .unknown:
            print("Unknown")
        case .invalidResponse:
            print("Invalid Respone")
        case .notHandled:
            print("Not handled")
        case .failed:
            print("Failed")
        case .notInteractive:
            print("Not Interactive")
        @unknown default:
            print("Default")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
            
        case let credentials as ASAuthorizationAppleIDCredential:
            
            let user = Users.init(credentials: credentials)
            if user.email == ""
            {
                var appleUserID = user.id
                appleUserID = appleUserID.replacingOccurrences(of: ".", with: "")
                getUserDetails(userID: appleUserID)
            }
            else
            {
                let userName = "\(user.firstName) \(user.lastName)"
                UserDefaults.standard.set(user.id, forKey: UserDetails.userId)
                UserDefaults.standard.set(user.email, forKey: UserDetails.userMailID)
                UserDefaults.standard.set(userName, forKey: UserDetails.userName)
                navigationToHome()
                
            }
            
        default: break
        }
        
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//
//            UserDefaults.standard.set(appleIDCredential.user, forKey: UserDetails.userId)
//            let userID = appleIDCredential.user
//
//            let email = appleIDCredential.email
//
//            let givenName = appleIDCredential.fullName?.givenName
//
//            let familyName = appleIDCredential.fullName?.familyName
//
//            let nickName = appleIDCredential.fullName?.nickname
//
//            var identityToken : String?
//            if let token = appleIDCredential.identityToken {
//                identityToken = String(bytes: token, encoding: .utf8)
//            }
//
//            var authorizationCode : String?
//            if let code = appleIDCredential.authorizationCode {
//                authorizationCode = String(bytes: code, encoding: .utf8)
//            }
//
//
//        }
        
            }
}

extension LoginViewController : ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor
    {
        return self.view.window!
    }

}
