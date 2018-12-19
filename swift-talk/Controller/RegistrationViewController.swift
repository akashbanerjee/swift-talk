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
        
        view.backgroundColor = UIColor(red: 61, green: 91, blue: 151)
        self.registerButton.backgroundColor = UIColor(red: 80, green: 101, blue: 161)
        self.registerButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        self.loginButton.backgroundColor = UIColor(red: 80, green: 101, blue: 161)
        self.loginButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBAction func register(_ sender: Any) {
        guard let name = name.text, let password = password.text, let email = email.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error?.localizedDescription)
                let alert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                        
                    }}))
                self.present(alert, animated: true, completion: nil)
                return
                return
            }
            print("user authenticated")
            guard let uid = user?.user.uid else { return }
            //user authenticated
            let ref = Database.database().reference()
            let child = ref.child("users").child(uid)
            let data = ["name": name, "email": email, "image": ""]
            child.updateChildValues(data, withCompletionBlock: { (error, databaseReference) in
                if error != nil {
                    print(error?.localizedDescription)
                    let alert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        switch action.style{
                        case .default:
                            print("default")
                            
                        case .cancel:
                            print("cancel")
                            
                        case .destructive:
                            print("destructive")
                            
                            
                        }}))
                    self.present(alert, animated: true, completion: nil)
                    return
                    return
                }
                //user entered into database
                print("User entered in database")
                DispatchQueue.main.async {
                self.performSegue(withIdentifier: "messagesViewFromRegister", sender: self);
                }
                
            })
            
        }
    }
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
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

//Reference: https://medium.com/ios-os-x-development/ios-extend-uicolor-with-custom-colors-93366ae148e6
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
}

