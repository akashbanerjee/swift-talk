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

class MessagesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

  
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
    
    
}
