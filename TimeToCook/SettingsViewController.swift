//
//  SettingsViewController.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 4/26/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var tbController: TabBarController!
    
    @IBOutlet weak var autoplaySwitch: UISwitch!
    @IBOutlet weak var textToSpeechSwitch: UISwitch!
    
    // Called when autoplay switch is switched
    @IBAction func autoplaySwitchSwitched(sender: AnyObject) {
        self.tbController.settings!.setAutoplay(autoplaySwitch.on)
        DBManager.setAutoplay(autoplaySwitch.on, email: self.tbController.email)
    }
    
    // Called when textToSpeech switch is switched
    @IBAction func textToSpeechSwitchSwitched(sender: AnyObject) {
        self.tbController.settings!.setTextToSpeech(textToSpeechSwitch.on)
        DBManager.setSpeech(textToSpeechSwitch.on, email: self.tbController.email)
    }
    
    // Executes when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tbController = self.tabBarController as! TabBarController
        
        autoplaySwitch.on = self.tbController.settings!.getAutoplay()
        textToSpeechSwitch.on = self.tbController.settings!.getTextToSpeech()
    }
}