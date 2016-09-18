//
//  CreateRecipeViewController.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 3/21/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class CreateRecipeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var callingController: MyRecipesTableViewController! = nil
    var viewRecipeController: ViewRecipeViewController! = nil
    var ingredients:[Ingredient] = [Ingredient]()
    var steps:[Step] = [Step]()
    var timeInSeconds:Int = 0
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var type: UITextField!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var ingredientsTable: UITableView!
    @IBOutlet weak var stepsTable: UITableView!
    
    // Executes when save button is clicked
    // TODO: Validate that there is a name and at least one step
    // TODO: Point to recipe detail page, not My Recipes
    @IBAction func btnSaveClicked(sender: AnyObject) {
        
        var nameText:String = "Recipe"
        if (name.text != nil && !name.text!.isEmpty) {
            nameText = name.text!
        }
        
        var typeText:String = "Other"
        if (type.text != nil && !type.text!.isEmpty) {
            typeText = type.text!
        }
        
        var r:Recipe! = nil
        
        if (self.viewRecipeController == nil) {
            r = Recipe()
        } else {
            r = viewRecipeController.getRecipe()
        }
        
        r.setName(nameText)
        r.setType(typeText)
        r.setSteps(self.steps)
        r.initializeTime()
        
        DBManager.saveRecipe(r, email: callingController.email)
        callingController.recipes = DBManager.loadRecipes(callingController.email)
        callingController.recipesTable.reloadData()
        
        let tabBarController: TabBarController = self.tabBarController as! TabBarController
        tabBarController.allIngredients = DBManager.loadIngredients()
        
        if (self.viewRecipeController == nil) {
            self.navigationController!.popToViewController(callingController, animated: true)
        } else {
            self.viewRecipeController.saveRecipe(r)
            self.navigationController!.popToViewController(viewRecipeController, animated: true)
        }
    }
    
    // Executes when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.name.delegate = self
        self.type.delegate = self
        
        self.tabBarController?.tabBar.hidden = true // Hide tab bar on this view
        
        // Set dataSource and delegate of table views to self
        self.ingredientsTable.dataSource = self
        self.ingredientsTable.delegate = self
        self.stepsTable.dataSource = self
        self.stepsTable.delegate = self
        
        self.time.text = "00:00:00"
        
        if (viewRecipeController != nil) {
            let r:Recipe = viewRecipeController.getRecipe()
            self.name.text = r.getName()
            self.type.text = r.getType()
            self.timeInSeconds = r.getTime()
            self.time.text = r.getFormattedTime()
            self.steps = r.getSteps()
            self.getIngredients()
        }
    }
    
    // Called when view appears
    override func viewWillAppear(animated: Bool) {
        if (self.stepsTable.indexPathForSelectedRow != nil) {
            self.stepsTable.deselectRowAtIndexPath(self.stepsTable.indexPathForSelectedRow!, animated: false)
        }
    }
    
    // Iterates over steps and merges ingredients into single list
    func getIngredients() {
        for step:Step in self.steps {
            self.ingredients = Ingredient.mergeIngredients(self.ingredients, listTwo: step.getIngredients())
        }
    }
	
	func updateIngredients() {
		self.ingredients = [Ingredient]()
		self.getIngredients()
	}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Number of rows in table views
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Ingredients
        if (tableView == self.ingredientsTable) {
            return ingredients.count
            
        // Steps
        } else {
            return steps.count
        }
    }
    
    // Cell construction
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row:Int = indexPath.row
        
        // Ingredients
        if (tableView == self.ingredientsTable) {
            let cell:RecipeIngredientTableViewCell = tableView.dequeueReusableCellWithIdentifier("CreateRecipeIngredientCell", forIndexPath: indexPath) as! RecipeIngredientTableViewCell
            cell.loadData(ingredients[row])
            return cell
            
        // Steps
        } else {
            let cell:RecipeInstructionTableViewCell = tableView.dequeueReusableCellWithIdentifier("CreateRecipeStepCell", forIndexPath: indexPath) as! RecipeInstructionTableViewCell
            cell.loadData(row, step: steps[row])
            return cell
        }
    }
    
    // Adds a step to this recipe
    // Called from AddStepViewController
    func addStep(time:Int, ingredients:[Ingredient], directions:String) {
        self.steps.append(Step(directions: directions, time: time, ingredients: ingredients))
        self.timeInSeconds += time
        self.time.text = getFormattedTime()
        self.ingredients = Ingredient.mergeIngredients(self.ingredients, listTwo: ingredients)
        self.ingredientsTable.reloadData()
        self.stepsTable.reloadData()
    }
    
    // Edits a step on this recipe
    // Called from AddStepViewController
    func saveStep(time:Int, ingredients:[Ingredient], directions:String) {
        
        let index:Int = (self.stepsTable.indexPathForSelectedRow?.row)!
        
        self.steps[index].setTime(time)
        self.steps[index].setIngredients(ingredients)
        self.steps[index].setDirections(directions)
		// Delete current ingredient list and merge everything again, still not working
		//self.updateIngredients()
        self.ingredientsTable.reloadData()
    }
    
    func getFormattedTime() -> String {
        let hours:Int = self.timeInSeconds / 3600
        let mins:Int = (self.timeInSeconds % 3600) / 60
        let secs:Int = self.timeInSeconds % 60
        
        var str:String = ""
        
        if (hours < 10) {
            str += "0"
        }
        str += "\(String(hours)):"
        
        if (mins < 10) {
            str += "0"
        }
        str += "\(String(mins)):"
        
        if (secs < 10) {
            str += "0"
        }
        str += "\(String(secs))"
        
        return str
    }
	
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if tableView == self.stepsTable {
			return true
		}
		return false
	}
	
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		
		// Delete step from recipe
		if tableView == self.stepsTable && editingStyle == UITableViewCellEditingStyle.Delete
		{
            DBManager.deleteStep(self.steps[indexPath.row], email: callingController.email)
			self.steps.removeAtIndex(indexPath.row)
			self.stepsTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.ingredients = []
			self.getIngredients();
			self.ingredientsTable.reloadData()
		}
	}
    
    // MARK: - Navigation
    
    // Called when view is going to disappear
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false // Show tab bar
    }
    
    // Send reference to this class to new class
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Send reference to this class to AddStepViewController
        if (segue.identifier == "AddStepSegue") {
            let dvc = segue.destinationViewController as! AddStepViewController
            dvc.callingController = self
        }
        
        if (segue.identifier == "EditStepSegue") {
            let index:Int = (self.stepsTable.indexPathForSelectedRow?.row)!
            let dvc = segue.destinationViewController as! AddStepViewController
            dvc.callingController = self
            dvc.title = "Edit Step \(String(index + 1))"
            dvc.step = self.steps[index]
        }
    }
}
