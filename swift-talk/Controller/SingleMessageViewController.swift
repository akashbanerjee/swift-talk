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

class SingleMessageViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource{

    var users = [User]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        cell.detailTextLabel?.text = users[indexPath.row].email
        
        return cell
    }
    

    override func viewDidLoad() {
        
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        super.viewDidLoad()
        tableView.register(SingleCell.self, forCellReuseIdentifier: "cell")
        fetchAllContacts()
    }
    
    func fetchAllContacts(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                let user = User()
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
   

}

class SingleCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("coder not implemented")
    }
}
