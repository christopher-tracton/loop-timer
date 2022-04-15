//
//  ViewController.swift
//  loop timer
//
//  Created by Christopher Tracton on 2022-01-27.
//

import UIKit

class ViewController: UIViewController {
    let singleMode = 0
    let batchMode  = 1
    var status = ["countMode":0, "nextTimer":1]
    let batchArray = [1,5,15,34,65,111,175,260,369]
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        status["countMode"] = singleMode
        if (!loadConfiguration())
        {
            print("configuration could not be loaded")
        }
        
        requestPermissionForNotifications()
        updateButtonTitle(setupNotification:false)
        segmentControl.selectedSegmentIndex = status["countMode"]!
        // Do any additional setup after loading the view.
    }

    @IBAction func didChangeSegment(_ sender: UISegmentedControl ) {
        if sender.selectedSegmentIndex == 0 {
            print("switch to single")
            status["countMode"] = singleMode
            status["nextTimer"] = 1
            updateButtonTitle()
        } else {
            print("switch to batch")
            status["countMode"] = batchMode
            status["nextTimer"] = 0
            updateButtonTitle()
        }
    }
    
    @IBAction func action(_ sender: Any) {
        print ("button was pressed")
        status["nextTimer"]! += 1
        updateButtonTitle()
        let ok = saveConfiguration()
        if (!ok)
        {
            print ("could not save configuration")
        }
    }
    
    func updateButtonTitle(setupNotification:Bool = true) {
        var title : String?
        var message : String?
        let index = status["nextTimer"]!
        if status["countMode"]==singleMode {
            title = "Next: \(index)"
            message = "\(index) complete"
            if (setupNotification)
            {
                scheduleNotification(title: "single", text: message!, delayInMinutes: index)
            }
        } else {
            let batchIndex = batchArray[index]
            title = "Next: \(batchIndex)"
            message = "\(batchIndex) complete"
            if (setupNotification)
            {
                scheduleNotification(title: "batch", text: message!, delayInMinutes: batchIndex)
            }
        }
        button.setTitle(title, for: .normal)
    }
    
    func saveConfiguration() -> Bool
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let docuDir = paths.firstObject as! String
        let configUrl = URL(fileURLWithPath: docuDir).appendingPathComponent("config.plist")
        let filemanager = FileManager.default

        let filePath = configUrl.path
        
        if (!filemanager.fileExists(atPath: filePath))
        {
            if (!filemanager.createFile(atPath: filePath, contents: nil))
            {
                print("Could not save configuration")
            }
        }

        do
        {
            let plistData = try PropertyListSerialization.data(fromPropertyList: self.status, format: .xml, options: 0)
            try plistData.write(to: configUrl)
        }
        catch
        {
            print(error)
        }

        return true
    }
    
    func loadConfiguration() -> Bool
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let docuDir = paths.firstObject as! String
        let configUrl = URL(fileURLWithPath: docuDir).appendingPathComponent("config.plist")
        let filemanager = FileManager.default

        let filePath = configUrl.path
        
        
        if (filemanager.fileExists(atPath: filePath))
        {
            do
            {
                let data = try Data(contentsOf: configUrl)
                guard let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Int] else {
                    return false
                }
                
                status = plist
            }
            catch
            {
                print(error)
            }

        }
        else
        {
            return false
        }
        
        return true
    }

    func requestPermissionForNotifications()
    {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            if let error = error {
                // Handle the error here.
            }
            
            // Enable or disable features based on the authorization.
        }
    }
    
    func scheduleNotification(title: String, text: String, delayInMinutes: Int)
    {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = text
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (Double(delayInMinutes)*60), repeats: false)

        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil {
              // Handle any errors.
           }
        }
    }
    
}

