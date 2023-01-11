//
//  Utill.swift
//  Sofia
//
//  Created by Mac on 06/01/2023.
//

import Foundation
import UIKit


@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

extension UIViewController {
    func popupAlert(title: String?, message: String?, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    public func openAlert(title: String,
                             message: String,
                             alertStyle:UIAlertController.Style,
                             actionTitles:[String],
                             actionStyles:[UIAlertAction.Style],
                             actions: [((UIAlertAction) -> Void)]){

           let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
           for(index, indexTitle) in actionTitles.enumerated(){
               let action = UIAlertAction(title: indexTitle, style: actionStyles[index], handler: actions[index])
               alertController.addAction(action)
           }
           self.present(alertController, animated: true)
       }
}

class UserDetails
{
    static var userId = "UserId"
    static var gmailAccessToken = "useraGmailAccessToken"
    static var faceBookUserID =  "userFaceBookUserID"
    static var appleUserId =  "userAppleUserId"
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
