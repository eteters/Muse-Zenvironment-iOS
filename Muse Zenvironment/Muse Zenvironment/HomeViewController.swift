//
//  HomeViewController.swift
//  Muse Zenvironment
//
//  Created by Evan Teters on 1/30/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import UIKit
import HealthKit
import WatchConnectivity

class HomeViewController: UIViewController, StreamDelegate {
    
    //Interface outlet connections
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var getRelaxed: UILabel!
    @IBOutlet weak var optionsTableView: UITableView!
    
    var healthKitStore:HKHealthStore?
    var observerQuery:HKObserverQuery?
    let heartRateUnit: HKUnit = HKUnit.count().unitDivided(by: HKUnit.minute())//HKUnit.secondUnit(with: .milli) //

    //init the receiver
    let headbandReceiver = HeadbandReceiver()
    //Set up settings objects
    let optionNames = [ ZVOption(name:"Connect to Headband" , type: OptionType.textButton),
                        ZVOption(name: "Connection to Lights", type: .textButton),
                        ZVOption(name: "Connection to Watch", type: .indicator),
                        ZVOption(name: "Switch Zenvironment Mode", type: .textButton),
                        ZVOption(name: "Authorize Health Data", type: .textButton) ]
    
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    var validSession: WCSession? {
        
        // Adapted from https://gist.github.com/NatashaTheRobot/6bcbe79afd7e9572edf6
        
        #if os(iOS)
        if let session = session, session.isPaired && session.isWatchAppInstalled {
            return session
        }
        #elseif os(watchOS)
        return session
        #endif
        return nil
    }
    
    
    override func viewWillAppear(_ animated: Bool){
        super.viewDidLoad()
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = UIColor.black.cgColor
        getRelaxed.text = "Not Connected"
        self.colorView.layer.cornerRadius = self.colorView.frame.width/2
        headbandReceiver.delegate = self
        settingsButton.isHidden = true
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).dataDidFlow(_:)),
            name: .dataDidFlow, object: nil
        )
        
        validSession?.activate()
    }
    
    // .dataDidFlow notification handler.
    // Update the UI based on the userInfo dictionary of the notification.
    //
    @objc
    func dataDidFlow(_ notification: Notification) {
        //print("We made it!")
        if let message = notification.object as? [String:Any]{
            if let gravStatus = message["gravityLevel"] as? String {
                print("gravStatus is " + gravStatus)
                getRelaxed.text = gravStatus
            }
            if let status = message["activityLevel"] as? String {
                print("accelStatus is " + status)
                getRelaxed.text = status
            }
        }
    }

    //Settings buttons
    @IBAction func downButton(_ sender: Any) {
        downButton.isHidden = true
        settingsButton.isHidden = false
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseOut], animations: {
            self.tableTopConstraint.constant = 700
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    @IBAction func settingsButtonWasPressed(_ sender: Any) {
        downButton.isHidden = false
        settingsButton.isHidden = true
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseIn], animations: {
            self.tableTopConstraint.constant = 15
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
}

//Thing I implement to fulfil my role as a delegate so I can receive messages on the receiver's time
//Also where the color happens
extension HomeViewController:HeadbandReceiverDelegate {
    //TODO: This is the place to put in a connection to the lights, since here is where the data is. Might want another object to handle it since this viewcontroller is getting big.
    //Use the Model of ExcusifyIos to see how to set up a UrlRequest for the connection!
    func receivedMessage(message: HeadbandMessage) {
        print("message in VC with alpha at \(message.alphaRelaxation)")
        getRelaxed.text = "Connected" 
        let red   = CGFloat(message.alphaRelaxation) //* 255.0
        let green = CGFloat(message.betaConcentration) //* 255.0
        let blue  = CGFloat(message.thetaRelaxation) //* 255.0
        let alpha = CGFloat(1.0)
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [], animations: {
            self.colorView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            self.getRelaxed.textColor = UIColor(red: 1-red, green: 1-green, blue: 1-blue, alpha: alpha)
        }, completion: nil)
    }
    
    func messageError(errorString: String) {
        print("uhh I'm being told the connection has stopped for reason: \(errorString)")
        getRelaxed.text = "Not Connected"
        colorView.backgroundColor = UIColor.clear
    }
}

//Table view stuff
extension HomeViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentOption = optionNames[indexPath.row]
        
        switch currentOption.type {
        case .textButton:
            let cell = optionsTableView.dequeueReusableCell(withIdentifier: "textButton") as? TextButtonTableViewCell
            cell?.buttonTitle.text = currentOption.name
            if let cell = cell {
                return cell
            }
        case .indicator:
            let cell = optionsTableView.dequeueReusableCell(withIdentifier: "indicatorButton") as? ButtonIndicatorTableViewCell
            cell?.buttonTitle.text = currentOption.name
            if let cell = cell {
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Yes, I was lazy and hardcoded the settings.
        //Do you know how hard it would have been to give each settings object a delegate
        //object that was connected to the right thing that the setting needs to affect
        //so that I could do it without hardcoding?
        //Actually I'm not sure how hard, but this is easier
        switch indexPath.row {
        //case: Connec to Headband
        case 0:
            //attempting connection
            headbandReceiver.setupNetworkConnection()
        case 3:
            //do health stuf
            //pretend that the mode is heartrate and not heartrate for no
            guard let hkStore = healthKitStore else {
                return
            }
            
            let heartRateSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)
            
//            if let observerQuery = observerQuery {
//                hkStore.stop(observerQuery)
//            }
//            let anchorQuery = HKAnchoredObjectQuery(type: heartRateSampleType!, predicate: nil, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, samples, deletedObjects, qAnchor, error) in
//                if let error = error {
//                    print("Error: \(error.localizedDescription)")
//                    return
//                }
//                if let samples = samples, let sample = samples[0] as? HKQuantitySample  {
////                    DispatchQueue.main.async {
//                        let heartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
//                        print("Heart Rate Sample: \(heartRate)")
//                    self.getRelaxed.text = "\(heartRate)"
//                }
            
//                self.fetchLatestHeartRateSample { (sample) in
//                    guard let sample = sample else {
//                        return
//                    }
//
//                    DispatchQueue.main.async {
//                        let heartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
//                        print("Heart Rate Sample: \(heartRate)")
//                        //                        self.updateHeartRate(heartRateValue:  )
//                    }
//                }
//            }
            
//            anchorQuery.updateHandler = { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
//
//                guard let samples = samplesOrNil, let deletedObjects = deletedObjectsOrNil else {
//                    // Handle the error here.
//                    fatalError("*** An error occurred during an update: \(errorOrNil!.localizedDescription) ***")
//                }
//                if let samples = samples as? [HKQuantitySample]{
//                    for sample in samples {
////                        DispatchQueue.main.async {
//                            let heartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
//                            print("Heart Rate Sample: \(heartRate)")
//                            self.getRelaxed.text = "\(heartRate)"
//
//                    }
//                }
//            }
//            hkStore.execute(anchorQuery)
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
//                        self.updateHeartRate(heartRateValue:  )
                    }
                }
            }
            if let observerQuery = observerQuery {
                hkStore.execute(observerQuery)
            }
            
        case 4:
            HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
                guard authorized else {
                    let baseMessage = "HealthKit Authorization Failed"
                    if let error = error {
                        print("\(baseMessage). Reason: \(error.localizedDescription)")
                    } else {
                        print(baseMessage)
                    }
                    return
                }
                self.healthKitStore = HKHealthStore()
                print("HealthKit Successfully Authorized.")
            }

        default:
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
        if let hkStore = healthKitStore {
            hkStore.execute(query)
        }
    }
    
}
