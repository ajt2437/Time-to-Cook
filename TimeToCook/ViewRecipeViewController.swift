//
//  ViewRecipeViewController.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 3/21/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class ViewRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Data Model
    private var recipe:Recipe!
    private var steps:[Step]! = [Step]()
    private var ingredients:[Ingredient] = [Ingredient]()
    private var recipeName:String!
    private var totalTime:Int!
    private let ingredientCellIdentifier = "ViewRecipeIngredientCell"
    private let stepCellIdentifier = "ViewRecipeStepCell"
    private let cookNowSegueIdentifier = "CookNowSegue"
    var callingController:MyRecipesTableViewController! = nil
    var alertController: UIAlertController? = nil
    var shoppingListQuantity: UITextField? = nil
    
    // Views
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var ingredientsTableView: UITableView!
    @IBOutlet var stepsTableView: UITableView!
    
    // Called when the add to shopping list button is clicked
    @IBAction func btnAddToShoppingListClicked(sender: AnyObject) {
        
        // Setup alert controller basics
        self.alertController = UIAlertController(title: "Add to Shopping List", message: "Enter the quantity", preferredStyle: UIAlertControllerStyle.Alert)
        
        // Setup save and cancel actions
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            if (self.shoppingListQuantity != nil) {
                let tabBarController:TabBarController = self.tabBarController as! TabBarController
                let i:Int? = Int(self.shoppingListQuantity!.text!)
                if (i != nil) {
                    for _ in 1...i! {
                        DBManager.addToShoppingList(tabBarController.email, ingredients: self.ingredients)
                    }
                }
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
            self.shoppingListQuantity = textField
            self.shoppingListQuantity?.placeholder = "Quantity"
            self.shoppingListQuantity?.delegate = self
            self.shoppingListQuantity?.keyboardType = .NumberPad
        }
        
        // Present alert controller
        presentViewController(self.alertController!, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        stepsTableView.delegate = self
        stepsTableView.dataSource = self
        
        self.title = self.recipeName
        self.timeLabel.text = self.recipe.getFormattedTime()
        self.image.contentMode = .ScaleAspectFit
        self.image.image = self.recipe.getImage()
        self.loadIngredients(self.steps)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(ViewRecipeViewController.imageTapped(_:)))
        self.image.userInteractionEnabled = true
        self.image.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func imageTapped(img: AnyObject) {
        performSegueWithIdentifier("ViewImageSegue", sender: nil)
    }
    
    func setNewImage(image:UIImage) {
        self.recipe.setImage(image)
        self.image.image = image
    }
    
    func setName(name:String) {
        self.recipeName = name
    }
    
    func setSteps(steps:[Step]) {
        self.steps = steps
    }
    
    func getRecipe() -> Recipe {
        return self.recipe
    }
    
    func setRecipe(recipe:Recipe) {
        self.recipe = recipe
    }
    
    // Called by CreateRecipeViewController on recipe save after editing
    func saveRecipe(recipe:Recipe) {
        
        self.setName(recipe.getName())
        self.setSteps(recipe.getSteps())
        self.setRecipe(recipe)
        
        self.title = self.recipeName
        self.timeLabel.text = self.recipe.getFormattedTime()
        self.loadIngredients(self.steps)
        self.ingredientsTableView.reloadData()
        self.stepsTableView.reloadData()
    }
    
    func loadIngredients(steps:[Step]) {
        self.ingredients = []
        for step in steps {
            self.ingredients = Ingredient.mergeIngredients(self.ingredients, listTwo: step.getIngredients())
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.ingredientsTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier(ingredientCellIdentifier, forIndexPath: indexPath) as! RecipeIngredientTableViewCell
            
            // Customize cell
            
            cell.loadData(self.ingredients[indexPath.row])
            
            return cell
        }
        else if tableView == self.stepsTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier(stepCellIdentifier, forIndexPath: indexPath) as! RecipeInstructionTableViewCell
            
            // Customize cell
            
            cell.loadData(indexPath.row, step: steps[indexPath.row])

            return cell
        }
            // Should not reach
        else {
            return UITableViewCell()
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.ingredientsTableView {
            return ingredients.count
        }
        else if tableView == self.stepsTableView {
            return steps.count
        }
        // Should not reach
        else {
            return 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // Called when view will disappear
    override func viewWillDisappear(animated: Bool) {
        if (self.callingController.recipesTable.indexPathForSelectedRow != nil) {
            self.callingController.recipesTable.deselectRowAtIndexPath(self.callingController.recipesTable.indexPathForSelectedRow!, animated: false)
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == cookNowSegueIdentifier {
            let destination = segue.destinationViewController as! ViewStepViewController
            destination.setSteps(self.steps)
        } else if segue.identifier == "EditRecipeSegue" {
            let destination = segue.destinationViewController as! CreateRecipeViewController
            destination.callingController = self.callingController
            destination.title = "Edit Recipe"
            destination.viewRecipeController = self
        } else if segue.identifier == "ViewImageSegue" {
            let destination = segue.destinationViewController as! ViewImageViewController
            destination.callingController = self
            destination.recipe = self.recipe
        }
    }
}
