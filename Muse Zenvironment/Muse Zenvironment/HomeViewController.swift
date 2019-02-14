//
//  HomeViewController.swift
//  Muse Zenvironment
//
//  Created by Evan Teters on 1/30/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, StreamDelegate {
    //Interface outlet connections
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var getRelaxed: UILabel!
    @IBOutlet weak var optionsTableView: UITableView!
    
    //init the receiver
    let headbandReceiver = HeadbandReceiver()
    //Set up settings objects
    let optionNames = [ ZVOption(name:"Connect to Headband" , type: OptionType.textButton),
                        ZVOption(name: "Connection to Lights", type: .textButton),
                        ZVOption(name: "Connection to Watch", type: .indicator),
                        ZVOption(name: "Switch Zenvironment Mode", type: .textButton) ]
    
    override func viewWillAppear(_ animated: Bool){
        super.viewDidLoad()
        headbandReceiver.delegate = self
        headbandReceiver.setupNetworkConnection()
        settingsButton.isHidden = true
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
    func receivedMessage(message: HeadbandMessage) {
        print("message in VC with alpha at \(message.alphaRelaxation)")
        let red   = CGFloat(message.alphaRelaxation) //* 255.0
        let green = CGFloat(message.betaConcentration) //* 255.0
        let blue  = CGFloat(message.thetaRelaxation) //* 255.0
        let alpha = CGFloat(1.0)
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.repeat,.autoreverse], animations: {
            self.colorView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            self.colorView.layer.cornerRadius = self.colorView.frame.width/2
            self.getRelaxed.textColor = UIColor(red: 1-red, green: 1-green, blue: 1-blue, alpha: alpha)
        }, completion: nil)
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

        default:
            return
        }
    }
    
}
