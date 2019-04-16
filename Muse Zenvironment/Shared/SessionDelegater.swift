//
//  SessionDelegater.swift
//  Muse Zenvironment
//
//  Created by Evan Teters on 4/11/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import Foundation
import WatchConnectivity

#if os(watchOS)
import ClockKit
#endif


enum ActivityLevel: CustomStringConvertible {
    case unknown
    case maybeStressed
    case sedentary
    case active
    case veryActive
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
            case .unknown: return "Unknown"
            case .maybeStressed: return "Maybe Stressed"
            case .active: return "active"
            case .sedentary: return "sedentary"
            case .veryActive: return "very active"
        }
    }
}


extension Notification.Name {
    static let dataDidFlow = Notification.Name("DataDidFlow")
    static let activationDidComplete = Notification.Name("ActivationDidComplete")
    static let reachabilityDidChange = Notification.Name("ReachabilityDidChange")
}

// Implement WCSessionDelegate methods to receive Watch Connectivity data and notify clients.
// WCsession status changes are also handled here.
//
class SessionDelegater: NSObject, WCSessionDelegate {
    // Called when a message is received and the peer doesn't need a response.
    //
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            print("Made it to the sessionDelegater")
            NotificationCenter.default.post(name: .dataDidFlow, object: message)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Activation Completed")
        //postNotificationOnMainQueueAsync(name: .activationDidComplete)
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Activate the new session after having switched to a new watch.
        session.activate()
    }
    #endif
   
}
