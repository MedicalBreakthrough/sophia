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
import FirebaseStorage

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    
    var userId = String()
    var userName = String()
    var userEmail = String()
    var profilePic = String()
    
    var imagePicker = UIImagePickerController()
    var selectedImage: UIImage?
    
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
    
    @IBAction func saveButtonAction(_ sender: Any)
    {
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
    
    @IBAction func logoutAction(_ sender: Any)
    {
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
    
    //MARK:- editProfilePicBtnAct()
    @IBAction func editProfilePicBtnAct(_ sender: UIButton)
    {
        let alert = UIAlertController(title: "Option", message: "Select option to proced with upadting proile pic.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { UIAlertAction in
            self.cameraOptionSelected()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .cancel, handler: { UIAlertAction in
            self.galleryOptionSelected()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- cameraOptionSelected()
    func cameraOptionSelected()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK:- galleryOptionSelected()
    func galleryOptionSelected()
    {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
        {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }
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
        ref.child("users").child(userId).child("userDetails").updateChildValues(updates)
    }
    
    //MARK:- uploadProfilePic()
    func uploadProfilePic()
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let ref = Database.database(url: "https://sofia-67890-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
//        let user = Auth.auth().currentUser!
        let userID = UserDefaults.standard.string(forKey: UserDetails.userId) ?? ""
        let storageRef = Storage.storage().reference()
        var imageDownloadUrl = String()
        
        let data = selectedImage!.jpegData(compressionQuality: 0.8)!
        let imageName = "\(userID)-\(Date().currentTimeMillis())"
        let filePath = "\(userID)/profilePics/\(imageName)"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.child(filePath).putData(data, metadata: metaData){(metaData,error) in
            if let error = error {
                MBProgressHUD.hide(for: self.view, animated: true)
                print("Storage Error: \(error.localizedDescription)")
                return
            }else{
                
                let starsRef = storageRef.child(userID).child("profilePics").child(imageName)
                starsRef.downloadURL { url, error in
                    if let error = error {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        print("Upload Error: \(error)")
                    } else {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        imageDownloadUrl = url!.absoluteString
                        print("Profile Pic URL -->> " + imageDownloadUrl)
                        self.profilePic = imageDownloadUrl
                        let updates = ["profilePicUrl": imageDownloadUrl] as [String : Any]
                        ref.child("users").child(self.userId).child("userDetails").updateChildValues(updates)
                        
                        if let url = URL(string: imageDownloadUrl) {
                            URLSession.shared.dataTask(with: url) { (data, response, error) in
                              
                              guard let imageData = data else { return }

                              DispatchQueue.main.async {
                                  let image = UIImage(data: imageData)!
                                  let resized = resizeImage(image: image, targetSize: CGSize(width: 30, height: 30))?.withRenderingMode(.alwaysOriginal)
                                  self.tabBarController?.tabBar.items![2].image = resized ?? UIImage(named: "ProfileDefultImage")
                              }
                            }.resume()
                          }
                    }
                }
            }
        }
    }
}

//MARK:- Textview Delegates
extension SettingsViewController: UITextFieldDelegate
{
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
}

//MARK:- ImagePicket Delegates
extension SettingsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let chosenImage = info[.originalImage] as? UIImage{
            selectedImage = chosenImage
            profileImageView.contentMode = .scaleAspectFit
            profileImageView.image = chosenImage
        }
        dismiss(animated:true, completion: nil)
        self.uploadProfilePic()
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
}
