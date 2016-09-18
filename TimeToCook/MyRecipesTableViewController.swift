//
//  MyRecipesTableViewController.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 3/21/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class MyRecipesTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var recipes:[Recipe] = [Recipe]()
    var email: String = ""
    
    @IBOutlet weak var recipesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.email = (self.tabBarController as! TabBarController).email
        
        self.recipesTable.dataSource = self
        self.recipesTable.delegate = self
        
        self.recipes = DBManager.loadRecipes(self.email)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Sorts recipes by name
    func sortByName() {
        self.recipes.sortInPlace {
            $0.getName().localizedCaseInsensitiveCompare($1.getName()) == NSComparisonResult.OrderedAscending
        }
        self.recipesTable.reloadData()
    }
    
    // Sorts recipes by type
    func sortByType() {
        self.recipes.sortInPlace {
            $0.getType().localizedCaseInsensitiveCompare($1.getType()) == NSComparisonResult.OrderedAscending
        }
        self.recipesTable.reloadData()
    }

    // MARK: - Table view data source
    
    // Number of rows in table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    // Table view cell population
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        let cell = tableView.dequeueReusableCellWithIdentifier("RecipeCell", forIndexPath: indexPath)
        cell.textLabel!.text = self.recipes[row].getName()
        cell.detailTextLabel!.text = self.recipes[row].getType()
        return cell
    }
	
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		
		// Delete recipe from recipe list
		if editingStyle == UITableViewCellEditingStyle.Delete
		{
            DBManager.deleteRecipe(email, recipe: self.recipes[indexPath.row])
			self.recipes.removeAtIndex(indexPath.row)
			self.recipesTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
			// TODO: update in data in database
		}
	}
    
    // MARK: - Navigation
    
    // Send reference for this class to new class
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Pass reference for this class to CreateRecipeViewController
        if (segue.identifier == "CreateRecipeSegue") {
            let dvc = segue.destinationViewController as! CreateRecipeViewController
            dvc.callingController = self
        }
        
        if (segue.identifier == "ViewRecipeSegue") {
            
            let index = self.recipesTable.indexPathForSelectedRow?.row
            let dvc = segue.destinationViewController as! ViewRecipeViewController
            dvc.callingController = self
            dvc.setSteps(self.recipes[index!].getSteps())
            dvc.setName(self.recipes[index!].getName())
            dvc.setRecipe(self.recipes[index!])
        }
        
        if (segue.identifier == "SortBySegue") {
            let dvc = segue.destinationViewController as! SortByViewController
            dvc.callingController = self
        }
    }
}