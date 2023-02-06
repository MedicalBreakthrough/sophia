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
import ZLImageEditor
import Photos

class AddTabVC: UIViewController {
    
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressInfoLabel: UILabel!
    @IBOutlet weak var percentageOneView: UIView!
    @IBOutlet weak var percentageTwoView: UIView!
    @IBOutlet weak var percentageThreeView: UIView!
    @IBOutlet weak var percentageFourView: UIView!
    @IBOutlet weak var cameraOrGalleryView: UIView!
    
    @IBOutlet weak var camerBtn: UIButton!
    @IBOutlet weak var galleryBtn: UIButton!
    
    var imageDownloadUrl = String()
    var resultImageEditModel: ZLEditImageModel?
    var imagePicker = UIImagePickerController()
    var window: UIWindow?
    var selectedImage: UIImage?
    
    @IBOutlet weak var deleteImageButton: UIButton!
    //MARK:- viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descTextView.delegate = self
        camerBtn.isHidden = true
        galleryBtn.isHidden = true
        
        progressView.isHidden = true
        percentageOneView.backgroundColor = .clear
        percentageTwoView.backgroundColor = .clear
        percentageThreeView.backgroundColor = .clear
        percentageFourView.backgroundColor = .clear
        
//        selectedImageView.contentMode = .scaleAspectFit
//        selectedImageView.image = selectedImage
//        if UIImagePickerController.isSourceTypeAvailable(.camera)
//        {
//            imagePicker.delegate = self
//            imagePicker.sourceType = .camera
//            imagePicker.allowsEditing = true
//            present(imagePicker, animated: true, completion: nil)
//        }
        
        cameraOrGalleryView.isHidden = false
        selectedImageView.isHidden = true
        camerBtn.isHidden = true
        galleryBtn.isHidden = true
    }
    
    //MARK:- viewWillAppear()
    override func viewWillAppear(_ animated: Bool) {
        self.descTextView.text = "my dream photo"
        self.descTextView.textColor = .gray
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        progressView.isHidden = true
        deleteImageButton.isHidden = true
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }
        cameraOrGalleryView.isHidden = false
        selectedImageView.isHidden = true
        camerBtn.isHidden = true
        galleryBtn.isHidden = true
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
//        requestPerm()
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
        {
            DispatchQueue.main.async {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .savedPhotosAlbum
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }

    }
                               
    //MARK:- generatePhotoBtnAct()
    @IBAction func generatePhotoBtnAct(_ sender: UIButton)
    {
        if (descTextView.text! != "my dream photo") && (descTextView.text != "")
        {
            uploadImage()
        }
        else
        {
            self.showToast(message: "Please enter text to proceed.")
        }
    }
    
    @IBAction func deleteImageButtonAction(_ sender: Any) {
        
        self.selectedImage = UIImage()
        self.deleteImageButton.isHidden = true
        self.cameraOrGalleryView.isHidden = false
        selectedImageView.isHidden = true
        camerBtn.isHidden = true
        galleryBtn.isHidden = true
    }
    
    //MARK:- requestPerm()
    func requestPerm()
    {
        PHPhotoLibrary.execute(controller: self, onAccessHasBeenGranted: {
            
        }, onAccessHasBeenDenied: { [self] in
            requestPerm()
        }
        )
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
        
        if selectedImage != UIImage()
        {
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
//                            print(imageDownloadUrl)
                            
                            let descText = self.descTextView.text
                            let date = Date.getCurrentDate()
                            let dataBaseRef = ref.child("users").child(userID).child("insertedItems").childByAutoId()
                            dataBaseRef.setValue(["originalImage": imageDownloadUrl, "text": descText, "botGenratedImage":"", "date":date, "progress": "0"]) {
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
        else
        {
            let descText = self.descTextView.text
            let date = Date.getCurrentDate()
            let dataBaseRef = ref.child("users").child(userID).child("insertedItems").childByAutoId()
            dataBaseRef.setValue(["originalImage": "", "text": descText, "botGenratedImage":"", "date":date, "progress": "0"]) {
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
    
    //MARK:- imageObserver()
    func imageObserver(dataBaseRef: DatabaseReference)
    {
//        MBProgressHUD.showAdded(to: self.view, animated: true)
        progressView.isHidden = false
        dataBaseRef.observe(.value, with: {(snapshot) in
            if let value = snapshot.value as? [String: Any] {
                let progressPercentage = value["progress"] as? String ?? ""
                if progressPercentage != "0" || progressPercentage != ""
                {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.progressInfoLabel.text = "Working on it(\(progressPercentage)%)"
                    if Int(progressPercentage)! > 0 && Int(progressPercentage)! <= 25
                    {
                        self.percentageOneView.backgroundColor = .green
                    }
                    else if Int(progressPercentage)! > 25 && Int(progressPercentage)! <= 50
                    {
                        self.percentageOneView.backgroundColor = .green
                        self.percentageTwoView.backgroundColor = .green
                    }
                    else if Int(progressPercentage)! > 50 && Int(progressPercentage)! <= 75
                    {
                        self.percentageOneView.backgroundColor = .green
                        self.percentageTwoView.backgroundColor = .green
                        self.percentageThreeView.backgroundColor = .green
                    }
                    else if Int(progressPercentage)! > 75
                    {
                        self.percentageOneView.backgroundColor = .green
                        self.percentageTwoView.backgroundColor = .green
                        self.percentageThreeView.backgroundColor = .green
                        self.percentageFourView.backgroundColor = .green
                    }
                    if progressPercentage == "100"
                    {
                        dataBaseRef.removeAllObservers()
                        self.progressView.isHidden = true
                        self.getBotImageUrl(dataBaseRef: dataBaseRef)
                    }
                }
            }
        })
    }
    
    //MARK:- getBotImageUrl()
    func getBotImageUrl(dataBaseRef: DatabaseReference)
    {
        dataBaseRef.getData(completion:  { [self] error, snapshot in
            guard error == nil else {
                MBProgressHUD.hide(for: self.view, animated: true)
                print(error!.localizedDescription)
                return
            }
            MBProgressHUD.hide(for: self.view, animated: true)
            let value = snapshot?.value as? NSDictionary
            let botGenImageUrl = value?["botGenratedImage"] as? String ?? ""
            if botGenImageUrl == ""
            {
                MBProgressHUD.showAdded(to: self.view, animated: true)
                dataBaseRef.observe(.value, with: {(snapshot) in
                    if let value = snapshot.value as? [String: Any] {
                        let botGenImageUrl = value["botGenratedImage"] as? String ?? ""
                        if botGenImageUrl != ""
                        {
                            MBProgressHUD.hide(for: self.view, animated: true)
                            print(botGenImageUrl)
                            dataBaseRef.removeAllObservers()
//                            self.navImageEditingVC(botGenImageUrl: botGenImageUrl)
                            self.downloadImage(from: URL(string: botGenImageUrl)!)
                        }
                    }
                })
            }
            else
            {
//                self.navImageEditingVC(botGenImageUrl: botGenImageUrl)
                downloadImage(from: URL(string: botGenImageUrl) ?? URL(fileURLWithPath: "") )
                

            }
        })
    }
    
    func downloadImage(from url: URL)
    {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() { [weak self] in
                self!.selectedImage = UIImage(data: data)!
                self!.enableEditing()
            }
        }
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    //MARK:- enableEditing()
    func enableEditing()
    {
        ZLImageEditorConfiguration.default()
            .editImageTools([.draw, .clip, .imageSticker, .textSticker, .mosaic, .filter, .adjust])
            .adjustTools([.brightness, .contrast, .saturation])
        
        ZLEditImageViewController.showEditImageVC(parentVC: self, image: selectedImage!, editModel: self.resultImageEditModel) { [weak self] (resImage, editModel) in
            
//            self?.editedImageView.image = resImage
            self?.uploadToDatabase(resImage: resImage)
  
            
//            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
//            let navigationController = UINavigationController(rootViewController: nextViewController)
//            let appdelegate = UIApplication.shared.delegate as! AppDelegate
//            appdelegate.window!.rootViewController = navigationController
        }
    }

    //MARK:- uploadImage()
    func uploadToDatabase(resImage: UIImage)
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let ref = Database.database(url: "https://sofia-67890-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
//        let user = Auth.auth().currentUser!
        let userID = UserDefaults.standard.string(forKey: UserDetails.userId) ?? ""
        let storageRef = Storage.storage().reference()
        
        
        let data = resImage.jpegData(compressionQuality: 0.8)!
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
                starsRef.downloadURL { [self] url, error in
                    if let error = error {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        print(error)
                    } else {
                        imageDownloadUrl = url!.absoluteString
                        
                        let date = Date.getCurrentDate()
                        let userName = UserDefaults.standard.string(forKey: UserDetails.userName) ?? ""
                        let dataBaseRef = ref.child("users").child(userID).child("feedList").childByAutoId()
                        dataBaseRef.setValue(["feedImage": imageDownloadUrl, "date": date, "name": userName, "textDesc": self.descTextView.text ?? ""]) {
                            (error:Error?, ref:DatabaseReference) in
                            if let error = error {
                                MBProgressHUD.hide(for: self.view, animated: true)
                                print("Data could not be saved: \(error).")
                            } else {
                                MBProgressHUD.hide(for: self.view, animated: true)
                                print("Data saved successfully!")
                                let homeVC = storyboard?.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController

                                self.navigationController?.pushViewController(homeVC, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK:- navImageEditingVC()
    func navImageEditingVC(botGenImageUrl: String)
    {
        let imageEditingVC = storyboard?.instantiateViewController(withIdentifier: "ImageEditingVC") as! ImageEditingVC
//        imageEditingVC.selectedImage = selectedImage ?? UIImage()
        imageEditingVC.textDesc = self.descTextView.text ?? ""
        imageEditingVC.botGenImageUrl = botGenImageUrl
        navigationController?.pushViewController(imageEditingVC, animated: true)
    }
}

//MARK:- TextView Delegates
extension AddTabVC: UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if textView.text == "my dream photo"
        {
            self.descTextView.text = ""
            self.descTextView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.text == ""
        {
            self.descTextView.text = "my dream photo"
            self.descTextView.textColor = .gray
        }
    }
}

//MARK:- ImagePicket Delegates
extension AddTabVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let chosenImage = info[.editedImage] as? UIImage{
            selectedImage = chosenImage
            selectedImageView.contentMode = .scaleAspectFit
            selectedImageView.image = chosenImage
            self.cameraOrGalleryView.isHidden = true
            selectedImageView.isHidden = false
            self.camerBtn.isHidden = false
            self.galleryBtn.isHidden = false
            self.deleteImageButton.isHidden = false
        }
        dismiss(animated:true, completion: nil)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
       
        
        cameraOrGalleryView.isHidden = false
        selectedImageView.isHidden = true
        camerBtn.isHidden = true
        galleryBtn.isHidden = true
        self.selectedImage = UIImage()
        
//        if let tabBarController = self.window?.rootViewController as? HomeTabBarController {
//            tabBarController.selectedIndex = 0
//        }
//        self.tabBarController?.selectedIndex = 0
    }
}

public extension PHPhotoLibrary {
   
   static func execute(controller: UIViewController,
                       onAccessHasBeenGranted: @escaping () -> Void,
                       onAccessHasBeenDenied: (@escaping () -> Void)) {
      
      let onDeniedOrRestricted = onAccessHasBeenDenied ?? {
//         let alert = UIAlertController(
//            title: "We were unable to load your album groups. Sorry!",
//            message: "You can enable access in Privacy Settings",
//            preferredStyle: .alert)
//         alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//         alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
//            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
//               UIApplication.shared.open(settingsURL)
//            }
//         }))
//         DispatchQueue.main.async {
//            controller.present(alert, animated: true)
//         }
      }

      let status = PHPhotoLibrary.authorizationStatus()
      switch status {
      case .notDetermined:
         onNotDetermined(onDeniedOrRestricted, onAccessHasBeenGranted)
      case .denied, .restricted:
         onDeniedOrRestricted()
      case .authorized:
         onAccessHasBeenGranted()
      @unknown default:
         fatalError("PHPhotoLibrary::execute - \"Unknown case\"")
      }
   }
   
    
}
private func onNotDetermined(_ onDeniedOrRestricted: @escaping (()->Void), _ onAuthorized: @escaping (()->Void)) {
   PHPhotoLibrary.requestAuthorization({ status in
      switch status {
      case .notDetermined:
         onNotDetermined(onDeniedOrRestricted, onAuthorized)
      case .denied, .restricted:
         onDeniedOrRestricted()
      case .authorized:
         onAuthorized()
      @unknown default:
         fatalError("PHPhotoLibrary::execute - \"Unknown case\"")
      }
   })
}
