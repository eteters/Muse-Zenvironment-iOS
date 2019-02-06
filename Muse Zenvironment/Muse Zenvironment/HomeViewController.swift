//
//  HomeViewController.swift
//  Muse Zenvironment
//
//  Created by Evan Teters on 1/30/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, StreamDelegate {

    @IBOutlet weak var getRelaxed: UILabel!
    let headbandReceiver = HeadbandReceiver()
    
    
    override func viewWillAppear(_ animated: Bool){
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
        headbandReceiver.delegate = self
        headbandReceiver.setupNetworkConnection()
    }
}

extension HomeViewController:HeadbandReceiverDelegate {
    func receivedMessage(message: HeadbandMessage) {
        print("message in VC with alpha at \(message.alphaRelaxation)")
        let red   = CGFloat(message.alphaRelaxation) //* 255.0
        let green = CGFloat(message.betaConcentration) //* 255.0
        let blue  = CGFloat(message.thetaRelaxation) //* 255.0
        let alpha = CGFloat(1.0)
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.repeat,.autoreverse], animations: {
            self.view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            self.getRelaxed.textColor = UIColor(red: 1-red, green: 1-green, blue: 1-blue, alpha: alpha)
        }, completion: nil)
    }
}
