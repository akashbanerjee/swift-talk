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

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var login: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupColors()
        setupListenersOnTextFields()
        self.hideKeyboardWhenTappedAround()

    }
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var login: UIButton!
    
    func setupListenersOnTextFields(){
        self.password.delegate = self
        self.email.delegate = self
    }
    
    func setupColors() {
        view.backgroundColor = UIColor(red: 61, green: 91, blue: 151)
        self.login.backgroundColor = UIColor(red: 80, green: 101, blue: 161)
        self.login.setTitleColor(UIColor.white, for: UIControl.State.normal)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func loginButton(_ sender: Any) {
        guard let email = email.text, let password = password.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                self.addAlert(title: "Login Error", message: error?.localizedDescription ?? "")
                return
            }
            
            DispatchQueue.main.async {
            self.performSegue(withIdentifier: "messagesView", sender: self);
            }
        }
    }

    @IBAction func unwindFromLogout(segue: UIStoryboardSegue){
        if segue.source is MessagesViewController{
            do{
                try Auth.auth().signOut()
            }catch let logoutException{
                print(logoutException)
            }
        }
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
