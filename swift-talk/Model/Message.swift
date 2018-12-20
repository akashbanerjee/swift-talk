//
//  Message.swift
//  swift-talk
//
//  Created by Akash Banerjee on 12/16/18.
//  Copyright © 2018 SDSU. All rights reserved.
//
//Model for Message Object
import UIKit

@objcMembers
class Message: NSObject {
    var timestamp: NSNumber?
    var text: String?
    var fromId: String?
    var toId: String?

}
