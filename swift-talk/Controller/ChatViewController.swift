//
//  ChatViewController.swift
//  swift-talk
//
//  Created by Akash Banerjee on 12/16/18.
//  Copyright © 2018 SDSU. All rights reserved.
//

import UIKit
import Firebase
class ChatViewController: UIViewController, UITextFieldDelegate {
   
    var mainTitle = User()
    @IBAction func sendMessage(_ sender: Any) {
        let message = messageBody.text
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let userId = mainTitle.id
        let fromId = Auth.auth().currentUser?.uid
        let timestamp: NSNumber = NSNumber(value: Int(Date().timeIntervalSince1970))
        let values = ["text": message ?? "", "toId": userId ?? "", "fromId" : fromId ?? "", "timestamp": timestamp] as [String : Any]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            guard let fromId = fromId else {return}
            guard let toId = userId else {return}
            print("here")
//            let userGroupedReference = Database.database().reference().child("user-messages").child(fromId)
            guard let messageId = childRef.key else {return }
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(messageId)
            
            userMessagesRef.setValue(1)
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(messageId)
            
            recipientUserMessagesRef.setValue(1)
            
            self.messageBody.text = ""
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage(self)
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleAsNameOfReceiver()
        messageBody.delegate = self
    }
    @IBOutlet weak var messageBody: UITextField!
   
    
    @IBOutlet weak var messageTitle: UINavigationItem!
    func setTitleAsNameOfReceiver(){
        messageTitle.title = mainTitle.name
    }
}
