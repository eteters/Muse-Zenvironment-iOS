//
//  MotionInterfaceController.swift
//  Muse Zenvironment
//
//  Created by Evan Teters on 4/9/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import WatchConnectivity


class MotionInterfaceController: WKInterfaceController, MotionDelegate {

    @IBOutlet weak var gravityLabel: WKInterfaceLabel!
    @IBOutlet weak var accelerationLabel: WKInterfaceLabel!
    @IBOutlet weak var rotationLabel: WKInterfaceLabel!
    @IBOutlet weak var attitudeLabel: WKInterfaceLabel!
   
    let motionManager = MotionManager()
   
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate() 
        
        motionManager.delegate = self
        motionManager.initMotion()
        
        //WCSession.default.delegate = HomeViewController
//        validSession?.activate()
        
    }
    
    //This will be called by the delegate
    func updateLabels(gravityVec:MotionVector, userAccelVec:MotionVector, rotationRateVec:MotionVector, attitudeVec:MotionVector) {
        // The active check is set when we start and stop recording.
            gravityLabel.setText(makeMotionString(vec: gravityVec))
            accelerationLabel.setText(makeMotionString(vec: userAccelVec))
            rotationLabel.setText(makeMotionString(vec: rotationRateVec))
            attitudeLabel.setText(makeMotionString(vec: attitudeVec))
        
        
    }
    
    func makeMotionString(vec:MotionVector) -> String {
        return String(format: "X: %.1f Y: %.1f Z: %.1f" , vec.x, vec.y, vec.z)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        motionManager.deactivate()
        super.didDeactivate()
    }

}
