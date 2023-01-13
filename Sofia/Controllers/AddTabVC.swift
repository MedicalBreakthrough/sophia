//
//  AddTabVC.swift
//  Sofia
//
//  Created by Admin on 10/01/23.
//

import UIKit
import FirebaseAuth
import Kingfisher
import FirebaseStorage
import FirebaseDatabase
import MBProgressHUD

class AddTabVC: UIViewController {
    
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var descTextView: UITextView!
    
    var imagePicker = UIImagePickerController()
    
    var selectedImage: UIImage?
    
    //MARK:- viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descTextView.delegate = self
    }
    
    //MARK:- viewWillAppear()
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    //MARK:- cameraRollBtnAct()
    @IBAction func cameraRollBtnAct(_ sender: UIButton)
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK:- selectGalleryBtnAct()
    @IBAction func selectGalleryBtnAct(_ sender: UIButton)
    {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
        {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK:- generatePhotoBtnAct()
    @IBAction func generatePhotoBtnAct(_ sender: UIButton)
    {
//        navImageEditingVC()
        if selectedImage != nil
        {
            uploadImage()
        }
        else
        {
            
        }
    }
    
    //MARK:- uploadImage()
    func uploadImage()
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let ref = Database.database(url: "https://sofia-67890-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
//        let user = Auth.auth().currentUser!
        let userID = UserDefaults.standard.string(forKey: UserDetails.userId) ?? ""
        let storageRef = Storage.storage().reference()
        var imageDownloadUrl = String()
        
        let data = selectedImage!.jpegData(compressionQuality: 0.8)!
        let imageName = "\(userID)-\(Date().currentTimeMillis())"
        let filePath = "\(userID)/\(imageName)"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.child(filePath).putData(data, metadata: metaData){(metaData,error) in
            if let error = error {
                MBProgressHUD.hide(for: self.view, animated: true)
                print(error.localizedDescription)
                return
            }else{
                
                let starsRef = storageRef.child(userID).child(imageName)
                starsRef.downloadURL { url, error in
                    if let error = error {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        print(error)
                    } else {
                        imageDownloadUrl = url!.absoluteString
                        print(imageDownloadUrl)
                        
                        var descText = String()
                        if self.descTextView.text != "What kind of image you want me to generate?"
                        {
                            MBProgressHUD.hide(for: self.view, animated: true)
                            descText = self.descTextView.text
                        }
                        let dataBaseRef = ref.child("users").child(userID).child("insertedItems").childByAutoId()
                        dataBaseRef.setValue(["originalImage": imageDownloadUrl, "text": descText, "botGenratedImage":""]) {
                            (error:Error?, ref:DatabaseReference) in
                            if let error = error {
                                MBProgressHUD.hide(for: self.view, animated: true)
                                print("Data could not be saved: \(error).")
                            } else {
                                MBProgressHUD.hide(for: self.view, animated: true)
                                print("Data saved successfully!")
                                self.imageObserver(dataBaseRef: dataBaseRef)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK:- imageObserver()
    func imageObserver(dataBaseRef: DatabaseReference)
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        dataBaseRef.observe(.value, with: {(snapshot) in
            if let value = snapshot.value as? [String: Any] {
                let botGenImageUrl = value["botGenratedImage"] as? String ?? ""
                if botGenImageUrl != "Paste the genrated image url here"
                {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    print(botGenImageUrl)
                    dataBaseRef.removeAllObservers()
                    self.navImageEditingVC(botGenImageUrl: botGenImageUrl)
                }
            }
        })
    }
    
    //MARK:- navImageEditingVC()
    func navImageEditingVC(botGenImageUrl: String)
    {
        let imageEditingVC = storyboard?.instantiateViewController(withIdentifier: "ImageEditingVC") as! ImageEditingVC
        imageEditingVC.selectedImage = selectedImage!
        imageEditingVC.botGenImageUrl = botGenImageUrl
        navigationController?.pushViewController(imageEditingVC, animated: true)
    }
}

//MARK:- ImagePicket Delegates
extension AddTabVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let chosenImage = info[.originalImage] as? UIImage{
            selectedImage = chosenImage
            selectedImageView.contentMode = .scaleAspectFit
            selectedImageView.image = chosenImage
        }
        dismiss(animated:true, completion: nil)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK:- TextView Delegates
extension AddTabVC: UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView) {
        let currentText = textView.text
        if currentText == "What kind of image you want me to generate?"
        {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let currentText = textView.text
        if currentText == ""
        {
            textView.text = "What kind of image you want me to generate?"
        }
    }
}
