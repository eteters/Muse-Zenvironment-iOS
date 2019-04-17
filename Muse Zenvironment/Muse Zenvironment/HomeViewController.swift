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
    
    @IBOutlet weak var backgroundView: UIImageView!
    
    //init the receiver
    let headbandReceiver = HeadbandReceiver()
    //make the light connector
    let lightConnector = LightConnector()
    
    let bgChanger = ZVTimer()
    
    //mode booleans
    var useLights = true
    
    //Set up settings objects
    let optionNames = [ ZVOption(name:"Connect to Headband" , type: OptionType.textButton),
                        ZVOption(name: "Connection to Lights", type: .indicator),
                        ZVOption(name: "Connection to Watch", type: .indicator),
                        ZVOption(name: "Switch Zenvironment Mode", type: .textButton) ]
    
    override func viewWillAppear(_ animated: Bool){
        super.viewDidLoad()
        bgChanger.delegate = self
        bgChanger.startUpdates()
        formatTable(tableView: optionsTableView)
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = UIColor.black.cgColor
        getRelaxed.text = "Not Connected"
        self.colorView.layer.cornerRadius = self.colorView.frame.width/2
        headbandReceiver.delegate = self
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
    //TODO: This is the place to put in a connection to the lights, since here is where the data is. Might want another object to handle it since this viewcontroller is getting big.
    //Use the Model of ExcusifyIos to see how to set up a UrlRequest for the connection!
    func receivedMessage(message: HeadbandMessage) {
        print("message in VC with alpha at \(message.alphaRelaxation)")
        getRelaxed.text = "Connected" 
//        let red   = CGFloat(message.alphaRelaxation) //* 255.0
//        let green = CGFloat(message.betaConcentration) //* 255.0
//        let blue  = CGFloat(message.thetaRelaxation) //* 255.0
        let hue = CGFloat(47000*message.movement)
        let sat = CGFloat(254)
        let brightness = CGFloat(127)
        let alpha = CGFloat(1.0)
        if useLights {
            let request = LightRequest(on: true,
                                       sat: Int(254),
                                       bri: Int(127),
                                       hue: Int(47000*message.movement))
            lightConnector.lightHttpCall(request: request, dispatchQueueForHandler: DispatchQueue.main) { (statusMessage) in
                print(statusMessage)
            }
        }
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [], animations: {
            self.colorView.backgroundColor = UIColor(hue: hue, saturation: sat, brightness: brightness, alpha: alpha)
//            self.colorView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            self.getRelaxed.textColor = UIColor(hue: 1-hue, saturation: 1-sat, brightness: 1-brightness, alpha: alpha)
        }, completion: nil)
    }
    
    func messageError(errorString: String) {
        print("uhh I'm being told the connection has stopped for reason: \(errorString)")
        getRelaxed.text = "Not Connected"
        colorView.backgroundColor = UIColor.clear
    }
}

extension HomeViewController:TimerDelegate {
    func changeImage(image: UIImage) {
        UIView.transition(with: self.backgroundView, duration: 2.0, options: .transitionCrossDissolve, animations: {
            self.backgroundView.image = image
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
            //Light connection
            if indexPath.row == 1 {
                cell?.buttonIndicator.setOn(useLights, animated: false)
            }
            if let cell = cell {
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func formatTable(tableView:UITableView) {
        tableView.layer.shadowPath = UIBezierPath(rect: tableView.bounds).cgPath
        tableView.layer.shadowOffset = CGSize(width: 2, height: 2)
        tableView.layer.shadowColor = (UIColor.black).cgColor
        tableView.layer.shadowRadius = 2
        tableView.layer.shadowOpacity = 0.75
        tableView.clipsToBounds = false
        tableView.layer.cornerRadius = 0.2
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
        case 1:
            useLights = !useLights
            if let cell = tableView.cellForRow(at: indexPath) as? ButtonIndicatorTableViewCell {
                cell.buttonIndicator.setOn(useLights, animated: true)
            }

        default:
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
