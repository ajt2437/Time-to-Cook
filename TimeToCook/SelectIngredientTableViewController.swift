//
//  SelectIngredientTableViewController.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 3/21/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class SelectIngredientTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var addIngredientLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var addStepController: AddStepViewController! = nil
    var shoppingListController: ShoppingListViewController! = nil
    var alertController: UIAlertController? = nil
    var newIngredientText: UITextField? = nil
    var allIngredients:[Ingredient] = [Ingredient]()
    var allIngredientsSet:Set<String> = Set<String>()
    var wholeQuantities:[String] = Ingredient.getWholeQuantities()
    let partialQuantities:[String] = Ingredient.getPartialQuantities()
    let units:[String] = Ingredient.getUnits()
    var ingredient:Ingredient! = nil
    
    // Called when add button is clicked
    @IBAction func btnAddClicked(sender: AnyObject) {
        
        // Setup alert controller basics
        self.alertController = UIAlertController(title: "New Ingredient", message: "Enter the name of the new ingredient", preferredStyle: UIAlertControllerStyle.Alert)
        
        // Setup save and cancel actions
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            if (self.newIngredientText!.text != nil && !self.newIngredientText!.text!.isEmpty && !self.allIngredientsSet.contains(self.newIngredientText!.text!.lowercaseString)) {
                let i:Ingredient = Ingredient(name: self.newIngredientText!.text!, quantity: 0, partialQuantity: "0", unit: "units")
                self.allIngredients.append(i)
                (self.tabBarController as! TabBarController).allIngredients.append(i)
                self.allIngredientsSet.insert(i.getName().lowercaseString)
                self.table.reloadData()
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            print("Cancel Button Pressed")
        }
        
        // Add actions to alert controller
        self.alertController!.addAction(saveAction)
        self.alertController!.addAction(cancelAction)
        
        // Add text field to alert controller
        self.alertController!.addTextFieldWithConfigurationHandler { (textField) -> Void in
            self.newIngredientText = textField
            self.newIngredientText?.placeholder = "Ingredient"
        }
        
        // Present alert controller
        presentViewController(self.alertController!, animated: true, completion: nil)
    }
    
    // Called when cancel button is clicked
    @IBAction func btnCancelClicked(sender: AnyObject) {
        if (self.ingredient != nil) {
            self.table.deselectRowAtIndexPath(self.table.indexPathForSelectedRow!, animated: false)
            self.showTable()
        }
    }
    
    // Called when save button is clicked
    @IBAction func btnSaveClicked(sender: AnyObject) {
        
        let quantity:Int = picker.selectedRowInComponent(0)
        let partialQuantity:String = partialQuantities[picker.selectedRowInComponent(1)]
        let unit:String = units[picker.selectedRowInComponent(2)]
        
        if (self.addStepController != nil) {
            if (self.ingredient == nil) {
                self.addStepController.addIngredient(self.allIngredients[table.indexPathForSelectedRow!.row].getName(), quantity: quantity, partialQuantity: partialQuantity, unit: unit, id: self.allIngredients[table.indexPathForSelectedRow!.row].getId())
            } else {
                self.addStepController.saveIngredient(quantity, partialQuantity: partialQuantity, unit: unit)
            }
            
            self.navigationController!.popToViewController(self.addStepController, animated: true)
            
        } else if (self.shoppingListController != nil) {
            
            // Add ingredient to shopping list
            let tabBarController:TabBarController = self.tabBarController as! TabBarController
            var arr = [Ingredient]()
            arr.append(Ingredient(name: self.allIngredients[table.indexPathForSelectedRow!.row].getName(), quantity: quantity, partialQuantity: partialQuantity, unit: unit, id: self.allIngredients[table.indexPathForSelectedRow!.row].getId()))
            DBManager.addToShoppingList(tabBarController.email, ingredients: arr)
            
            
            self.navigationController!.popToViewController(self.shoppingListController, animated: true)
        }
    }
    
    // Executes when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get list of ingredients already in database
        let tabBarController: TabBarController = self.tabBarController as! TabBarController
        self.allIngredients = tabBarController.allIngredients
        for ingredient:Ingredient in self.allIngredients {
            self.allIngredientsSet.insert(ingredient.getName().lowercaseString)
        }
        
        self.tabBarController?.tabBar.hidden = true // Hide tab bar on this view
        
        self.table.dataSource = self
        self.table.delegate = self
        self.picker.dataSource = self
        self.picker.delegate = self
        
        if (self.ingredient != nil) {
            self.hideTable()
            self.importIngredient()
        } else {
            self.showTable()
        }
    }
    
    // Shows table, hides picker
    func showTable() {
        self.addIngredientLabel.hidden = true
        self.cancelButton.hidden = true
        self.saveButton.hidden = true
        self.picker.hidden = true
        self.addButton.enabled = true
        self.table.hidden = false
    }
    
    // Hides table, shows picker
    func hideTable() {
        self.addIngredientLabel.hidden = false
        self.cancelButton.hidden = false
        self.saveButton.hidden = false
        self.picker.hidden = false
        self.addButton.enabled = false
        self.table.hidden = true
    }
    
    // Import an ingredient into this view
    func importIngredient() {
        
        // Modify label
        self.addIngredientLabel.text = "Edit \(self.ingredient.getName())"
        
        // If whole quantity is bigger than default, expand list
        if (self.ingredient.getQuantity() >= self.wholeQuantities.count) {
            let existing:Int = self.wholeQuantities.count - 1
            let toAdd:Int = self.ingredient.getQuantity() - self.wholeQuantities.count + 1
            for i:Int in 1...toAdd {
                self.wholeQuantities.append(String(existing + i))
            }
            self.picker.reloadComponent(0)
        }
        
        // Select appropriate whole quantity
        self.picker.selectRow(self.ingredient.getQuantity(), inComponent: 0, animated: false)
        
        // Select appropriate partial quantity
        for i:Int in 0...self.partialQuantities.count - 1 {
            if (self.ingredient.getPartialQuantity() == self.partialQuantities[i]) {
                self.picker.selectRow(i, inComponent: 1, animated: false)
                break
            }
        }
        
        // Select appropriate unit
        for i:Int in 0...self.units.count - 1 {
            if (self.ingredient.getUnit() == self.units[i]) {
                self.picker.selectRow(i, inComponent: 2, animated: false)
                break
            }
        }
    }
    
    // MARK: Table view
    
    // Number of rows in table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allIngredients.count
    }
    
    // Table view cell setup
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row:Int = indexPath.row
        
        let cell = tableView.dequeueReusableCellWithIdentifier("IngredientCell", forIndexPath: indexPath)
        cell.textLabel!.text = self.allIngredients[row].getName()
        return cell
    }
    
    // Called when row in table view is selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let row:Int = indexPath.row
        
        self.picker.selectRow(1, inComponent: 0, animated: false)
        self.picker.selectRow(3, inComponent: 2, animated: false)
        
        self.addIngredientLabel.text = "Add \(self.allIngredients[row].getName())"
        
        self.hideTable()
    }
    
    // MARK: Picker
    
    // Number of components in picker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    // Number of elements of each component in picker
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return wholeQuantities.count
        } else if (component == 1) {
            return partialQuantities.count
        } else {
            return units.count
        }
    }
    
    // Populate each element of picker
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) {
            return wholeQuantities[row]
        } else if (component == 1) {
            return partialQuantities[row]
        } else {
            return units[row]
        }
    }
}