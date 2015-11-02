//
//  SafetyGaugeViewController.swift
//  SafetyGauge
//
//  Created by Dalal, Neha (GE Corporate) on 10/7/15.
//  Copyright © 2015 Dalal, Neha (GE Corporate). All rights reserved.
//

import UIKit




class SafetyGaugeViewController: UIViewController {

    @IBOutlet weak var currentLocation: UILabel!
    
    @IBOutlet weak var incidentsCountLabel: UILabel!
    @IBOutlet weak var incidentsCountShieldLabel: UILabel!
    
    @IBOutlet weak var crimeRating: UILabel!
    
    @IBOutlet weak var crimeRatingsImageView: UIImageView!
    
    var crimeData: CrimeData? {
        get {
            if let appDelegate = UIApplication.sharedApplication().delegate  as? AppDelegate{
                return appDelegate.crimeData
            }else {
                NSLog("Failed to get crime data from app delegate")
            }
            return nil
        }
        set(newCrimeData) {
            
            if let appDelegate = UIApplication.sharedApplication().delegate  as? AppDelegate
            {
                if newCrimeData != nil{
                    appDelegate.crimeData = newCrimeData!
                }
            }
            else {
                NSLog("Failed to set crime data in app delegate")
            }
        }
    }

    

    func showCrimeData(newCrimeData: CrimeData?) {
     
        if let crimeData = newCrimeData{
            
            dispatch_async(dispatch_get_main_queue(), {
                self.incidentsCountLabel.text = "\(crimeData.incidentsCount) Incidents"
                self.incidentsCountShieldLabel.text = "\(crimeData.incidentsCount)"
                self.crimeRating.text = crimeData.crimeRating.rawValue
                if let crimeImage = UIImage(named: CrimeDataUtil.getCrimeImage(crimeRating: crimeData.crimeRating)) {
                    self.crimeRatingsImageView.image = crimeImage
                }
                
                self.currentLocation.text = crimeData.currentLocation
            })
        }
        
    }
    

    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        

    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        

    }
        
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
