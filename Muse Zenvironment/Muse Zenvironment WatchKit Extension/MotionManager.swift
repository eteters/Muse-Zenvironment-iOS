//
//  MotionManager.swift
//  Muse Zenvironment WatchKit Extension
//
//  Created by Evan Teters on 4/11/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import Foundation
import CoreMotion
import WatchConnectivity


protocol MotionDelegate {
    func updateLabels(gravityVec:MotionVector, userAccelVec:MotionVector, rotationRateVec:MotionVector, attitudeVec:MotionVector)
}

struct MotionVector {
    var x:Double
    var y:Double
    var z:Double
    
    var magnitude:Double {
        return sqrt(pow(x, 2.0) + pow(y, 2.0) + pow(z, 2.0))
    }
}

class MotionManager{
    var delegate:MotionDelegate!
    
    let queue = OperationQueue()
    
    let motionManager = CMMotionManager()
    
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    var validSession: WCSession? {
        
        #if os(iOS)
        if let session = session, session.isPaired && session.isWatchAppInstalled {
            return session
        }
        #elseif os(watchOS)
        return session
        #endif
        return nil
    }
    
    var accelerationList = [MotionVector]()
    var gravityList = [MotionVector]()
    var activityLevel:ActivityLevel!
    
    
    func deactivate()  {
//        motionManager.stopDeviceMotionUpdates()
    }
    
    func initMotion() {
        //Init the WCSESSION
        validSession?.activate()
        
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 50
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            
            if error != nil {
                print("Encountered error: \(error!)")
            }
            if deviceMotion != nil {
                print("processing motion")
                self.processDeviceMotion(deviceMotion!)
            }
        }
    }
    private func processDeviceMotion(_ deviceMotion: CMDeviceMotion) {
        // 1. These strings are to show on the UI. Trying to fit
        // x,y,z values for the sensors is difficult so we’re
        // just going with one decimal point precision.
        let gravityVec = MotionVector(x:deviceMotion.gravity.x,
                                      y:deviceMotion.gravity.y,
                                      z:deviceMotion.gravity.z)
        let userAccelVec = MotionVector(
            x: deviceMotion.userAcceleration.x,
            y: deviceMotion.userAcceleration.y,
            z: deviceMotion.userAcceleration.z)
        let rotationRateVec = MotionVector(
            x: deviceMotion.rotationRate.x,
            y: deviceMotion.rotationRate.y,
            z: deviceMotion.rotationRate.z)
        let attitudeVec = MotionVector(
            x: deviceMotion.attitude.roll,
            y: deviceMotion.attitude.pitch,
            z: deviceMotion.attitude.yaw)
      
        delegate.updateLabels(gravityVec: gravityVec, userAccelVec: userAccelVec, rotationRateVec: rotationRateVec, attitudeVec: attitudeVec)
        
        //Now send things to phone thx
        if accelerationList.count <= 25 {
            print("Hello?")
            accelerationList.append(userAccelVec)
            gravityList.append(gravityVec)
            activityLevel = ActivityLevel.unknown
        }
        else {
            print("In the else now...")
            // pop off front, add to list creating sliding window
//            accelerationList.remove(at: 0)
//            accelerationList.append(userAccelVec)
            
            //calculate activity here
//            if abs( accelerationList[24].x ) < 0.2 && abs( accelerationList[24].y ) < 0.2 && abs( accelerationList[24].z ) < 0.2  {
//                activityLevel = ActivityLevel.sedentary
//            } else if abs(accelerationList[24].x ) > 0.2 || abs(accelerationList[24].y ) > 0.2 || abs(accelerationList[24].z ) > 0.2  {
//                activityLevel = ActivityLevel.active
//            } else if abs(accelerationList[24].x ) > 0.45 || abs(accelerationList[24].y ) > 0.45 || abs(accelerationList[24].z ) > 0.45  {
//                activityLevel = ActivityLevel.veryActive
//            } else {
//                activityLevel = ActivityLevel.unknown
//            }
            
            var total = 0.0
            var accelAverage = 0.0
            var gravityAverage = 0.0
            
            //calculate average
            for i in accelerationList {
                total = total + i.magnitude
            }
            
            accelAverage = total/25
            total = 0.0
            
            for i in gravityList {
                total = total + i.magnitude
            }
            
            gravityAverage = total/25
            
            if accelAverage >= 2.0 {
                accelAverage = 2.0
            }
            
            accelAverage = accelAverage / 2.0

            print(accelAverage)
            
            WCSession.default.sendMessage(["activityLevel": "\(accelAverage)", "gravityLevel": "\(gravityAverage)"], replyHandler: nil) { (error) in
                print(error.localizedDescription)
            }
            
            accelerationList.removeAll()
            gravityList.removeAll()
            
        }
        
        
    }
    
}
