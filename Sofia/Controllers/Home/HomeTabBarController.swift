//
//  HomeTabBarController.swift
//  Sofia
//
//  Created by Mac on 06/01/2023.
//

import UIKit
import FirebaseAuth
import Kingfisher
import MBProgressHUD
import FirebaseDatabase

class HomeTabBarController: UITabBarController,UITabBarControllerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    var userId = String()
    override func viewDidLoad() {
        super.viewDidLoad()

        userId = UserDefaults.standard.string(forKey: UserDetails.userId) ?? ""
        self.delegate = self
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
   
        getUserDetails()
        let barImage: UIImage = UIImage(named: "ProfileDefultImage")!.squareMyImage().resizeMyImage(newWidth: 40).roundMyImage.withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[2].image = barImage
        
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController)!
            if selectedIndex == 1{
                if UIImagePickerController.isSourceTypeAvailable(.camera)
                {
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera
                    imagePicker.allowsEditing = true
                    present(imagePicker, animated: true, completion: nil)
                }
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
            let profilePicURL = value?["profilePicUrl"] as? String ?? ""
            print("Profile URL -->> " + profilePicURL)
            if let url = URL(string: profilePicURL) {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                  guard let imageData = data else { return }
                  DispatchQueue.main.async {
                      let image = UIImage(data: imageData)!
//                      let resized = resizeImage(image: image, targetSize: CGSize(width: 40, height: 40))?.withRenderingMode(.alwaysOriginal)
                           
                      let barImage: UIImage = image.roundMyImage.resizeMyImage(newWidth: 40).roundMyImage.withRenderingMode(.alwaysOriginal)

                      self.tabBar.items?[2].image = barImage
                      
                  }
                }.resume()
              }
            else{
                
                let barImage: UIImage = UIImage(named: "ProfileDefultImage")!.roundMyImage.resizeMyImage(newWidth: 40).roundMyImage.withRenderingMode(.alwaysOriginal)
                self.tabBar.items?[2].image = barImage
            }
          
        })
    }
    
    
}
