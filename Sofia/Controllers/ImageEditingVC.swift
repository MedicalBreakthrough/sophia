//
//  ImageEditingVC.swift
//  Sofia
//
//  Created by Admin on 10/01/23.
//

import UIKit
import Kingfisher
import FMPhotoPicker
import ZLImageEditor
import MBProgressHUD
import FirebaseStorage
import FirebaseDatabase

class ImageEditingVC: UIViewController {
    
    @IBOutlet weak var editedImageView: UIImageView!
    var selectedImage = UIImage()
    var textDesc = String()
    var botGenImageUrl = String()
    var config = FMPhotoPickerConfig()
    var resultImageEditModel: ZLEditImageModel?
    var imageDownloadUrl = String()
    var window: UIWindow?

    
    //MARK:- viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        let url = URL(string: botGenImageUrl)
//        self.editedImageView.kf.indicatorType = .activity
//        self.editedImageView.kf.setImage(with: url)
//        selectedImage = editedImageView.image ?? UIImage()
        
        downloadImage(from: url!)
    }
    
    //MARK:- navBackAct()
    @IBAction func navBackAct(_ sender: UIButton)
    {
        navigationController?.popViewController(animated: true)
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
        
        ZLEditImageViewController.showEditImageVC(parentVC: self, image: selectedImage, editModel: self.resultImageEditModel) { [weak self] (resImage, editModel) in
            
            self?.editedImageView.image = resImage
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
                        dataBaseRef.setValue(["feedImage": imageDownloadUrl, "date": date, "name": userName, "textDesc": textDesc]) {
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
    
    @IBAction func shareButtonAction(_ sender: UIButton) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let textToShare = "Check out my new Image"
        if let myWebsite = URL(string: imageDownloadUrl)
        {
            let objectsToShare = [textToShare, myWebsite, image ?? UIImage(imageLiteralResourceName: "app-logo")] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
}

extension ImageEditingVC: FMImageEditorViewControllerDelegate
{
    func fmImageEditorViewController(_ editor: FMPhotoPicker.FMImageEditorViewController, didFinishEdittingPhotoWith photo: UIImage) {
        self.dismiss(animated: true)
        self.editedImageView.image = photo
        
        //        let editor = FMImageEditorViewController(config: config, sourceImage: selectedImage)
        //        editor.delegate = self
        //        self.present(editor, animated: true)
    }
}
