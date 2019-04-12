//
//  MotionManager.swift
//  Muse Zenvironment WatchKit Extension
//
//  Created by Evan Teters on 4/11/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import Foundation
import CoreMotion

protocol MotionDelegate {
    func updateLabels(gravityStr:String, userAccelStr:String, rotationRateStr:String, attitudeStr:String)
}

class MotionManager{
    var delegate:MotionDelegate!
    
    let queue = OperationQueue()
    
    let motionManager = CMMotionManager()
    
    func deactivate()  {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func initMotion() {
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 50
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            
            if error != nil {
                print("Encountered error: \(error!)")
            }
            if deviceMotion != nil {
                self.processDeviceMotion(deviceMotion!)
            }
        }
    }
    private func processDeviceMotion(_ deviceMotion: CMDeviceMotion) {
        // 1. These strings are to show on the UI. Trying to fit
        // x,y,z values for the sensors is difficult so we’re
        // just going with one decimal point precision.
        let gravityStr = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                            deviceMotion.gravity.x,
                            deviceMotion.gravity.y,
                            deviceMotion.gravity.z)
        let userAccelStr = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                              deviceMotion.userAcceleration.x,
                              deviceMotion.userAcceleration.y,
                              deviceMotion.userAcceleration.z)
        let rotationRateStr = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                                 deviceMotion.rotationRate.x,
                                 deviceMotion.rotationRate.y,
                                 deviceMotion.rotationRate.z)
        let attitudeStr = String(format: "r: %.1f p: %.1f y: %.1f" ,
                             deviceMotion.attitude.roll,
                             deviceMotion.attitude.pitch,
                             deviceMotion.attitude.yaw)
      
        delegate.updateLabels(gravityStr: gravityStr, userAccelStr: userAccelStr, rotationRateStr: rotationRateStr, attitudeStr: attitudeStr)
        
        //I had a transfer of info here
    }
    
}
