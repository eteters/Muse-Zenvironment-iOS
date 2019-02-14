//
//  ZVOption.swift
//  Muse Zenvironment
//
//  Created by Evan Teters on 2/12/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import Foundation

enum OptionType {
    case textButton
    case indicator
}

struct ZVOption {
    var name:String
    var type:OptionType
}
