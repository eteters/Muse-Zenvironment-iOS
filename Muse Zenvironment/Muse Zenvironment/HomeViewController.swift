//
//  HomeViewController.swift
//  Muse Zenvironment
//
//  Created by Evan Teters on 1/30/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, StreamDelegate {

    let headbandReceiver = HeadbandReceiver()
    
    
    override func viewWillAppear(_ animated: Bool){
        super.viewDidLoad()
        headbandReceiver.delegate = self
        headbandReceiver.setupNetworkConnection()
    }
}

extension HomeViewController:HeadbandReceiverDelegate {
    func receivedMessage(message: HeadbandMessage) {
        print("message in VC with alpha at \(message.alphaRelaxation)")
        
    }
}
