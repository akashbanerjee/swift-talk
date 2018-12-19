//
//  SingleMessageViewController.swift
//  swift-talk
//
//  Created by Akash Banerjee on 12/13/18.
//  Copyright © 2018 SDSU. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
// friends list
class SingleMessageViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource{

    var users = [User]()
    var clickedTitle = User()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        cell.detailTextLabel?.text = users[indexPath.row].email
        let placeholder = UIImage(named: "icons8-user-50")
        cell.imageView?.image = placeholder
        if let imageUrl = users[indexPath.row].image, users[indexPath.row].image != ""{
            cell.imageView?.loadImageFromCache(urlString: imageUrl)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clickedTitle = users[indexPath.row]
        self.performSegue(withIdentifier: "chatSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatSegue"{
            let chatVC = segue.destination as? ChatViewController
            chatVC?.mainTitle = clickedTitle
        }
    }

    override func viewDidLoad() {
        
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        super.viewDidLoad()
        tableView.register(SingleCell.self, forCellReuseIdentifier: "cell")
        users.removeAll()
        fetchAllContacts()
    }
    
    func fetchAllContacts(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
           
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                
                let user = User()
                user.id = snapshot.key
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                
                DispatchQueue.main.async {
                    print(self.users.count)
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    @IBOutlet weak var tableView: UITableView!
  
    @IBAction func unwindFromChat(segue: UIStoryboardSegue){
        //unwind from major filter VC and set the new retrieved filtered major list
        if segue.source is ChatViewController{
            print("back")
        }
    }
}

class SingleCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        
        addSubview(timeLabel)
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("coder not implemented")
    }
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        return label
    }()
}
