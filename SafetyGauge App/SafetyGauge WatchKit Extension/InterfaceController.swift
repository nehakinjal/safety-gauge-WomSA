//
//  InterfaceController.swift
//  SafetyGauge WatchKit Extension
//
//  Created by Dalal, Neha (GE Corporate) on 10/6/15.
//  Copyright © 2015 Dalal, Neha (GE Corporate). All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import UIKit

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    var crimeData:CrimeData = CrimeData(currentLocation: "", incidentsCount: 0)
    
    @IBOutlet var crimeLevel: WKInterfaceGroup!
    
    @IBOutlet var locationLabel: WKInterfaceLabel!
    
    @IBOutlet var incidentsLabel: WKInterfaceLabel!
    
    
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        self.showCrimeData()

    }
    
    func showCrimeData() {

        self.incidentsLabel.setText("\(crimeData.crimeRating.rawValue)\n\n\(self.crimeData.incidentsCount)\n\nIncidents")
        
        if crimeData.currentLocation.isEmpty {
            self.locationLabel.setText("Unknown")
        } else {
            self.locationLabel.setText(crimeData.currentLocation)
        }

        if let crimeImage = UIImage(named: CrimeDataUtil.getCrimeImage(crimeRating: self.crimeData.crimeRating)) {
            self.crimeLevel.setBackgroundImage(crimeImage)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func didAppear() {
        super.didAppear()
        
        if WCSession.isSupported() {
            
            session = WCSession.defaultSession()
            let message : [String : AnyObject]
            message = ["location" : "GPS Detected"]
            
            print("Watch asking for crime data...")
            session!.sendMessage(message, replyHandler: { (response) -> Void in
                
                if let currentLocation = response["currentLocation"] as? String,
                    let incidentsCount = response["incidentsCount"] as? Int{
                    
                    self.crimeData = CrimeData(currentLocation: currentLocation, incidentsCount: incidentsCount)
                     
                    print("Send crime data location: \(self.crimeData.currentLocation) incidents: \(self.crimeData.incidentsCount)")
                        
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.showCrimeData()
                    })
                }
                }, errorHandler: { (error) -> Void in
                    
                    print(error)
            })
        }
    }

}
