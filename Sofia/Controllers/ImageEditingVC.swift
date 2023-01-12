//
//  ImageEditingVC.swift
//  Sofia
//
//  Created by Admin on 10/01/23.
//

import UIKit
import Kingfisher
import FMPhotoPicker

class ImageEditingVC: UIViewController {
    
    @IBOutlet weak var editedImageView: UIImageView!
    var selectedImage = UIImage()
    var botGenImageUrl = String()
    var config = FMPhotoPickerConfig()
    
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
