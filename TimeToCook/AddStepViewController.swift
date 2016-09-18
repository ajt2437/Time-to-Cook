//
//  AddStepViewController.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 3/21/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class AddStepViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    var callingController: CreateRecipeViewController! = nil
    var ingredients:[Ingredient] = [Ingredient]()
    var step:Step! = nil
    
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var ingredientsTable: UITableView!
    @IBOutlet weak var directions: UITextView!
    
    // Called when save button is clicked
    @IBAction func btnSaveClicked(sender: AnyObject) {
        
        // Calculate amount of seconds
        let hours = timePicker.selectedRowInComponent(0)
        let minutes = timePicker.selectedRowInComponent(1)
        let seconds = timePicker.selectedRowInComponent(2)
        let total = (hours * 3600) + (minutes * 60) + seconds
        
        // Save step to create recipe controller
        if (self.step == nil) {
            callingController.addStep(total, ingredients: self.ingredients, directions: directions.text)
        } else {
            callingController.saveStep(total, ingredients: self.ingredients, directions: directions.text)
        }
        
        // Display create recipe view
        self.navigationController!.popToViewController(self.callingController, animated: true)
    }
    
    // Executes when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.directions.delegate = self
        
        self.tabBarController?.tabBar.hidden = true // Hide tab bar on this view
        
        // Set dataSource and delagate of picker and table view to self
        self.timePicker.dataSource = self
        self.timePicker.delegate = self
        self.ingredientsTable.dataSource = self
        self.ingredientsTable.delegate = self
        
        if (self.step != nil) {
            self.importStep()
        }
    }
    
    // Called when view appears
    override func viewWillAppear(animated: Bool) {
        if (self.ingredientsTable.indexPathForSelectedRow != nil) {
            self.ingredientsTable.deselectRowAtIndexPath(self.ingredientsTable.indexPathForSelectedRow!, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewShouldReturn(textField: UITextField) -> Bool {
        self.directions.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func importStep() {
        self.ingredients = self.step.getIngredients()
        self.directions.text = self.step.getDirections()
        self.timePicker.selectRow(self.step.getHours(), inComponent: 0, animated: false)
        self.timePicker.selectRow(self.step.getMinutes(), inComponent: 1, animated: false)
        self.timePicker.selectRow(self.step.getSeconds(), inComponent: 2, animated: false)
    }
    
    // MARK: Begin time picker
    
    // Number of components in time picker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    // Number of elements of each component in time picker
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return 49
        } else {
            return 60
        }
    }
    
    // Populate each element of time picker
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) {
            return "\(String(row)) hours"
        } else if (component == 1) {
            return "\(String(row)) minutes"
        } else {
            return "\(String(row)) seconds"
        }
    }
    
    // MARK: Begin table view
    
    // Number of rows in ingredient table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ingredients.count
    }
    
    // Cell construction for ingredient table view
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row:Int = indexPath.row
        
        let cell:RecipeIngredientTableViewCell = tableView.dequeueReusableCellWithIdentifier("AddStepIngredientCell", forIndexPath: indexPath) as! RecipeIngredientTableViewCell
        cell.loadData(self.ingredients[row])
        return cell
    }
    
    // Function to add a new ingredient to the step
    func addIngredient(name:String, quantity:Int, partialQuantity:String, unit:String, id:Int) {
        self.ingredients = Ingredient.mergeIngredients(self.ingredients, ingredient: (Ingredient(name: name, quantity: quantity, partialQuantity: partialQuantity, unit: unit, id: id)))
        ingredientsTable.reloadData()
    }
    
    // Function to save an edited ingredient
    func saveIngredient(quantity:Int, partialQuantity:String, unit:String) {
        
        let index:Int = (self.ingredientsTable.indexPathForSelectedRow?.row)!
        
        self.ingredients[index].setQuantity(quantity)
        self.ingredients[index].setPartialQuantity(partialQuantity)
        self.ingredients[index].setUnit(unit)
        self.ingredientsTable.reloadData()
    }
	
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if tableView == self.ingredientsTable {
			return true
		}
		return false
	}
	
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		
		// Delete ingredient from step
		if tableView == self.ingredientsTable && editingStyle == UITableViewCellEditingStyle.Delete {
            DBManager.deleteIngredientInStep(self.ingredients[indexPath.row], step: self.step, email: callingController.callingController.email)
			self.ingredients.removeAtIndex(indexPath.row)
			self.ingredientsTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
		}
	}

    // MARK: - Navigation
    
    // Send reference to this class to new class
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Send reference to this class to SelectIngredientTableViewController
        if (segue.identifier == "AddIngredientSegue") {
            let dvc = segue.destinationViewController as! SelectIngredientTableViewController
            dvc.addStepController = self
        }
        
        if (segue.identifier == "EditIngredientSegue") {
            let index:Int = (self.ingredientsTable.indexPathForSelectedRow?.row)!
            let dvc = segue.destinationViewController as! SelectIngredientTableViewController
            dvc.addStepController = self
            dvc.title = "Edit Ingredient"
            dvc.ingredient = self.ingredients[index]
        }
    }
}
