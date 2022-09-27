//
//  AlertWorker.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 18.09.22.
//

import UIKit

final class AlertWorker {
    static func showAlertWithOkButton(title: String?, message: String, forViewController: UIViewController) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let titleAttrString = NSMutableAttributedString(string: message, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)
        ])

        
        DispatchQueue.main.async {
            let action = UIAlertAction(title: "OK", style: .cancel)
            
            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            
            alertController.setValue(titleAttrString, forKey: "attributedMessage")
            alertController.addAction(action)
            
            alertController.view.backgroundColor = UIColor.clear
            forViewController.present(alertController, animated: true)
        }
    }
    
    static func showAlertWithOkButtonAndDismissPage(title: String?, message: String, forViewController: UIViewController) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let titleAttrString = NSMutableAttributedString(string: message, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)
        ])

        
        DispatchQueue.main.async {
            let action = UIAlertAction(title: "OK", style: .cancel) { action in
                forViewController.dismiss(animated: true)
            }
            
            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            
            alertController.setValue(titleAttrString, forKey: "attributedMessage")
            alertController.addAction(action)
            
            alertController.view.backgroundColor = UIColor.clear
            forViewController.present(alertController, animated: true)
        }
    }
}
