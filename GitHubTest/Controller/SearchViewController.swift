//
//  SearchViewController.swift
//  GitHubTest
//
//  Created by Roman Syrota on 01.04.2018.
//  Copyright © 2018 Roman Syrota. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeaboard(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeaboard(_ gesture: UITapGestureRecognizer) {
        if textField.isFirstResponder {
            let tapPoint = gesture.location(in: view)
            guard let viewOnTap = view.hitTest(tapPoint, with: nil) else { return }
            
            if viewOnTap == view {
                textField.resignFirstResponder()
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showUser(_ sender: UIButton) {
        guard let text = textField.text else { return }
        if !text.isEmpty {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            textField.resignFirstResponder()
            
            ServerManager.shared.getUser(name: textField.text!, success: { [unowned self] (user, message) in
                if let message = message {
                    self.showAlert(title: "User", message: message)
                } else {
                    self.user = user
                    ServerManager.shared.getReposBy(user: user!, success: { (reposArray) in
                        self.user.reposArray = reposArray
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserInfoTableViewController") as! UserInfoTableViewController
                        vc.user = self.user
                        self.navigationController?.pushViewController(vc, animated: true)
                    }, failure: { (statusCode, error) in
                        print("StatusCode: \(statusCode!)\nError \(error!.localizedDescription)")
                    })
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }, failure: { (statusCode, error) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.showAlert(title: "Error", message: "No internet connection")
            })
        }
    }

}
