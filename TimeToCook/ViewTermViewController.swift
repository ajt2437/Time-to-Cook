//
//  ViewTermViewController.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 4/26/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class ViewTermViewController: UIViewController {
    
    var term:Term!
    var callingController:GlossaryTableViewController! = nil
    
    @IBOutlet weak var definitionTextView: UITextView!
    
    // Executes when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.term.getName()
        self.definitionTextView.text = self.term.getDefinition()
    }
    
    // Called when view will disappear
    override func viewWillDisappear(animated: Bool) {
        if (self.callingController.glossaryTable.indexPathForSelectedRow != nil) {
            self.callingController.glossaryTable.deselectRowAtIndexPath(self.callingController.glossaryTable.indexPathForSelectedRow!, animated: false)
        }
    }
}