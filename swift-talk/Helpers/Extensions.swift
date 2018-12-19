//
//  Extensions.swift
//  swift-talk
//
//  Created by Akash Banerjee on 12/16/18.
//  Copyright © 2018 SDSU. All rights reserved.
//

import UIKit
let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImageFromCache(urlString: String){
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject){
            self.image = cachedImage as? UIImage
            return
        }
        
        if !urlString.isEmpty {
            let url = URL(string: urlString)
            
            URLSession.shared.dataTask(with: url!) { (data, response, error) -> Void in
                if error != nil {
                    print(error!)
                    return
                }
                DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: data!){
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
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

