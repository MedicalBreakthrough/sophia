//
//  AddTabVC.swift
//  Sofia
//
//  Created by Admin on 10/01/23.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

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
        let ref = Database.database(url: "https://sofia-67890-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
        let user = Auth.auth().currentUser!
        let storageRef = Storage.storage().reference()
        var imageDownloadUrl = String()
        
        let data = selectedImage!.jpegData(compressionQuality: 0.8)!
        let imageName = "\(user.uid)-\(Date().currentTimeMillis())"
        let filePath = "\(user.uid)/\(imageName)"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.child(filePath).putData(data, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
                let uploadedImageUrl = storageRef.child("\(imageName).jpg")
                uploadedImageUrl.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Error: \(String(describing: error!.localizedDescription))")
                      return
                    }
                    imageDownloadUrl = downloadURL.absoluteString
                  }
                
                //store downloadURL
//                let downloadURL = metaData!.downloadURL()!.absoluteString
            }
            
        }
        
        var descText = String()
        if descTextView.text != "What kind of image you want me to generate?"
        {
            descText = descTextView.text
        }
        
        ref.child("users").child(user.uid).childByAutoId().setValue(["image": imageDownloadUrl, "text": descText]) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
              print("Data could not be saved: \(error).")
            } else {
              print("Data saved successfully!")
            }
          }
    }
    
    //MARK:- navImageEditingVC()
    func navImageEditingVC()
    {
        let imageEditingVC = storyboard?.instantiateViewController(withIdentifier: "ImageEditingVC") as! ImageEditingVC
        imageEditingVC.selectedImage = selectedImage!
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
