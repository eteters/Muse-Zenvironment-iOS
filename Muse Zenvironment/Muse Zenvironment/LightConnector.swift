//
//  LightConnector.swift
//  Muse Zenvironment
//
//  Created by Evan Teters on 3/10/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import Foundation

class LightConnector {
    
    let user = "psmHCxZKbSswfXiXR1RCmph9Ic2WPuW8y8Ndf7dH"
    let urlBase = "http://192.168.2.2/api/"
    let mode = "lights"
    let lightId = "7"
    let state = "state"
    let testRequest = LightRequest(on: true, sat: 254, bri: 127,  hue: 48000)
    
    //var allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)

    func lightHttpCall(request:LightRequest, dispatchQueueForHandler:DispatchQueue, completionHandler: @escaping (String?) -> Void){
//        guard let escapedSearchText = SearchText.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) else {
//            dispatchQueueForHandler.async {
//                completionHandler("Couldn't add percent encoding")
//            }
//            return
//        }
      //http://192.168.2.2/api/psmHCxZKbSswfXiXR1RCmph9Ic2WPuW8y8Ndf7dH/lights/7/state
        
        let urlString = urlBase + user + "/" + mode + "/" + lightId + "/" + state
        
        //Initial URLRequest Configuration
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        guard let url = URL(string: urlString) else {
            dispatchQueueForHandler.async {
                completionHandler("Couldn't form the URL")
            }
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        if let data = try? JSONEncoder().encode(request) {
            urlRequest.httpBody = data
        }
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            
            if let error = error {
                dispatchQueueForHandler.async(execute: {
                    completionHandler("error")
                })
            }
            else if let data = data {
                dispatchQueueForHandler.async(execute: {
                    completionHandler("no error")
                })
            }
        }
        task.resume()
    }
}
