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

class MessagesViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var user = User()
    var clickedTitle = User()
    var nameArray = [String]()
    
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
            let ref = Database.database().reference().child("users").child(chatId)
            ref.observe(.value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    
                    self.clickedTitle.id = chatId
                    self.clickedTitle.name = dictionary["name"] as? String
                    DispatchQueue.main.async {
                         self.performSegue(withIdentifier: "fromMessagesToChat", sender: self)
                    }
                }
            }, withCancel: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromMessagesToChat"{
            let chatVC = segue.destination as? ChatViewController
            chatVC?.mainTitle = clickedTitle
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SingleCell
        let message = messages[indexPath.row]
        
        let chatId: String?
        if message.fromId == Auth.auth().currentUser?.uid{
            chatId = message.toId
        }
        else {
            chatId = message.fromId
        }
        
        if let chatId = chatId{
            let ref = Database.database().reference().child("users").child(chatId)
            ref.observe(.value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    cell.textLabel?.text = dictionary["name"] as? String
                    self.nameArray.append(dictionary["name"] as? String ?? "Unknown")
                    cell.detailTextLabel?.text = message.text
                    if let seconds = message.timestamp?.doubleValue{
                        let timeStampDate = Date(timeIntervalSince1970: seconds)
                        let dateFormat = DateFormatter()
                        dateFormat.dateFormat = "HH:mm:ss a"
                        cell.timeLabel.text = dateFormat.string(from: timeStampDate as Date)
                        
                    }
                    let placeholder = UIImage(named: "icons8-user-50")
                    cell.imageView?.image = placeholder
                    if let imageUrl = dictionary["image"], imageUrl as! String != ""{
                        
                        cell.imageView?.loadImageFromCache(urlString: imageUrl as! String)
                            
                        
                    }
                   
                }
                
            }, withCancel: nil)
        }
        
        return cell
    }
    

    @IBOutlet weak var messagesTableView: UITableView!
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        self.messagesTableView.delegate = self
        self.messagesTableView.dataSource = self
        super.viewDidLoad()
        setUserNameInHeader()
        picker.delegate = self
        picker.allowsEditing = true
        messagesTableView.register(SingleCell.self, forCellReuseIdentifier: "cell")
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeProfilePicture)))
        profilePicture.isUserInteractionEnabled = true
        
        loadProfilePictureIfPresent()
        messages.removeAll()
        messagesGroup.removeAll()
        self.messagesTableView.reloadData()
        checkUserMessages()
        self.messagesTableView.reloadData()
    }
    
    func checkUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
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
                        self.messagesTableView.reloadData()
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
        
        
    }
    var messages = [Message]()
    var messagesGroup = [String: Message]()

    
    func loadProfilePictureIfPresent(){
        let uid = Auth.auth().currentUser?.uid
    Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot) in
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
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var messageTitle: UINavigationItem!
   
    @objc func changeProfilePicture(gesture: UIGestureRecognizer) {
        
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
            present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func unwindFromChat(segue: UIStoryboardSegue){
        //unwind from major filter VC and set the new retrieved filtered major list
        if segue.source is ChatViewController{
            print("back")
        }
    }
    
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
    @IBAction func unwindFromNewMessage(segue: UIStoryboardSegue){
        //unwind from major filter VC and set the new retrieved filtered major list
        if segue.source is SingleMessageViewController{
            print("back")
        }
    }
    
    @IBAction func newMessage(_ sender: Any) {
        self.performSegue(withIdentifier: "singleMessage", sender: self);
    }

 
    
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
    
    func saveProfilePicture(){
        let uid = Auth.auth().currentUser?.uid
        let child = Database.database().reference().child("users").child(uid!)
        
        
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
