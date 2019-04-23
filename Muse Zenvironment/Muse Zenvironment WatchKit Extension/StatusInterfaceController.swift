//
//  StatusInterfaceController.swift
//  Muse Zenvironment
//
//  Created by Lydia Teters on 2/28/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import WatchKit
import HealthKit
import Foundation
import CoreMotion

// if( phone is using watch ){
//      check if have healthstore permissions (tentative code above)
//          statusLabel.setText("Now Recording")
//          send heartrate
//          send movement..?
//          getColor (? Do this even if no healthkit permissions????)
//          setColor
//      if not, setText("Need Permissions")

//else
//  statusLabel = "Not Active in Zenvironment"

// Configure interface objects here.
class StatusInterfaceController: WKInterfaceController, HeartDelegate {
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var colorImage: WKInterfaceImage!
    @IBOutlet weak var workoutButton: WKInterfaceButton!
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    let heartRateManager = HeartRateManager()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        //tentative maybe change the text color!?!?!?
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        // Assume watch is connected with iphone, check whether healthkit is authorized
        heartRateManager.delegate = self
//        heartRateManager.startObserver()
        
        super.willActivate()
    }

    func respondToObserver(errorMsg: String?, heartRate: Double?) {
        if let errorMsg = errorMsg{
            statusLabel.setText(errorMsg)
        }
        else if let heartRate = heartRate{
            statusLabel.setText("HealthKit Active, sharing with Zenvironment and looking for HeartRate")
            heartRateLabel.setText("\(heartRate)")
        }
        else{
            statusLabel.setText("There has been an error I don't understand")
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func workoutButtonPressed() {
        
//        workoutButton.setTitle(heartRateManager.handleWorkoutState())
        heartRateManager.startObserver()
        workoutButton.setTitle("Stop")
    }

}



// reference this self: https://developer.apple.com/documentation/watchconnectivity/using_watch_connectivity_to_communicate_between_your_apple_watch_app_and_iphone_app
// good luck LUL
