//
//  CrimeDataHelper.swift
//  SafetyGauge
//
//  Created by Dalal, Neha (GE Corporate) on 10/20/15.
//  Copyright © 2015 Dalal, Neha (GE Corporate). All rights reserved.
//

import UIKit

class CrimeDataHelper: NSObject {

    let kCrimeRatingService = NSURL(string: "https://jgentes-Crime-Data-v1.p.mashape.com/")
    let kCrimeDataHelperAPIKey = "o0KGxCX5wYmshg3prcYlb6fVqpe3p1hMEcejsn3ng4idnmhUNA"
    
    var crimeRatingRetrivalInProgress = false
    
    
    func httpGet(request: NSURLRequest!, callback: (NSData?, NSError?) -> Void)
    {
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request)
            {  (data, responseOptional, error) -> Void in
                
            if error != nil {
                callback(nil, error!)
                NSLog("Failed to retrieve Crime data")
                
            } else {
                
                if let response = responseOptional as? NSHTTPURLResponse where response.statusCode == 200
                {
                    callback(data, nil)
                }
            }
        }
        task.resume()
    }
    
    internal func getCrimesForGeoCode(latitude: Double?,
                                    longitude:Double?,
                                    forLastMonths: Int,
                                    crimeDataHelperResults: (incidentsCount:Int) -> Void)
    {
        if self.crimeRatingRetrivalInProgress {
            return
        }
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        
        guard let monthsAgo = calendar.dateByAddingUnit(.Month, value: (-1 * forLastMonths), toDate: NSDate(), options: NSCalendarOptions.WrapComponents) else {
            
            NSLog("Cannot get date \(forLastMonths) months ago")
            return
        }
        
        if latitude == nil || longitude == nil {
            
            NSLog("Location not detected to retrieve crime data")
            return
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .NoStyle;
        dateFormatter.dateStyle = .ShortStyle;
        
        if let startDate = dateFormatter.stringFromDate(monthsAgo).stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()),
            let endDate = dateFormatter.stringFromDate(date).stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()),
            let lat = latitude,
            let long = longitude
        {
            
            let requestString = String("crime?enddate=\(endDate)&lat=\(lat)&long=\(long)&startdate=\(startDate)")
            
            if  let url = NSURL(string: requestString, relativeToURL: self.kCrimeRatingService)
            {
                self.crimeRatingRetrivalInProgress = true
                let request = NSMutableURLRequest(URL: url)
                
                request.addValue(self.kCrimeDataHelperAPIKey, forHTTPHeaderField: "X-Mashape-Key")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                self.httpGet(request, callback: { (data, errorOptional) -> Void in
                    
                    if errorOptional == nil
                    {
                        do {
                            let array = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as! NSArray
                            
                            NSLog("Number of incidents reported: \(array.count)")
                            crimeDataHelperResults(incidentsCount:array.count)

                        }
                        catch let error as NSError
                        {
                            
                            NSLog("Failed to retrive crime data with Error - Failed to get array from data - <\(error)")
                        }
                    }
                    else {
                        NSLog("Failed to retrive crime data with Error - \(errorOptional?.localizedDescription)")
                    }
                    
                    self.crimeRatingRetrivalInProgress = false
                })
            }
        }
        
    }
    
}

