//
//  LightRequest.swift
//  Muse Zenvironment
//
//  Created by Evan Teters on 3/10/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import Foundation

struct LightRequest:Encodable {
    var on:Bool
    var sat:Int
    var bri:Int
    var hue:Int
//    var xy:[Double]
//    var effect:String
    
}
