//
//  ShoppingListViewController.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 4/3/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class ShoppingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var shoppingListTable: UITableView!
    @IBOutlet weak var tabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shoppingListTable.dataSource = self
        self.shoppingListTable.delegate = self
    }
    
    // Toggle checked value for ingredient in tab bar controller
    func toggleChecked(index:Int) {
        (self.tabBarController as! TabBarController).shoppingList[index].toggleChecked()
        (self.tabBarController as! TabBarController).orderShoppingList()
        self.shoppingListTable.reloadData()
    }
    
    func setChecked(index:Int, checked:Bool) {
        (self.tabBarController as! TabBarController).shoppingList[index].setChecked(checked)
        (self.tabBarController as! TabBarController).orderShoppingList()
        self.shoppingListTable.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.tabBarController as! TabBarController).shoppingList.count
    }
    
    // Table view cell population
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ShoppingListIngredientCell", forIndexPath: indexPath) as! RecipeIngredientTableViewCell
        cell.loadData((self.tabBarController as! TabBarController).shoppingList[row])
        cell.shoppingListController = self
        cell.shoppingListIndex = row
        
        return cell
    }
    
    // Called when a row is selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tbController = self.tabBarController as! TabBarController

        if tbController.shoppingList[indexPath.row].getChecked() {
            DBManager.setCheckInShoppingList(tbController.email, ingredient: tbController.shoppingList[indexPath.row], checked: false)
        }
        else {
            DBManager.setCheckInShoppingList(tbController.email, ingredient: tbController.shoppingList[indexPath.row], checked: true)
        }
        
        self.shoppingListTable.deselectRowAtIndexPath(indexPath, animated: false)
        
        let cell:RecipeIngredientTableViewCell = self.shoppingListTable.cellForRowAtIndexPath(indexPath) as! RecipeIngredientTableViewCell
        cell.toggleCheckImage()
    }
	
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == UITableViewCellEditingStyle.Delete
		{
            let tbController = self.tabBarController as! TabBarController
            DBManager.removeFromShoppingList(tbController.email, ingredient: tbController.shoppingList[indexPath.row])
            
			tbController.shoppingList.removeAtIndex(indexPath.row)
			self.shoppingListTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
		}
	}
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false // Show tab bar
        
        // Reload data
        (self.tabBarController as! TabBarController).shoppingList = DBManager.loadShoppingList((self.tabBarController as! TabBarController).email)
        (self.tabBarController as! TabBarController).orderShoppingList()
        self.shoppingListTable.reloadData()
    }
    
    // Send reference to this class to new class
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Send reference to this class to SelectIngredientTableViewController
        if (segue.identifier == "AddIngredientFromShoppingListSegue") {
            let dvc = segue.destinationViewController as! SelectIngredientTableViewController
            dvc.shoppingListController = self
        }
        
        // Edit ingredient here
        /*if (segue.identifier == "EditIngredientSegue") {
            let index:Int = (self.ingredientsTable.indexPathForSelectedRow?.row)!
            let dvc = segue.destinationViewController as! SelectIngredientTableViewController
            dvc.addStepController = self
            dvc.title = "Edit Ingredient"
            dvc.ingredient = self.ingredients[index]
        }*/
    }
}