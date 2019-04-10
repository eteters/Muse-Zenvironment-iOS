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
class StatusInterfaceController: WKInterfaceController {

    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var colorImage: WKInterfaceImage!
    @IBOutlet weak var workoutButton: WKInterfaceButton!
    let healthStore = HKHealthStore()
    let config = HKWorkoutConfiguration()
    var workoutSession:HKWorkoutSession?
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    
    let heartRateUnit: HKUnit = HKUnit.count().unitDivided(by: HKUnit.minute())//HKUnit.secondUnit(with: .milli) //
    
    var observerQuery:HKObserverQuery?
    
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        //tentative maybe change the text color!?!?!?
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        // Assume watch is connected with iphone, check whether healthkit is authorized
        
        

        if HKHealthStore.isHealthDataAvailable() {
            let allTypes = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                                HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                                HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                                HKObjectType.quantityType(forIdentifier: .vo2Max)!])
        
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                if !success {
                    //Handle the error here.
                    self.statusLabel.setText("HealthKit Authorization Rekt Wirireds")
                } else {
                    self.statusLabel.setText("HealthKit Active, Sharing Data with Zenvironment")
                }
            }
            let heartRateSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)
            
            observerQuery = HKObserverQuery(sampleType: heartRateSampleType!, predicate: nil) { (_, _, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                self.fetchLatestHeartRateSample { (sample) in
                    guard let sample = sample else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        let heartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
                        print("Heart Rate Sample: \(heartRate)")
                        self.heartRateLabel.setText("\(heartRate)")
                    }
                }
            }
            if let observerQuery = observerQuery {
                healthStore.execute(observerQuery)
            }
            
            
            
        }
        super.willActivate()
    }
    

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        workoutSession?.end()
        super.didDeactivate()
    }

    @IBAction func workoutButtonPressed() {
        
        if workoutSession?.state == HKWorkoutSessionState.running {
            workoutSession?.end()
            workoutSession = nil
            workoutButton.setTitle("Stop")
        }
        else{
            config.activityType = .running
            guard let wSession = try? HKWorkoutSession(healthStore: healthStore, configuration: config) else {
                return
            }
            wSession.startActivity(with: Date())
            workoutSession = wSession
            workoutButton.setTitle("Start")
        }
        
        
    }
    
    
    func fetchLatestHeartRateSample(completionHandler: @escaping (_ sample: HKQuantitySample?) -> Void) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            completionHandler(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: sampleType,
                                  predicate: predicate,
                                  limit: Int(HKObjectQueryNoLimit),
                                  sortDescriptors: [sortDescriptor]) { (_, results, error) in
                                    if let error = error {
                                        print("Error: \(error.localizedDescription)")
                                        return
                                    }
                                    
                                    completionHandler(results?[0] as? HKQuantitySample)
        }
        
        healthStore.execute(query)
    }

}



// reference this self: https://developer.apple.com/documentation/watchconnectivity/using_watch_connectivity_to_communicate_between_your_apple_watch_app_and_iphone_app
// good luck LUL
