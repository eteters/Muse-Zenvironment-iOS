//
//  StatusInterfaceController.swift
//  Muse Zenvironment
//
//  Created by Lydia Snyder on 2/28/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import WatchKit
import HealthKit
import Foundation

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
class StatusInterfaceController: WKInterfaceController {

    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var colorImage: WKInterfaceImage!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        //tentative maybe change the text color!?!?!?
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        // Assume watch is connected with iphone, check whether healthkit is authorized
        
        if HKHealthStore.isHealthDataAvailable() {
            let healthStore = HKHealthStore()
            let allTypes = Set([HKObjectType.workoutType(),
                                HKObjectType.quantityType(forIdentifier: .heartRate)!])
        
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                if !success {
                    //Handle the error here.
                    self.statusLabel.setText("HealthKit Authorization Rekt Wirireds")
                } else {
                    self.statusLabel.setText("HealthKit Active, Sharing Data with Zenvironment")
                }
            }
        }
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

// reference this self: https://developer.apple.com/documentation/watchconnectivity/using_watch_connectivity_to_communicate_between_your_apple_watch_app_and_iphone_app
// good luck LUL
