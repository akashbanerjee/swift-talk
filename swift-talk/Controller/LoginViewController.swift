//
//  LoginViewController.swift
//  swift-talk
//
//  Created by Akash Banerjee on 12/8/18.
//  Copyright © 2018 SDSU. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 61, green: 91, blue: 151)
        self.login.backgroundColor = UIColor(red: 80, green: 101, blue: 161)
        self.login.setTitleColor(UIColor.white, for: UIControl.State.normal)

    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBAction func loginButton(_ sender: Any) {
        guard let email = email.text, let password = password.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print("error while authenticated")
                return
            }
            print("Logged in")
        }
    }
    @IBOutlet weak var login: UIButton!
    
}
