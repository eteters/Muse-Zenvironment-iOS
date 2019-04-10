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


class MotionInterfaceController: WKInterfaceController {

    @IBOutlet weak var gravityLabel: WKInterfaceLabel!
    @IBOutlet weak var accelerationLabel: WKInterfaceLabel!
    @IBOutlet weak var rotationLabel: WKInterfaceLabel!
    @IBOutlet weak var attitudeLabel: WKInterfaceLabel!
    
    var gravityStr = ""
    var userAccelStr = ""
    var rotationRateStr = ""
    var attitudeStr = ""
    
    let queue = OperationQueue()
    
    let motionManager = CMMotionManager()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
        updateLabels()
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 50
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            
            if error != nil {
                print("Encountered error: \(error!)")
                self.gravityStr = "Error!"
                self.updateLabels()
            }
            if deviceMotion != nil {
//                self.gravityStr = "Something hapenns"
                self.updateLabels()
                self.processDeviceMotion(deviceMotion!)
            }
//            self.gravityStr = "both statements are not hit???"
            self.updateLabels()
        }
        
    }
    
    func processDeviceMotion(_ deviceMotion: CMDeviceMotion) {
        // 1. These strings are to show on the UI. Trying to fit
        // x,y,z values for the sensors is difficult so we’re
        // just going with one decimal point precision.
        gravityStr = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                            deviceMotion.gravity.x,
                            deviceMotion.gravity.y,
                            deviceMotion.gravity.z)
        userAccelStr = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                              deviceMotion.userAcceleration.x,
                              deviceMotion.userAcceleration.y,
                              deviceMotion.userAcceleration.z)
        rotationRateStr = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                                 deviceMotion.rotationRate.x,
                                 deviceMotion.rotationRate.y,
                                 deviceMotion.rotationRate.z)
        attitudeStr = String(format: "r: %.1f p: %.1f y: %.1f" ,
                             deviceMotion.attitude.roll,
                             deviceMotion.attitude.pitch,
                             deviceMotion.attitude.yaw)
        // 2. Since this is timeseries data, we want to include the
        //    time we log the measurements (in ms since it's
        //    recording every .02s)
        let timestamp = Date()
        // 3. Log this data so we can extract it later
        
        // 4. update values in the UI
            self.updateLabels();
    }
    
    func updateLabels() {
        // The active check is set when we start and stop recording.
            gravityLabel.setText(gravityStr)
            accelerationLabel.setText(userAccelStr)
            rotationLabel.setText(rotationRateStr)
            attitudeLabel.setText(attitudeStr)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        motionManager.stopDeviceMotionUpdates()
        super.didDeactivate()
    }

}
