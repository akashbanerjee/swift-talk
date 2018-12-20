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
