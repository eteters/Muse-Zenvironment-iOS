//
//  ZVTimer.swift
//  Muse Zenvironment
//
//  Created by Evan Teters on 4/12/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import Foundation
import UIKit

protocol TimerDelegate {
    func changeImage(image:UIImage)
}

class ZVTimer {
    var timer = Timer()
    
    var delegate:TimerDelegate!
    
    func startUpdates() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { (tim) in
            self.imageApiCall(dispatchQueueForHandler: DispatchQueue.main, completionHandler: { (image) in
                self.delegate.changeImage(image: image)
            })
        })
        
//        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(imageApiCall(dispatchQueueForHandler:completionHandler:)), userInfo: nil, repeats: true)
    }

    
    func imageApiCall(dispatchQueueForHandler:DispatchQueue, completionHandler: @escaping (UIImage) -> Void){
        guard let url = URL(string: "https://picsum.photos/750/1334/?random")  else{
            return
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let urlRequest = URLRequest(url: url)
        
        let task = session.dataTask(with: urlRequest) { (data, responseCode, error) in
            guard error == nil, let data = data else {
                var errorString = "urlRequest did not work"
                if let error = error {
                    errorString = error.localizedDescription
                }
                //                    dispatchQueueForHandler.async(execute: {
                //                        completionHandler(errorString)
                //                    })
                return
            }
            
            if let image = UIImage(data: data) {
                dispatchQueueForHandler.async(execute: {
                    completionHandler(image)
                })
            }
        }
        
        task.resume()
    }
    
}
