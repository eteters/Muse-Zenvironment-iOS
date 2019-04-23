//
//  HeadbandMessage.swift
//  Muse Zenvironment
//
//  Created by Evan Teters on 2/6/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import Foundation

struct HeadbandMessage:Decodable {
    var alphaRelaxation:Double
    var betaConcentration:Double
    var thetaRelaxation:Double
    var headMovementHorizontal:Double
    var headMovementVertical: Double
    var movement:Double
    var blink:Bool?
    var jawClench:Bool?
    
    
    
    //TODO: define the translation from alpha-relaxation etc
    enum CodingKeys: String, CodingKey {
        case alphaRelaxation = "alpha-relaxation"
        case betaConcentration = "beta-concentration"
        case thetaRelaxation = "theta-relaxation"
        case headMovementHorizontal = "head-movement-horizontal"
        case headMovementVertical = "head-movement-vertical"
        case movement //this is fine for now
        
        case blink
        case jawClench = "jaw_clench"
    }
}
