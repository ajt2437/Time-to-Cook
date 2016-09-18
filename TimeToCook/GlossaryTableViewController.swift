//
//  GlossaryTableViewController.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 4/26/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class GlossaryTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var terms:[Term] = [Term]()
    
    @IBOutlet weak var glossaryTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.glossaryTable.dataSource = self
        self.glossaryTable.delegate = self
        
        self.terms = Term.getTermList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    // Number of rows in table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return terms.count
    }
    
    // Table view cell population
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        let cell = tableView.dequeueReusableCellWithIdentifier("GlossaryCell", forIndexPath: indexPath)
        cell.textLabel!.text = self.terms[row].getName()
        return cell
    }
    
    // MARK: - Navigation
    
    // Send reference for this class to new class
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "ViewTermSegue") {
            let index:Int = (self.glossaryTable.indexPathForSelectedRow?.row)!
            let dvc = segue.destinationViewController as! ViewTermViewController
            dvc.term = self.terms[index]
            dvc.callingController = self
        }
    }
}