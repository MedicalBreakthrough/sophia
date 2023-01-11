//
//  ImageEditingVC.swift
//  Sofia
//
//  Created by Admin on 10/01/23.
//

import UIKit
import FMPhotoPicker

class ImageEditingVC: UIViewController {
    
    @IBOutlet weak var editedImageView: UIImageView!
    var selectedImage = UIImage()
    var config = FMPhotoPickerConfig()
    
    //MARK:- viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        enableEditing()
    }
    
    //MARK:- navBackAct()
    @IBAction func navBackAct(_ sender: UIButton)
    {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- enableEditing()
    func enableEditing()
    {
        let editor = FMImageEditorViewController(config: config, sourceImage: selectedImage)
        editor.delegate = self
        self.present(editor, animated: true)
    }
}

extension ImageEditingVC: FMImageEditorViewControllerDelegate
{
    func fmImageEditorViewController(_ editor: FMPhotoPicker.FMImageEditorViewController, didFinishEdittingPhotoWith photo: UIImage) {
        self.dismiss(animated: true)
        self.editedImageView.image = photo
    }
}
