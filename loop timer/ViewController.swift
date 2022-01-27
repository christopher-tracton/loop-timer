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
    var nextTimer  = 1
    var countMode  = 0
    var batchArray = [1,5,15,34,65,111,175,260,369]
    
    @IBOutlet weak var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        countMode = singleMode
        updateButtonTitle()
        // Do any additional setup after loading the view.
    }

    @IBAction func didChangeSegment(_ sender: UISegmentedControl ) {
        if sender.selectedSegmentIndex == 0 {
            print("switch to single")
            countMode = singleMode
            nextTimer = 1
            updateButtonTitle()
        } else {
            print("switch to batch")
            countMode = batchMode
            nextTimer = 0
            updateButtonTitle()
        }
    }
    
    @IBAction func action(_ sender: Any) {
        print ("button was pressed")
        nextTimer += 1
        updateButtonTitle()
    }
    
    func updateButtonTitle() {
        var title : String?
        if countMode==singleMode {
            title = "Next: \(nextTimer)"
        } else {
            title = "Next: \(batchArray[nextTimer])"
        }
        button.setTitle(title, for: .normal)
    }
}

