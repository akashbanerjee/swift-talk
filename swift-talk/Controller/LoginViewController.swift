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
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var password: UITextField!
    
    @IBAction func loginButton(_ sender: Any) {
        guard let email = email.text, let password = password.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error)
                return
            }
            print("Logged in")
            DispatchQueue.main.async {
            self.performSegue(withIdentifier: "messagesView", sender: self);
            }
            
        }
    }
    @IBOutlet weak var login: UIButton!
    
    @IBAction func unwindFromLogout(segue: UIStoryboardSegue){
        //unwind from major filter VC and set the new retrieved filtered major list
        if segue.source is MessagesViewController{
            do{
                try Auth.auth().signOut()
            }catch let logoutException{
                print(logoutException)
            }
        }
    }
    
}
