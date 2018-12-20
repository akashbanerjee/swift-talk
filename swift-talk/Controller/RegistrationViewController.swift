//
//  RegisterViewController.swift
//  swift-talk
//
//  Created by Akash Banerjee on 12/1/18.
//  Copyright © 2018 SDSU. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class RegistrationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupColors()
        setupListenersOnTextFields()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    
    func setupListenersOnTextFields(){
        self.name.delegate = self
        self.password.delegate = self
        self.email.delegate = self
    }
    
    func setupColors() {
        view.backgroundColor = UIColor(red: 61, green: 91, blue: 151)
        self.registerButton.backgroundColor = UIColor(red: 80, green: 101, blue: 161)
        self.registerButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        self.loginButton.backgroundColor = UIColor(red: 80, green: 101, blue: 161)
        self.loginButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @IBAction func register(_ sender: Any) {
        
        guard let name = name.text, let password = password.text, let email = email.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                self.addAlert(title: "Registration Error", message: error?.localizedDescription ?? "")
                return
            }
            
            guard let uid = user?.user.uid else { return }
            //user authenticated
            let ref = Database.database().reference()
            let child = ref.child("users").child(uid)
            let data = ["name": name, "email": email, "image": ""]
            child.updateChildValues(data, withCompletionBlock: { (error, databaseReference) in
                if error != nil {
                    self.addAlert(title: "Registration Error", message: error?.localizedDescription ?? "")
                    return
                }
                //user entered into database
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "messagesViewFromRegister", sender: self);
                }
            })
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

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}





