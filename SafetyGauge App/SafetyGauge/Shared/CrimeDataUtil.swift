//
//  CrimeDataUtil.swift
//  SafetyGauge
//
//  Created by Dalal, Neha (GE Corporate) on 10/25/15.
//  Copyright © 2015 Dalal, Neha (GE Corporate). All rights reserved.
//

import Foundation

class CrimeDataUtil
{
    internal static func getCrimeImage(crimeRating crimeRating: CrimeLevel) -> String
    {
        var crimeBackgroundImage: String = "shield_low"
        switch(crimeRating) {
        case .High:
            crimeBackgroundImage = "shield_high"
        case .Medium:
            crimeBackgroundImage = "shield_medium"
        case .Low:
            crimeBackgroundImage = "shield_low"
        }
        
        return crimeBackgroundImage
    }
}
