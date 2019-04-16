//
//  HeartRateManager.swift
//  Muse Zenvironment WatchKit Extension
//
//  Created by Evan Teters on 4/11/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import Foundation
import HealthKit
import WatchKit

protocol HeartDelegate {
    func respondToObserver(errorMsg:String?, heartRate:Double?)
}

class HeartRateManager {
    
    let healthStore = HKHealthStore()
    let config = HKWorkoutConfiguration()
    var workoutSession:HKWorkoutSession?
    let heartRateUnit: HKUnit = HKUnit.count().unitDivided(by: HKUnit.minute())//HKUnit.secondUnit(with: .milli) //
    
    var observerQuery:HKObserverQuery?

    var delegate:HeartDelegate!
    
    func handleWorkoutState() -> String {
        if workoutSession?.state == HKWorkoutSessionState.running {
            workoutSession?.stopActivity(with: Date())
            workoutSession?.end()
            workoutSession = nil
            return "Stop Workout"
        }
        else{
            config.activityType = .running
            guard let wSession = try? HKWorkoutSession(healthStore: healthStore, configuration: config) else {
                return "error"
            }
            wSession.startActivity(with: Date())
            workoutSession = wSession
            return "Start Workout"
        }
        
    }
    
    func startObserver() {
        if HKHealthStore.isHealthDataAvailable() {
            let allTypes = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                                HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                                HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                                HKObjectType.quantityType(forIdentifier: .vo2Max)!])
            
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                if !success {
                    //Handle the error here.
                    self.delegate.respondToObserver(errorMsg: "HealthKit Authorization Rekt Wirireds", heartRate: nil)
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
                        self.delegate.respondToObserver(errorMsg: nil, heartRate: heartRate)
                    }
                }
            }
            if let observerQuery = observerQuery {
                healthStore.execute(observerQuery)
            }
        }
    }
    func endObserver() {
        if let observerQuery = observerQuery {
            healthStore.stop(observerQuery)
        }
    }
    
    private func fetchLatestHeartRateSample(completionHandler: @escaping (_ sample: HKQuantitySample?) -> Void) {
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
