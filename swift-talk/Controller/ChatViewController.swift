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
class ChatViewController: UIViewController, UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var messageExchanges: UITableView!
    var mainTitle = User()
    var messages = [Message]()
    
    @IBAction func sendMessage(_ sender: Any) {
        let message = messageBody.text
        // wont let user send blank messages
        if message != ""{
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
       
        
    }
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        sendMessage(self)
        return true
    }
    
    

    override func viewDidLoad() {
        self.messageExchanges.delegate = self
        self.messageExchanges.dataSource = self
        self.messageExchanges.separatorStyle = UITableViewCell.SeparatorStyle.none
        super.viewDidLoad()
        setTitleAsNameOfReceiver()
        getChatHistory()
        messageBody.delegate = self
       

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
        let messagesRef = Database.database().reference().child("user-messages").child(senderID)
        messagesRef.observe(.childAdded, with: {
            (snapshot) in
            
            let getMessageId = snapshot.key
            let messagesIdRef = Database.database().reference().child("messages").child(getMessageId)
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
                if self.messages.count > 0 {
                    self.messageExchanges.scrollToRow(at: IndexPath(item:self.messages.count-1, section: 0), at: .bottom, animated: true)
                }
            })

        })
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
//            self.loadMore()
        }
    }
    
    // number of items to be fetched each time (i.e., database LIMIT)
    let itemsPerBatch = 50
    
    // Where to start fetching items (database OFFSET)
    var offset = 0
    
    // a flag for when all database items have already been loaded
    var reachedEndOfItems = false
    
//    func loadMore(){
//        // don't bother doing another db query if already have everything
//        guard !self.reachedEndOfItems else {
//            return
//        }
//
//        // query the db on a background thread
//        DispatchQueue.global(qos: .background).async {
//
//            // determine the range of data items to fetch
//            var thisBatchOfItems: [Message]?
//            let start = self.offset
//            let end = self.offset + self.itemsPerBatch
//
//            // query the database
//            do {
//                // SQLite.swift wrapper
//                thisBatchOfItems = try MyDataHelper.findRange(start..<end)
//            } catch _ {
//                print("query failed")
//            }
//
//            // update UITableView with new batch of items on main thread after query finishes
//            DispatchQueue.main.async {
//
//                if let newItems = thisBatchOfItems {
//
//                    // append the new items to the data source for the table view
//                    self.myObjectArray.appendContentsOf(newItems)
//
//                    // reload the table view
//                    self.messageExchanges.reloadData()
//
//                    // check if this was the last of the data
//                    if newItems.count < self.itemsPerBatch {
//                        self.reachedEndOfItems = true
//                        print("reached end of data. Batch count: \(newItems.count)")
//                    }
//
//                    // reset the offset for the next data query
//                    self.offset += self.itemsPerBatch
//                }
//
//            }
//        }
//    }
    
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
