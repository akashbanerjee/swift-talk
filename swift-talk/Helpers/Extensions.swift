//
//  Extensions.swift
//  swift-talk
//
//  Created by Akash Banerjee on 12/16/18.
//  Copyright © 2018 SDSU. All rights reserved.
//

import UIKit
let imageCache = NSCache<AnyObject, AnyObject>()

//This file contains extensions which are resued in various parts of the code
extension UIImageView {
    //the load image from cache is an extension of UIImageView which is used to store an image in NSCache and fetch from it.
    //the first time it is downloaded, and then stored. This saves a lot of network usage and gives a better user experience
    func loadImageFromCache(urlString: String){
        self.image = nil
        
        //check if image exists in NSCache then just retrieve from it and return from the function
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject){
            self.image = cachedImage as? UIImage
            return
        }
        
        //or else, download the image and then store in NSCache and also return the new image
        if !urlString.isEmpty {
            let url = URL(string: urlString)
            //fetch image from firebase
            URLSession.shared.dataTask(with: url!) { (data, response, error) -> Void in
                if error != nil {
                    print(error!)
                    return
                }
                DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: data!){

                        //store image in nscache object
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        //set image in UIImageView
                        self.image = downloadedImage
                    }
                }
                }.resume()
        }
    }
}

//extension for alert functionality which can be reused by all view controllers
extension UIViewController{
    func addAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog(message)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    //function to hide keyboard when tapped anywhere else on the screen
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
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

