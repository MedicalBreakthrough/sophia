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
//    codeNotReceivedAlert.view.tintColor = UIColor(#colorLiteral(red: 0, green: 0.8465872407, blue: 0.7545004487, alpha: 1))
//        codeNotReceivedAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action: UIAlertAction!) in
//
    func showAlert(title: String?, message: String?, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.view.tintColor = UIColor(#colorLiteral(red: 0, green: 0, blue: 0.7545004487, alpha: 1))
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
    static var userName = "userName"
    static var userMailID =  "userMailID"
    static var userPhoneNo = "userPhoneNo"
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    static func getCurrentDate() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        return dateFormatter.string(from: Date())
    }
}
