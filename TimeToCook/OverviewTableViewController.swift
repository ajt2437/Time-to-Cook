//
//  OverviewTableViewController.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 3/21/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class OverviewTableViewController: UITableViewController {
    
    // Data Model
    private var steps:[Step]!
    //private var ingredients:[Ingredient] = [Ingredient]()
    var main:ViewStepViewController!
    
    // View
    private let overviewStepCellIdentifier = "OverviewStepCell"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setSteps(steps:[Step]) {
        self.steps = steps
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.steps.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(overviewStepCellIdentifier, forIndexPath: indexPath) as! RecipeInstructionTableViewCell

        // Configure the cell...
        cell.loadData(indexPath.row, step: self.steps[indexPath.row])

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        main.setCurrentIndex(indexPath.row)
        self.navigationController?.popToViewController(self.main, animated: true)
    }
}