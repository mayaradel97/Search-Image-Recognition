//
//  UIViewControllerAlertExtension.swift
//  Search Image Recognition
//
//  Created by Mayar Adel on 1/21/22.
//

import UIKit
extension UIViewController
{
    func showAlert(with message:String)
    {
        let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
