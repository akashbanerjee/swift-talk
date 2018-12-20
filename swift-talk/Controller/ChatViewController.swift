//
//  ChatViewController.swift
//  swift-talk
//
//  Created by Akash Banerjee on 12/16/18.
//  Copyright © 2018 SDSU. All rights reserved.
//

import UIKit
import Firebase
// single person chat
extension UILabel {
    func setSizeFont (sizeFont: CGFloat) {
        self.font =  UIFont(name: self.font.fontName, size: sizeFont)!
        self.sizeToFit()
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        sendMessage(self)
        return true
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row].text;
        cell.textLabel?.numberOfLines = 0;
        cell.textLabel?.sizeToFit();
        cell.textLabel?.textAlignment = .right
        cell.textLabel?.preferredMaxLayoutWidth = 10;
        
        if messages[indexPath.row].fromId == mainTitle.id{
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.backgroundColor = UIColor.white
        }
        cell.separatorInset = UIEdgeInsets.zero
        return cell
        
    }
}

class ChatViewController: UIViewController {
   
    @IBOutlet weak var messageExchanges: UITableView!
    var mainTitle = User()
    var messages = [Message]()
    let databaseRef = Database.database().reference()
    
    @IBAction func sendMessage(_ sender: Any) {
        let message = messageBody.text
        // wont let user send blank messages
        if message != ""{
            let ref = databaseRef.child("messages")
            let childRef = ref.childByAutoId()
            let userId = mainTitle.id
            let fromId = Auth.auth().currentUser?.uid
            let timestamp: NSNumber = NSNumber(value: Int(Date().timeIntervalSince1970))
            let values = ["text": message ?? "", "toId": userId ?? "", "fromId" : fromId ?? "", "timestamp": timestamp] as [String : Any]
            
            childRef.updateChildValues(values) { (error, ref) in
                if error != nil {
                    return
                }
                guard let fromId = fromId else {return}
                guard let toId = userId else {return}
                
                guard let messageId = childRef.key else {return }
                
                let fromUserMessagesRef = self.databaseRef.child("user-messages").child(fromId).child(messageId)
                fromUserMessagesRef.setValue(1)
                
                let recipientUserMessagesRef = self.databaseRef.child("user-messages").child(toId).child(messageId)
                recipientUserMessagesRef.setValue(1)
                
                self.messageBody.text = ""
            }
            
        }
       
        
    }

    override func viewDidLoad() {
        messageExchangesSetup()
        super.viewDidLoad()
        setTitleAsNameOfReceiver()
        getChatHistory()
        messageBody.delegate = self
        //we tried hiding keyboard when tapped arround in this view but it got in the way of the send button
        //that is, the view listened to the tap and hid the keyboard, but if we hit the send button when
        //the keyboard is on, it just hid the keyboard and ignored the action call to the send button
     //   self.hideKeyboardWhenTappedAround()
        
    }
 
    func messageExchangesSetup() {
        self.messageExchanges.delegate = self
        self.messageExchanges.dataSource = self
        self.messageExchanges.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    @IBOutlet weak var messageBody: UITextField!
    @IBOutlet weak var messageTitle: UINavigationItem!
    
    func setTitleAsNameOfReceiver(){
        messageTitle.title = mainTitle.name
    }
    
    // This function will fetch some the previous
    // message exchanged with this secelected User()
    // sender is the person logged in
    func getChatHistory(){
        guard let senderID = Auth.auth().currentUser?.uid else{
            return
        }
        let sentMessagesRef = databaseRef.child("user-messages").child(senderID)
        sentMessagesRef.observe(.childAdded, with: {
            (snapshot) in
            
            let getMessageId = snapshot.key
            let messagesIdRef = self.databaseRef.child("messages").child(getMessageId)
            
            messagesIdRef.observeSingleEvent(of:.value, with:{
                (snapshot) in
                guard let messagesDictionary = snapshot.value as? [String:Any] else {
                    return
                }
                let messages = Message()
                messages.setValuesForKeys(messagesDictionary)
                if (messages.fromId == senderID && messages.toId ==  self.mainTitle.id)  || (messages.fromId == self.mainTitle.id && messages.toId == senderID){
                    self.messages.append(messages)
                }
                
                self.messageExchanges.reloadData()
                self.scrollToBottomOnNewMessage()
                
            })

        })
    }
    
    func scrollToBottomOnNewMessage() {
        if self.messages.count > 0 {
            self.messageExchanges.scrollToRow(at: IndexPath(item:self.messages.count-1, section: 0), at: .bottom, animated: true)
        }
    }
    
    
   
}
