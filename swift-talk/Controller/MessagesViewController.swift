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
import FirebaseStorage

class MessagesViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let picker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUserNameInHeader()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeProfilePicture)))
        profilePicture.isUserInteractionEnabled = true
        
        loadProfilePictureIfPresent()
    }
    
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
