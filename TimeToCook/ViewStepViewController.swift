//
//  ViewStepViewController.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 3/21/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import AVFoundation

class ViewStepViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Tab bar controller
    var tbController: TabBarController!
    
    // Sound
    let systemSoundID:SystemSoundID = 1005
    
    // Started
    var running:Bool = false
    
    // Data Model
    private var currentIndex = 0
    private var steps:[Step]!
    private var ingredients:[Ingredient]!
    private var totalTime:Int = 0
    private var currentStep:Step!
    private var recipeName:String!
	var timer: NSTimer = NSTimer()
	var timeLeft: Int = 0
    var alertController: UIAlertController? = nil
	let synch = AVSpeechSynthesizer()
	var myUtterance:AVSpeechUtterance = AVSpeechUtterance(string: "")

    // Views
    @IBOutlet var ingredientsTableView: UITableView!
    private let ingredientCellIdentifier = "CookStepIngredientCell"
    private let overviewSegueIdentifier = "OverviewVCSegue"
    @IBOutlet var directionTextView: UITextView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var prevStepButton:UIButton!
    @IBOutlet var nextStepButton:UIButton!
    @IBOutlet weak var startPauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    func setSteps(steps:[Step]) {
        self.steps = steps
    }
    
    func setCurrentIndex(index:Int) {
        self.currentIndex = index
        updateUI()
    }
    
    @IBAction func doneButtonAction() {
        if self.synch.paused == false {
            self.synch.stopSpeakingAtBoundary(AVSpeechBoundary.Word)
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func btnStartPauseClicked(sender: AnyObject) {
        self.timer.invalidate()
        if !self.running {
            self.startPauseButton.setTitle("Pause", forState: UIControlState.Normal)
            self.running = true
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewStepViewController.timerTick), userInfo: nil, repeats: true)
			if (tbController.settings?.getTextToSpeech()) != nil && (tbController.settings?.getTextToSpeech())! {
				if (self.synch.paused) {
					self.synch.continueSpeaking()
				}
				else {
					self.myUtterance = AVSpeechUtterance(string: currentStep.getDirections())
					self.myUtterance.rate = 0.4
					self.myUtterance.pitchMultiplier = 1.3
					self.synch.speakUtterance(myUtterance)
				}
			}
        } else {
            self.startPauseButton.setTitle("Start", forState: UIControlState.Normal)
            self.running = false
			if self.synch.paused == false {
				self.synch.pauseSpeakingAtBoundary(AVSpeechBoundary.Word)
			}
        }
    }
	
	func timerTick() {
		if self.timeLeft != 0 {
			self.timeLeft -= 1
			self.updateTimer()
            if (self.timeLeft == 0) {
                self.timerDone()
            }
		}
		else {
			self.timer.invalidate()
		}
	}
    
    @IBAction func btnRestartClicked(sender: AnyObject) {
        self.timer.invalidate()
		self.timeLabel.text = currentStep.getFormattedTime()
		self.timeLeft = currentStep.getTime()
        self.startPauseButton.enabled = true
        self.startPauseButton.setTitle("Start", forState: UIControlState.Normal)
        self.running = false
		if (tbController.settings?.getTextToSpeech()) != nil && (tbController.settings?.getTextToSpeech())! {
			self.synch.stopSpeakingAtBoundary(AVSpeechBoundary.Word)
		}
    }
    
    func updateUI() {
        // update the following
        self.currentStep = self.steps[self.currentIndex]
        self.timeLabel.text = self.currentStep.getFormattedTime()
		self.timeLeft = self.currentStep.getTime()
        self.ingredients = self.currentStep.getIngredients()
        self.directionTextView.text = self.currentStep.getDirections()
        
        // Disable timer buttons if this step doesn't have time
        if (self.currentStep.getTime() == 0) {
            self.startPauseButton.enabled = false
            self.resetButton.enabled = false
        } else {
            self.startPauseButton.enabled = true
            self.resetButton.enabled = true
        }
        
        //update table view
        self.ingredientsTableView.reloadData()
        self.title = "Step " + String(self.currentIndex + 1)
        self.currentStep = self.steps[self.currentIndex]
        self.startPauseButton.setTitle("Start", forState: UIControlState.Normal)
        
        // only one step
        if self.currentIndex == 0 && (self.currentIndex + 1) == self.steps.count {
            self.prevStepButton.enabled = false
            self.nextStepButton.enabled = false
        }
            
        // edge cases
        else if (currentIndex == 0) {
            self.prevStepButton.enabled = false
            self.nextStepButton.enabled = true
        }
            
        else if (currentIndex + 1) == steps.count {
            self.nextStepButton.enabled = false
            self.prevStepButton.enabled = true
        }
            
        else {
            self.prevStepButton.enabled = true
            self.nextStepButton.enabled = true
        }
        
        // If autoplay, start the timer
        if self.tbController.settings!.getAutoplay() {
            btnRestartClicked(self)
            btnStartPauseClicked(self)
        }
    }
	
	func updateTimer() {
        self.timeLabel.text = Step.getFormattedTime(self.timeLeft)
	}
    
    func timerDone() {
        // Disable start/pause button
        startPauseButton.enabled = false
        
        // Setup alert controller basics
        self.alertController = UIAlertController(title: "Timer Done!", message: "Timer Done!", preferredStyle: UIAlertControllerStyle.Alert)
        
        // Setup ok action
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            print("Ok Button Pressed")
        })
        
        // Add action to alert controller
        self.alertController!.addAction(okAction)
        
        // Present alert controller
        presentViewController(self.alertController!, animated: true, completion: nil)
        
        // Play sound
        AudioServicesPlaySystemSound(self.systemSoundID)
    }
    
    @IBAction func prevStepButtonAction() {
        if self.synch.paused == false {
            self.synch.stopSpeakingAtBoundary(AVSpeechBoundary.Word)
        }
        self.timer.invalidate()
        self.running = false
        currentIndex -= 1
        updateUI()
    }
    
    @IBAction func nextStepButtonAction() {
        if self.synch.paused == false {
            self.synch.stopSpeakingAtBoundary(AVSpeechBoundary.Word)
        }
        self.timer.invalidate()
        self.running = false
        currentIndex += 1
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tbController = self.tabBarController as! TabBarController
        
        self.title = "Step " + String(self.currentIndex + 1)

        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
		
        self.updateUI()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ingredientCellIdentifier, forIndexPath: indexPath) as! RecipeIngredientTableViewCell
            
        // Customize cell
        
        cell.loadData(self.ingredients[indexPath.row])
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == overviewSegueIdentifier {
            let destination = segue.destinationViewController as! OverviewTableViewController
            destination.setSteps(self.steps)
            destination.main = self
        }
    }
}