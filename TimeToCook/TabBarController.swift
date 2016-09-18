//
//  TabBarController.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 4/6/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var allIngredients: [Ingredient] = DBManager.loadIngredients()
    var shoppingList: [Ingredient] = [Ingredient]()
    var email: String = ""
    var settings: Settings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.settings = DBManager.loadSettings(self.email)
        shoppingList = DBManager.loadShoppingList(email)
        // Load allIngredients here
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Function to add a new ingredient to shopping list
    func addToShoppingList(name:String, quantity:Int, partialQuantity:String, unit:String, id:Int) {
        self.shoppingList = Ingredient.mergeIngredients(self.shoppingList, ingredient: (Ingredient(name: name, quantity: quantity, partialQuantity: partialQuantity, unit: unit, id: id)))
        self.orderShoppingList()
    }
    
    func addToShoppingList(ingredients: [Ingredient]) {
        self.shoppingList = Ingredient.mergeIngredients(self.shoppingList, listTwo: ingredients)
        self.orderShoppingList()
    }
    
    func orderShoppingList() {
        self.shoppingList.sortInPlace {
            !$0.getChecked() && $1.getChecked()
        }
    }
}