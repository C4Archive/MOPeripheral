//
//  ViewController.swift
//  MOPeripheral
//
//  Created by travis on 2015-07-17.
//  Copyright (c) 2015 C4. All rights reserved.
//

import UIKit
import C4

class ViewController: C4CanvasController {

    override func setup() {
        //adds a tap gesture recognizer to the main canvas
        canvas.addTapGestureRecognizer { (location, state) -> () in
            //posts a notification with the name "tap"
            NSNotificationCenter.defaultCenter().postNotificationName("tap", object: self, userInfo: ["location":"\(location)", "state" : "\(state.rawValue)"])
        }
        //adds a longpress gesture recognizer to the main canvas
        canvas.addLongPressGestureRecognizer { (location, state) -> () in
            //posts a notification with the name "longpress"
            NSNotificationCenter.defaultCenter().postNotificationName("longpress", object: self, userInfo: ["location":"\(location)", "state" : "\(state.rawValue)"])
        }
    }
}

