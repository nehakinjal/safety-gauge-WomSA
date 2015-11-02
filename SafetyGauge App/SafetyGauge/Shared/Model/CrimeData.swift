//
//  CrimeData.swift
//  SafetyGauge
//
//  Created by Dalal, Neha (GE Corporate) on 10/23/15.
//  Copyright © 2015 Dalal, Neha (GE Corporate). All rights reserved.
//

import UIKit

class CrimeData: NSObject {
    
    var currentLocation: String
    
    var incidentsCount: Int
    
    var crimeRating: CrimeLevel {
        get { return CrimeLevel.getCrimeLevel(self.incidentsCount)}
    }
    
    init(currentLocation: String, incidentsCount:Int) {
        
        self.currentLocation = currentLocation
        self.incidentsCount = incidentsCount
    }
}

enum CrimeLevel : String {
    case High, Medium, Low
    
    internal static func getCrimeLevel(incidents: Int) -> (CrimeLevel) {
        
        var level:CrimeLevel
        
        if incidents <= 25 {
            level = Low
        } else if incidents <= 50 {
            level = Medium
        } else  {
            level = High
        }
        
        return level
    }
    
}