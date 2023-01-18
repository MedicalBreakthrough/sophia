//
//  CameraViewController.swift
//  Sofia
//
//  Created by Mac on 18/01/2023.
//

import UIKit

class CameraViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var imagePicker = UIImagePickerController()
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                if UIImagePickerController.isSourceTypeAvailable(.camera)
                {
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera
                    imagePicker.allowsEditing = true
                    present(imagePicker, animated: true, completion: nil)
                }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let chosenImage = info[.originalImage] as? UIImage{
            
            
            let addimageVC = storyboard?.instantiateViewController(withIdentifier: "AddTabVC") as! AddTabVC
            addimageVC.selectedImage = chosenImage
            self.navigationController?.pushViewController(addimageVC, animated: true)
            
        }
        dismiss(animated:true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
        
    }
}
