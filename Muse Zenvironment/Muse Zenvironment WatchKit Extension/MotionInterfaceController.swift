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
        validSession?.activate()
        
    }
    
    //This will be called by the delegate
    func updateLabels(gravityStr:String, userAccelStr:String, rotationRateStr:String, attitudeStr:String) {
        // The active check is set when we start and stop recording.
            gravityLabel.setText(gravityStr)
            accelerationLabel.setText(userAccelStr)
            rotationLabel.setText(rotationRateStr)
            attitudeLabel.setText(attitudeStr)
        WCSession.default.sendMessage(["activity":"Sending data booyah"], replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        motionManager.deactivate()
        super.didDeactivate()
    }

}
