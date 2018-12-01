//
//  LoginViewController.swift
//  swift-talk
//
//  Created by Akash Banerjee on 12/1/18.
//  Copyright © 2018 SDSU. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 61, green: 91, blue: 151)
        self.registerButton.backgroundColor = UIColor(red: 80, green: 101, blue: 161)
        self.registerButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
    }
    

    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    @IBOutlet weak var registerButton: UIButton!
    @IBAction func register(_ sender: Any) {
        
    }
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
}
    

//Reference: https://medium.com/ios-os-x-development/ios-extend-uicolor-with-custom-colors-93366ae148e6
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
}

