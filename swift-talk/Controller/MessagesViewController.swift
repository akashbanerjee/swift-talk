//
//  MessagesViewController.swift
//  swift-talk
//
//  Created by Akash Banerjee on 12/13/18.
//  Copyright © 2018 SDSU. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class MessagesViewController: UIViewController, UIImagePickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUserNameInHeader()
  
    }
    @IBOutlet weak var messageTitle: UINavigationItem!
    
    func setUserNameInHeader() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let name = dictionary["name"] as! String
                print(name)
                self.messageTitle.title = name
                
            }
        })
        
    }

    @IBAction func logout(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            print("signed out")
            dismiss(animated: true, completion: nil)
            
        } catch let logoutException{
            print(logoutException)
        }
    }
    
    @IBAction func newMessage(_ sender: Any) {
        self.performSegue(withIdentifier: "singleMessage", sender: self);
    }

    @IBAction func uploadProfilePicture(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = (self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        present(picker, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
}
