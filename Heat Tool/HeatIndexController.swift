//
//  ViewController.swift
//  Heat Tool
//
//  Created by E J Kalafarski on 1/14/15.
//  Copyright (c) 2015 OSHA. All rights reserved.
//

import UIKit
import CoreLocation

class HeatIndexController: GAITrackedViewController, CLLocationManagerDelegate, NSXMLParserDelegate, UITextFieldDelegate {
    
    // Create globals for buttons and labels, so they can be updated with the risk state/background color
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var locationActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var temperatureTextField: UITextField!
    @IBOutlet weak var humidityTextField: UITextField!
    
    var temperatureLabel = UILabel()
    var humidityLabel = UILabel()
    
    @IBOutlet weak var nowLabel: UILabel!
    @IBOutlet weak var riskButtonNow: UIButton!
    @IBOutlet weak var feelsLikeNow: UILabel!
    
    @IBOutlet weak var todaysMaxContainer: UIView!
    @IBOutlet weak var todaysMaxLabel: UILabel!
    @IBOutlet weak var todaysMaxRisk: UIButton!
    @IBOutlet weak var todaysMaxTime: UILabel!
    
    // Create global for location manager
    var locManager: CLLocationManager!
    
    // Create globals for parser functions
    var parser = NSXMLParser()
    var times = NSMutableArray()
    var temperatures = NSMutableArray()
    var humidities = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var buffer = NSMutableString()
    var inHourlyTemp = false
    var inHourlyHumidity = false
    
    // Create a global to keep track of risk state/background color
    var riskLevel = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set up reference to this view for app delegate so we can refresh data when the app enters the foreground
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        appDelegate.myHeatIndexController = self
        
        // View name for Google Analytics
        self.screenName = "Heat Index Screen"
        
        // Starter colors for navbar
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
        
        // Give rounded corners to custom text fields
        temperatureTextField.layer.cornerRadius = 6.0
        humidityTextField.layer.cornerRadius = 6.0
        temperatureTextField.layer.borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5).CGColor
        humidityTextField.layer.borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5).CGColor
        temperatureTextField.layer.borderWidth = 0.5
        humidityTextField.layer.borderWidth = 0.5
        
        // Add icons to left inset of text fields
        locationTextField.leftViewMode = UITextFieldViewMode.Always
        locationTextField.leftView = UIImageView(image: UIImage(named: "geo")?.imageWithRenderingMode(.AlwaysTemplate))
        temperatureTextField.leftViewMode = UITextFieldViewMode.Always
        temperatureTextField.leftView = UIImageView(image: UIImage(named: "temperature")?.imageWithRenderingMode(.AlwaysTemplate))
        humidityTextField.leftViewMode = UITextFieldViewMode.Always
        humidityTextField.leftView = UIImageView(image: UIImage(named: "humidity")?.imageWithRenderingMode(.AlwaysTemplate))
        
        // Add labels to right inset of text fields
        temperatureLabel = UILabel(frame: CGRectZero)
        temperatureLabel.backgroundColor = UIColor.clearColor()
        temperatureLabel.font = UIFont.systemFontOfSize(15)
        temperatureLabel.textColor = UIColor.blackColor()
        temperatureLabel.alpha = 1
        temperatureLabel.text = "°F"
        temperatureLabel.frame = CGRect(x:0, y:0, width:20, height:15)
        
        temperatureTextField.rightViewMode = UITextFieldViewMode.Always
        temperatureTextField.rightView = temperatureLabel
        
        humidityLabel = UILabel(frame: CGRectZero)
        humidityLabel.backgroundColor = UIColor.clearColor()
        humidityLabel.font = UIFont.systemFontOfSize(15)
        humidityLabel.textColor = UIColor.blackColor()
        humidityLabel.alpha = 1
        humidityLabel.text = "%"
        humidityLabel.frame = CGRect(x:0, y:0, width:20, height:15)
        
        humidityTextField.rightViewMode = UITextFieldViewMode.Always
        humidityTextField.rightView = humidityLabel
        
        // Set up toolbar with completion button for keyboard
        var doneToolbar: UIToolbar = UIToolbar()
        doneToolbar.barStyle = UIBarStyle.Default
        
        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        var done: UIBarButtonItem = UIBarButtonItem(title: "Set", style: UIBarButtonItemStyle.Done, target: self, action: Selector("doneButtonAction"))
        
        var items = NSMutableArray()
        items.addObject(flexSpace)
        items.addObject(done)
        
        doneToolbar.items = items as [AnyObject]
        doneToolbar.sizeToFit()
        
        self.temperatureTextField.inputAccessoryView = doneToolbar
        self.humidityTextField.inputAccessoryView = doneToolbar
        
        // Set up text input field handlers
        self.temperatureTextField.delegate = self
        self.humidityTextField.delegate = self
        self.locationTextField.delegate = self
        
        // Center button text
        self.riskButtonNow.titleLabel?.textAlignment = .Center
        self.todaysMaxRisk.titleLabel?.textAlignment = .Center
        
        // Set button images so they always respect tint color
        self.riskButtonNow.setImage(UIImage(named:"chevron")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        self.todaysMaxRisk.setImage(UIImage(named:"chevron")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        
        // Set up location manager for getting our location
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization();
    }
    
    // Update state with the user's location when didChangeAuthorizationStatus fires on load
    func locationManager(manager: CLLocationManager!,didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            // Record GA event
            var tracker = GAI.sharedInstance().defaultTracker
            tracker.send(GAIDictionaryBuilder.createEventWithCategory("app", action: "open-app", label: "get-current-conditions", value: nil).build() as [NSObject : AnyObject])
            
            // Get current conditions
            self.locationActivityIndicator.startAnimating()
            manager.startUpdatingLocation()
        }
    }
    
    // When the user's location is available
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        // We don't need it to keep updating, so stop the manager
        locManager.stopUpdatingLocation()
        
        // Request and parse NOAA API with current coordinates
        times = []
        temperatures = []
        humidities = []
        
        // Use current coordinates to input and parse the NOAA API
        parser = NSXMLParser(contentsOfURL: (NSURL(string: "http://forecast.weather.gov/MapClick.php?lat=\(locations[locations.count-1].coordinate.latitude)&lon=\(locations[locations.count-1].coordinate.longitude)&FcstType=digitalDWML")))!
        
        // South Texas, for some nice testing
//        parser = NSXMLParser(contentsOfURL: (NSURL(string: "http://forecast.weather.gov/MapClick.php?lat=25.902470&lon=-97.418151&FcstType=digitalDWML")))!
        
        parser.delegate = self
        parser.parse()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        element = elementName
        
        buffer = NSMutableString.alloc()
        buffer = ""
        
        if attributeDict["type"] != nil {
            if attributeDict["type"] as! NSString == "hourly" {
                inHourlyTemp = true
            }
        }
        
        if elementName == "humidity" {
            inHourlyHumidity = true
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        buffer.appendString(string!)
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "description" || elementName == "area-description" {
            self.locationTextField.text = buffer as String
        }
        
        if elementName == "start-valid-time" {
            times.addObject(buffer)
        }
        
        if elementName == "value" && inHourlyTemp {
            temperatures.addObject(buffer)
        }
        
        if elementName == "value" && inHourlyHumidity {
            humidities.addObject(buffer)
        }
        
        if elementName == "temperature" && inHourlyTemp {
            inHourlyTemp = false
        }
        
        if elementName == "humidity" {
            inHourlyHumidity = false
        }
        
        // If parsing is complete
        if elementName == "dwml" {
            // Set text field temperature and humidity to the first hour in the forecast
            self.temperatureTextField.text = temperatures[0] as! String
            self.humidityTextField.text = humidities[0] as! String
            
            // Switch temperature and humidity fields to auto-filled styling
            self.temperatureTextField.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.0)
            self.humidityTextField.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.0)
            
            // Geolocation and parsing are complete
            self.locationActivityIndicator.stopAnimating()
            
            // Update today's max risk from fetched hourly values
            // N.B. Today's max should be calculated before overall risk level, so that app state styling controlled by overall risk can take it into account
            self.updateTodaysMaxRiskLevel()
            
            // Update main risk from text field values
            self.updateRiskLevel()
        }
    }
    
    // A function to calculate the heat index from a temperature/humidity combination
    func calculateHeatIndex(tempInF: Double, humidity: Double) -> Double {
        // Heat index calculation applies only to temps >= 80°
        if tempInF < 80.0 {
            return tempInF
        } else {
            var calculatedHeatIndexF = 0.0
            
            // Broke the formula up in pieces since its orginal incarnation was causing problems with Xcode
            calculatedHeatIndexF = -42.379 + (2.04901523 * tempInF)
            calculatedHeatIndexF += 10.14333127 * humidity
            calculatedHeatIndexF -= 0.22475541 * tempInF * humidity
            calculatedHeatIndexF -= 6.83783 * pow(10, -3) * pow(tempInF,2)
            calculatedHeatIndexF -= 5.481717 * pow(10,-2) * pow(humidity,2)
            calculatedHeatIndexF += 1.22874 * pow(10, -3) * pow(tempInF,2) * humidity
            calculatedHeatIndexF += 8.5282 * pow(10,-4) * tempInF * pow(humidity,2)
            calculatedHeatIndexF -= 1.99 * pow(10,-6) * pow(tempInF, 2) * pow(humidity, 2)
            
            return calculatedHeatIndexF
        }
    }
    
    // Update the "today's max" risk
    func updateTodaysMaxRiskLevel() {
        // Look for the maximum for the rest of the day
        var maxIndex = -1
        var maxTime:String = ""
        var maxHeatIndex = -1000.0
        
        // For the next 24 hours, stopping at midnight
        for index in 0...23 {
            // Get a date object for this hour's time
            var newTime = (times[index] as! NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            // Get a clean 12-hour readout of this hour's time
            let newDateFormatter = NSDateFormatter()
            newDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
            let newDate = newDateFormatter.dateFromString(newTime)
            newDateFormatter.dateFormat = "h:mm a"
            var newHour = newDateFormatter.stringFromDate(newDate!)
            
            // Stop the loop when we hit midnight
            if newHour == "12:00 AM" {
                break
            }
            
            // Calculate the heat index for this hour
            var newTempDouble = (temperatures[index] as! NSString).doubleValue
            var newHumidityDouble = (humidities[index] as! NSString).doubleValue
            var newHeatIndex = calculateHeatIndex(newTempDouble, humidity: newHumidityDouble)
            
            // Print out this hour's data
//            println("Hour \(index): Time: \(newHour) Temp: \(temperatures[index]), Humidity: \(humidities[index])")
            
            // If the heat index exists and is higher than previous ones, mark it as the new high
            if newTempDouble > 80.0 && newHeatIndex > maxHeatIndex {
                maxIndex = index
                maxHeatIndex = newHeatIndex
                maxTime = newTime
            }
        }
        
        // Print out the final max hour
//        println("Max \(maxIndex): Heat: \(maxHeatIndex)")
        
        // If risk won't be greater than minimal for the rest of the day
        if maxIndex == -1 {
            // Set the title on the button
            self.todaysMaxRisk.setTitle(NSLocalizedString("Minimal Risk From Heat", comment: "Minimal Risk Title"), forState: .Normal)
            
            // Blank out when the max is occurring because it doesn't apply
            self.todaysMaxTime.text = ""
        // If the risk now is the highest for the rest of the day
        } else if maxIndex == 0 {
            // Set the title on the button
            switch maxHeatIndex {
            case 0..<91:
                self.todaysMaxRisk.setTitle(NSLocalizedString("Lower Risk (Use Caution)", comment: "Low Risk Title"), forState: .Normal)
            case 91..<104:
                self.todaysMaxRisk.setTitle(NSLocalizedString("Moderate Risk", comment: "Moderate Risk Title"), forState: .Normal)
            case 104..<116:
                self.todaysMaxRisk.setTitle(NSLocalizedString("High Risk", comment: "High Risk Title"), forState: .Normal)
            case 116..<1000:
                self.todaysMaxRisk.setTitle(NSLocalizedString("Very High To Extreme Risk", comment: "Very High Risk Title"), forState: .Normal)
            default:
                println("default")
            }
            
            // Indicate that the max is occurring now
            self.todaysMaxTime.text = NSLocalizedString("Now", comment: "Now Title")
        // If there's a higher risk coming
        } else {
            switch maxHeatIndex {
            case 0..<91:
                self.todaysMaxRisk.setTitle(NSLocalizedString("Lower Risk (Use Caution)", comment: "Low Risk Title"), forState: .Normal)
            case 91..<104:
                self.todaysMaxRisk.setTitle(NSLocalizedString("Moderate Risk", comment: "Moderate Risk Title"), forState: .Normal)
            case 104..<116:
                self.todaysMaxRisk.setTitle(NSLocalizedString("High Risk", comment: "High Risk Title"), forState: .Normal)
            case 116..<1000:
                self.todaysMaxRisk.setTitle(NSLocalizedString("Very High To Extreme Risk", comment: "Very High Risk Title"), forState: .Normal)
            default:
                println("default")
            }
            
            // Indicate the hour at which the max will occur
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
            let date = dateFormatter.dateFromString(maxTime)
            dateFormatter.dateFormat = "h:mm a"
            self.todaysMaxTime.text = NSLocalizedString("At", comment: "At Title") + " \(dateFormatter.stringFromDate(date!))"
        }
        
        // Update the interface
        UIView.animateWithDuration(0.75, delay: 0.0, options: nil, animations: {
            // Make sure today's max container is visible
            self.todaysMaxContainer.alpha = 1
            
            // Disable precautions button if minimal risk state
            if (self.todaysMaxRisk.titleLabel?.text == NSLocalizedString("Minimal Risk From Heat", comment: "Minimal Risk Title")) {
                self.todaysMaxRisk.enabled = false
            } else {
                self.todaysMaxRisk.enabled = true
            }
            
            }, completion: nil)
    }
    
    // Update the risk state/background color of the app
    func updateRiskLevel() {
        var tempInF = Double(temperatureTextField.text.toInt()!)
        var humidity = Double(humidityTextField.text.toInt()!)
        var perceivedTemperature = calculateHeatIndex(tempInF, humidity: humidity)
        
        var riskTitleString = ""
        
        var backgroundColor = UIColor()
        var buttonColor = UIColor()
        var labelColor = UIColor()
        var disabledColor = UIColor()
        
        // Based on the perceived temperature, determine the app's state
        switch Int(perceivedTemperature) {
        case -1000..<80:
            self.riskLevel = 0
            riskTitleString = NSLocalizedString("Minimal Risk From Heat", comment: "Minimal Risk Title")
            
            backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
            buttonColor = UIColor.blackColor()
            labelColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
            disabledColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.2)
        case 80..<91:
            self.riskLevel = 1
            riskTitleString = NSLocalizedString("Lower Risk (Use Caution)", comment: "Low Risk Title")
            
            backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0)
            buttonColor = UIColor.blackColor()
            labelColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
            disabledColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 0.3)
        case 91..<104:
            self.riskLevel = 2
            riskTitleString = NSLocalizedString("Moderate Risk", comment: "Moderate Risk Title")
            
            backgroundColor = UIColor(red: 1.0, green: 0.675, blue: 0.0, alpha: 1.0)
            buttonColor = UIColor.blackColor()
            labelColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
            disabledColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 0.3)
        case 104..<116:
            self.riskLevel = 3
            riskTitleString = NSLocalizedString("High Risk", comment: "High Risk Title")
            
            backgroundColor = UIColor.orangeColor()
            buttonColor = UIColor.whiteColor()
            labelColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
            disabledColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.4)
        case 116..<1000:
            self.riskLevel = 4
            riskTitleString = NSLocalizedString("Very High To Extreme Risk", comment: "Very High Risk Title")
            
            backgroundColor = UIColor.redColor()
            buttonColor = UIColor.whiteColor()
            labelColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
            disabledColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.4)
        default:
            println("default")
        }
        
        // Update the interface
        // Set text
        self.riskButtonNow.setTitle(riskTitleString, forState: .Normal)
        if self.locationTextField.text == "" {
            self.nowLabel.text = NSLocalizedString("Calculated", comment: "Calculated Title")
            self.feelsLikeNow.text = NSLocalizedString("Feels Like", comment: "Feels Like Title") + " \(Int(perceivedTemperature))º F"
        } else {
            self.nowLabel.text = NSLocalizedString("Now", comment: "Now Title")
            self.feelsLikeNow.text = NSLocalizedString("Feels Like", comment: "Feels Like Title") + " \(Int(perceivedTemperature))º F"
        }
        
        // Disable current risk precautions button if minimal risk state
        if (self.riskLevel == 0) {
            self.riskButtonNow.enabled = false
            self.riskButtonNow.setTitleColor(disabledColor, forState: .Normal)
            self.riskButtonNow.imageView?.alpha = 0
        } else {
            self.riskButtonNow.enabled = true
            self.riskButtonNow.setTitleColor(buttonColor, forState: .Normal)
            self.riskButtonNow.imageView?.alpha = 1
        }
        
        // Disable max risk precautions button if minimal risk state
        if self.todaysMaxRisk.enabled == false {
            self.todaysMaxRisk.setTitleColor(disabledColor, forState: .Normal)
            self.todaysMaxRisk.imageView?.alpha = 0
        } else {
            self.todaysMaxRisk.setTitleColor(buttonColor, forState: .Normal)
            self.todaysMaxRisk.imageView?.alpha = 1
        }
        
        // Hide "feels like" text if we're below the heat index threshold
        self.feelsLikeNow.alpha = self.riskLevel == 0 ? 0 : 1
        
        // Animate certain interface updates
        UIView.animateWithDuration(0.75, delay: 0.0, options: nil, animations: {
            
            // Change background colors
            self.view.backgroundColor = backgroundColor
            self.navigationController?.navigationBar.barTintColor = backgroundColor
            
            // Change label colors
            self.temperatureLabel.textColor = labelColor
            self.humidityLabel.textColor = labelColor
            self.nowLabel.textColor = labelColor
            self.feelsLikeNow.textColor = labelColor
            self.todaysMaxLabel.textColor = labelColor
            self.todaysMaxTime.textColor = labelColor
            
            // Change button colors
            self.view.tintColor = buttonColor
            self.navigationController?.navigationBar.tintColor = buttonColor
            self.navigationController?.navigationBar.barStyle = (buttonColor == UIColor.blackColor() ? UIBarStyle.Default : UIBarStyle.Black)
            self.locationTextField.textColor = buttonColor
            self.locationActivityIndicator.color = buttonColor
            self.temperatureTextField.textColor = buttonColor
            self.humidityTextField.textColor = buttonColor
            
            }, completion: nil)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        // When location field is tapped
        if textField == locationTextField {
            // If location settings allow, start to get current conditions
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
                // Record GA event
                var tracker = GAI.sharedInstance().defaultTracker
                tracker.send(GAIDictionaryBuilder.createEventWithCategory("location-field", action: "tap", label: "get-current-conditions", value: nil).build() as [NSObject : AnyObject])
                
                // Get current conditions
                self.locationActivityIndicator.startAnimating()
                self.locManager.startUpdatingLocation()
                // If location settings don't allow, display an alert
            } else {
                // Record GA event
                var tracker = GAI.sharedInstance().defaultTracker
                tracker.send(GAIDictionaryBuilder.createEventWithCategory("location-field", action: "tap", label: "location-services-disabled-alert", value: nil).build() as [NSObject : AnyObject])
                
                let alertController = UIAlertController(
                    title: NSLocalizedString("Location Services Disabled", comment: "Location Services Title"),
                    message: NSLocalizedString("To get your local conditions, visit settings to allow the OSHA Heat Safety Tool to use your location when the app is in use.", comment: "Location Services Description"),
                    preferredStyle: .Alert)
                
                // Add a cancel option
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Title"), style: .Cancel, handler: nil))
                
                // Add an option to go to settings
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Settings Title"), style: .Default) { (action) in
                    if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                    })
                
                // Present the alert
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
            // Do not allow the text field to be editable
            return false
            // For all other text fields, allow editing to begin
        } else {
            return true
        }
    }
    
    // When the done button on the keyboard toolbar is tapped
    func doneButtonAction() {
        // Record GA event
        var tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory("keyboard", action: "set", label: "calculate-entered-conditions", value: nil).build() as [NSObject : AnyObject])
        
        self.temperatureTextField.endEditing(true)
        self.humidityTextField.endEditing(true)
        
        // If a field has been left blank, default it to 0
        if self.temperatureTextField.text == "" {
            self.temperatureTextField.text = "0"
        }
        if self.humidityTextField.text == "" {
            self.humidityTextField.text = "0"
        }
        
        self.locationTextField.text = ""
        
        // Change backgrounds of text fields to show they're in "manual" mode
        self.temperatureTextField.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.1)
        self.humidityTextField.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.1)
        
        // Update main risk
        updateRiskLevel()
        
        // Hide "today's max" for user-entered values
        UIView.animateWithDuration(0.75, delay: 0.0, options: nil, animations: {
            self.todaysMaxContainer.alpha = 0
            }, completion: nil)
    }
    
    // Tapping OSHA logo opens the OSHA website in Safari
    @IBAction func openOSHAWebsite(sender: AnyObject) {
        // Record GA event
        var tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory("osha-logo", action: "tap", label: "open-osha-website", value: nil).build() as [NSObject : AnyObject])
        
        // Open website
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.osha.gov")!)
    }
    
    // Tapping DOL logo opens the DOL website in Safari
    @IBAction func openDOLWebsite(sender: AnyObject) {
        // Record GA event
        var tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory("dol-logo", action: "tap", label: "open-dol-website", value: nil).build() as [NSObject : AnyObject])
        
        // Open website
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.dol.gov")!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        // Fill next view with appropriate precautions
        if segue.identifier == "nowPrecautionsSegue" {
            // Record GA event
            var tracker = GAI.sharedInstance().defaultTracker
            tracker.send(GAIDictionaryBuilder.createEventWithCategory("now-risk", action: "tap", label: "open-precautions", value: nil).build() as [NSObject : AnyObject])
            
            // Set variable in the destination controller
            var svc = segue.destinationViewController as! PrecautionsController
            switch self.riskLevel {
            case 1:
                svc.precautionLevel = "precautions_lower"
            case 2:
                svc.precautionLevel = "precautions_moderate"
            case 3:
                svc.precautionLevel = "precautions_high"
            case 4:
                svc.precautionLevel = "precautions_veryhigh"
            default:
                println("default")
            }
        }
        
        // Fill next view with appropriate precautions
        if segue.identifier == "todaysMaxPrecautionsSegue" {
            // Record GA event
            var tracker = GAI.sharedInstance().defaultTracker
            tracker.send(GAIDictionaryBuilder.createEventWithCategory("todays-max-risk", action: "tap", label: "open-precautions", value: nil).build() as [NSObject : AnyObject])
            
            // Set variable in the destination controller
            var svc = segue.destinationViewController as! PrecautionsController
            if let text = self.todaysMaxRisk.titleLabel?.text {
                switch text {
                case NSLocalizedString("Lower Risk (Use Caution)", comment: "Low Risk Title"):
                    svc.precautionLevel = "precautions_lower"
                case NSLocalizedString("Moderate Risk", comment: "Moderate Risk Title"):
                    svc.precautionLevel = "precautions_moderate"
                case NSLocalizedString("High Risk", comment: "High Risk Title"):
                    svc.precautionLevel = "precautions_high"
                case NSLocalizedString("Very High To Extreme Risk", comment: "Very High Risk Title"):
                    svc.precautionLevel = "precautions_veryhigh"
                default:
                    println("default")
                }
            }
        }
        
        // Set tint color of the incoming more info navigation controller to match the app state
        if segue.identifier == "moreInfoSegue" {
            // Record GA event
            var tracker = GAI.sharedInstance().defaultTracker
            tracker.send(GAIDictionaryBuilder.createEventWithCategory("more-info", action: "tap", label: "open-info", value: nil).build() as [NSObject : AnyObject])
            
            // Set tint color of the incoming more info navigation controller to match the app state
            var svc = segue.destinationViewController as! UINavigationController
            switch self.riskLevel {
            // Deeper gray for minimal state
            case 0:
                svc.navigationBar.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            // Deeper yellow for low risk state
            case 1:
                svc.navigationBar.tintColor = UIColor(red: 1.0, green: 0.775, blue: 0.0, alpha: 1.0)
            // Use background color for all other states
            default:
                svc.navigationBar.tintColor = self.view.backgroundColor
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}