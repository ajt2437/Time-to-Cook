//
//  SortByViewController.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 4/26/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class SortByViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var callingController: MyRecipesTableViewController! = nil
    
    @IBOutlet weak var sortByTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sortByTable.dataSource = self
        self.sortByTable.delegate = self
        
        self.title = "Sort Cookbook"
        
        self.tabBarController?.tabBar.hidden = true // Hide tab bar on this view
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Called when view is going to disappear
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false // Show tab bar
    }
    
    // MARK: - Table view data source
    
    // Number of rows in table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    // Table view cell population
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SortByCell", forIndexPath: indexPath)
        if (row == 0) {
            cell.textLabel!.text = "Sort by Name"
        } else if (row == 1) {
            cell.textLabel!.text = "Sort by Type"
        }
        
        return cell
    }
    
    // Called when user selects an option
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let row = indexPath.row
        
        if (row == 0) {
            self.callingController.sortByName()
        } else if (row == 1) {
            self.callingController.sortByType()
        }
        
        self.navigationController!.popToViewController(callingController, animated: true)
    }
}