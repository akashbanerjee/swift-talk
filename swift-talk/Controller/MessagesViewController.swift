//
//  MessagesViewController.swift
//  swift-talk
//
//  Created by Akash Banerjee on 12/13/18.
//  Copyright © 2018 SDSU. All rights reserved.
//
//  main page with all latest
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
// latest chats
class MessagesViewController: UIViewController {
    
    var user = User()
    var chattingUsers = [User]()
    var clickedTitle = User()
    var nameArray = [String]()
    var messages = [Message]()
    var messagesGroup = [String: Message]()
    let picker = UIImagePickerController()
    var messageDetails = [MessageDetails]()
    let databaseRef = Database.database().reference()
    
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var messageTitle: UINavigationItem!

    override func viewDidLoad() {
        initializeMessageTable()
        super.viewDidLoad()
        setHeader()
        checkUserMessages()
        //get all users messages and display them in table
    }
    
    func fetchChattingContacts(){
        print("chat")
        for var eachMessage in messages {
            print(eachMessage)
            let message = eachMessage
            let chatId: String?
            if message.fromId == Auth.auth().currentUser?.uid{
                chatId = message.toId
            }
            else {
                chatId = message.fromId
            }
            if let chatId = chatId{
                let ref = databaseRef.child("users").child(chatId)
                ref.observe(.value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject]{
                        self.nameArray.append(dictionary["name"] as? String ?? "Unknown")
                        var msgdetails = MessageDetails()
                        msgdetails.name = dictionary["name"] as? String ?? "Unknown"
                        msgdetails.text = message.text
                        if let seconds = message.timestamp?.doubleValue{
                            let timeStampDate = Date(timeIntervalSince1970: seconds)
                            let dateFormat = DateFormatter()
                            dateFormat.dateFormat = "HH:mm:ss a"
                            msgdetails.time = dateFormat.string(from: timeStampDate as Date)
                        }
                        if let imageUrl = dictionary["image"] as? String, imageUrl != ""{
                            msgdetails.image = imageUrl
                        }
                        else{
                             msgdetails.image = ""
                        }
                        self.messageDetails.append(msgdetails)
                    }
                    DispatchQueue.main.async {
                        self.messagesTableView.reloadData()
                    }
                }, withCancel: nil)
            }
        }
    }
   
    func setHeader() {
        setUserNameInHeader()
        loadProfilePictureIfPresent()
    }
    
    func cleanAllMessages() {
        messages.removeAll()
        messagesGroup.removeAll()
    }
    
    func initializeMessageTable() {
        self.messagesTableView.delegate = self
        self.messagesTableView.dataSource = self
    }
    
    func initializeProfilePicturePicker() {
        picker.delegate = self
        picker.allowsEditing = true
        messagesTableView.register(SingleCell.self, forCellReuseIdentifier: "cell")
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeProfilePicture)))
        profilePicture.isUserInteractionEnabled = true
    }
    
    func checkUserMessages() {
        print("msg")
        cleanAllMessages()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = databaseRef.child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesRef = self.databaseRef.child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]
                {
                    let messageObj = Message()
                    messageObj.setValuesForKeys(dictionary)
                    self.messages.append(messageObj)
                    
                    let chatId: String?
                    if messageObj.fromId == Auth.auth().currentUser?.uid{
                        chatId = messageObj.toId
                    }
                    else {
                        chatId = messageObj.fromId
                    }
                    if let chatId = chatId {
                        self.messagesGroup[chatId] = messageObj
                        self.messages = Array(self.messagesGroup.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            guard let message1Val = message1.timestamp?.intValue, let message2Val = message2.timestamp?.intValue else { return true }
                            return message1Val > message2Val
                        })
                      
                    }
                    DispatchQueue.main.async {
                        self.fetchChattingContacts()
//                        self.messagesTableView.reloadData()
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }

    
    func loadProfilePictureIfPresent(){
        initializeProfilePicturePicker()
        let uid = Auth.auth().currentUser?.uid
        databaseRef.child("users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let image = dictionary["image"] as! String
                if image.isEmpty{ return }
                let storageRef = Storage.storage().reference(forURL: image)
                storageRef.downloadURL(completion: { (url, error) in
                    guard let imageURL = url, error == nil else{
                        return
                    }
                    guard let data = NSData(contentsOf: imageURL) else {
                        return
                    }
                    self.profilePicture.image = UIImage(data: data as Data)
                })
            }
        })
    }
   
    @objc func changeProfilePicture(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
            present(picker, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromMessagesToChat"{
            let chatVC = segue.destination as? ChatViewController
            chatVC?.mainTitle = clickedTitle
        }
    }
    
    @IBAction func unwindFromChat(segue: UIStoryboardSegue){
        //unwind from major filter VC and set the new retrieved filtered major list
        if segue.source is ChatViewController{
            self.messagesTableView.reloadData()
        }
    }
    
    func setUserNameInHeader() {
        let uid = Auth.auth().currentUser?.uid
        databaseRef.child("users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let name = dictionary["name"] as! String
                print(name)
                self.messageTitle.title = name
            }
        })
    }
    
    @IBAction func unwindFromNewMessage(segue: UIStoryboardSegue){
        //unwind from major filter VC and set the new retrieved filtered major list
        if segue.source is SingleMessageViewController{
            self.messagesTableView.reloadData()
        }
    }
    
    @IBAction func newMessage(_ sender: Any) {
        self.performSegue(withIdentifier: "singleMessage", sender: self);
    }

    func saveProfilePicture(){
        let uid = Auth.auth().currentUser?.uid
        let child = databaseRef.child("users").child(uid!)
        let pictureReference = Storage.storage().reference().child("profileImages").child("\(uid!).jpg")
        if let profileImage = self.profilePicture.image, let uploadImage = profileImage.jpegData(compressionQuality: 0.1){
            pictureReference.putData(uploadImage, metadata: nil) { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                guard metadata != nil else {
                    // Uh-oh, an error occurred!
                    return
                }
                pictureReference.downloadURL(completion: { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    let data = ["image": downloadURL.absoluteString]
                    child.updateChildValues(data, withCompletionBlock: { (error, databaseReference) in
                        if error != nil {
                            print("error while writing in database")
                            return
                        }
                        //user entered into database
                        print("User updated image in database")
                    })
                })
            }
        }
    }
}


extension MessagesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage{
            self.profilePicture.image = editedImage
            print(editedImage.size)
        }
        else if let image = info[.originalImage] as? UIImage{
            self.profilePicture.image = image
            print(image.size)
        }
        saveProfilePicture()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.clickedTitle = User()
        let message = messages[indexPath.row]
        
        let chatId: String?
        if message.fromId == Auth.auth().currentUser?.uid{
            chatId = message.toId
        }
        else {
            chatId = message.fromId
        }
        
        if let chatId = chatId{
            let ref = databaseRef.child("users").child(chatId)
            ref.observe(.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    self.clickedTitle.id = chatId
                    self.clickedTitle.name = dictionary["name"] as? String
                    print(indexPath.row, ": ", dictionary["image"])
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "fromMessagesToChat", sender: self)
                    }
                }
            }, withCancel: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(messageDetails.count,"count")
        return messageDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as? MessagesDisplayTableViewCell else
        {
            fatalError("The dequeued cell is not an instance of MessagesDisplayTableViewCell.")
        }
        print(indexPath.row)
        print(messageDetails)
        let msgDetails = messageDetails[indexPath.row]
        cell.name.text = msgDetails.name
        cell.msg.text = msgDetails.text
        if (msgDetails.image != ""){
            cell.dp.loadImageFromCache(urlString: msgDetails.image ?? "dps")
        }
        cell.timestamp.text = msgDetails.time
        return cell
    }
}
