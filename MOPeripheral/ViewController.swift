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
    var line = C4Line([C4Point(),C4Point()])
    override func setup() {
        line.b = C4Point(canvas.width,0)
        line.center = canvas.center
        line.lineDashPattern = [canvas.width + 10, 10, 1,10]
        canvas.add(line)
        
        let anim = C4ViewAnimation(duration: 1.0) {
            self.line.lineDashPhase = self.canvas.width + 20
        }
        
        anim.repeats = true
        
        delay(1.0) {
            anim.animate()
        }
    }
}

