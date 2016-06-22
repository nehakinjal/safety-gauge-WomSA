//
//  AppDelegate.swift
//  SafetyGauge
//
//  Created by Dalal, Neha (GE Corporate) on 10/6/15.
//  Copyright © 2015 Dalal, Neha (GE Corporate). All rights reserved.
//

import UIKit
import CoreLocation
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, WCSessionDelegate  {

    var window: UIWindow?
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    var locationUpdatesStarted: Bool = false

    var latitude: Double?
    
    var longitude: Double?
    
    var crimeDataHelper: CrimeDataHelper = CrimeDataHelper()
    
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }
    
    var showCrimeDataOnWatch: ((CrimeData) -> Void)? = nil

    var crimeData: CrimeData = CrimeData(currentLocation: "Unknown", incidentsCount: 0)

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Override point for customization after application launch.
        self.startLocationUpdates()
        
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK: Location detection
    
    var locationServicesAvailable :Bool
        {
        get {
            return (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse)
        }
    }
    
    //MARK: - Location manager
    
    internal func startLocationUpdates(){
        
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        if self.locationServicesAvailable
        {
            self.locationManager.startUpdatingLocation() //startMonitoringSignificantLocationChanges
            self.locationUpdatesStarted = true
        } else
        {
            let osVersion = UIDevice.currentDevice().systemVersion
            
            var versionComponents = osVersion.componentsSeparatedByString(".")
            
            if  versionComponents.count > 1 {
                if Float(versionComponents[0]) >= 8.0 {
                    self.locationManager.requestWhenInUseAuthorization() //requestAlwaysAuthorization
                }
            }
        }
        
    }
    
    internal func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.AuthorizedWhenInUse  && !self.locationUpdatesStarted{
            locationManager.startUpdatingLocation()
            self.locationUpdatesStarted = true
        }
    }
    
    internal func isSameLocation(newLatitude: Double, newLongitude: Double) -> Bool {
        
        let locationSame = (self.latitude == newLatitude && self.longitude == newLongitude)
        
        return locationSame
    }
    
    
    internal func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location:CLLocation = locations.last {
            
            //locationManager.stopUpdatingLocation()
            
            if self.isSameLocation(location.coordinate.latitude, newLongitude: location.coordinate.longitude) {
                print("Location still the same")
                self.showCrimeData()
                return
            }
            
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            
            NSLog("GPS Co-ordinates - Latitude:\(self.latitude) Longitude:\(self.longitude) ")
            
            self.crimeDataHelper.dummyGetCrimesForGeoCode(self.latitude, longitude:self.longitude, forLastMonths: 3, crimeDataHelperResults: { (incidentsCount) -> Void in
                
                self.crimeData.incidentsCount = incidentsCount
                NSLog("Incidents at current location \(incidentsCount)")
                self.showCrimeData()
            })
            
            
            let geoCoder = CLGeocoder()
            
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks:[CLPlacemark]?, error:NSError?) -> Void in
                
                if let placemarksAvailable = placemarks {
                    for placemark in placemarksAvailable {
                        if let locality = placemark.locality {
                            
                            self.crimeData.currentLocation = locality
                            NSLog("Location Detected \(locality)")
                            
                            self.showCrimeData()
                        
                        }
                    }
                }
            })
        }
    }
    
    func showCrimeData() {
        
        if  let window : UIWindow = self.window!,
            let tabVC : UITabBarController = window.rootViewController as? UITabBarController,
            let sgVC = tabVC.viewControllers?[0] as? SafetyGaugeViewController
        {
            sgVC.showCrimeData(self.crimeData)
        }
        
        if let showCrimeDataOnWatch = self.showCrimeDataOnWatch {
            showCrimeDataOnWatch(self.crimeData)
        }
    }
    
    //MARK: WCSessionDelegate
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        self.showCrimeDataOnWatch = { (crimeData) -> Void in
            
            if let _ = message["location"] as? String {
                
                var response : [String : AnyObject]
                
                response = [
                    "currentLocation": self.crimeData.currentLocation,
                    "incidentsCount": self.crimeData.incidentsCount
                ]
                
                print("Send crime data location: \(self.crimeData.currentLocation) incidents: \(self.crimeData.incidentsCount)")
                replyHandler(response)
                
            }
        
        }
    
        self.startLocationUpdates()
        
    }

    
}

