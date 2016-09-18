//
//  RecipeIngredientTableViewCell.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 3/21/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class RecipeIngredientTableViewCell: UITableViewCell {
    
    var shoppingListController:ShoppingListViewController! = nil
    var shoppingListIndex:Int = 0
    
    @IBOutlet weak var unit: UILabel! = UILabel()
    @IBOutlet weak var quantity: UILabel! = UILabel()
    @IBOutlet weak var ingredient: UILabel! = UILabel()
    @IBOutlet weak var uncheckedButton: UIButton!
    @IBOutlet weak var checkedButton: UIButton!
    
    @IBAction func uncheckedButtonClicked(sender: AnyObject) {
        self.toggleCheckImage()
    }
    @IBAction func checkedButtonClicked(sender: AnyObject) {
        self.toggleCheckImage()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Function to load data for ingredient into @IBOutlets
    func loadData(ingredient:Ingredient) {
        
        let quant:Int = ingredient.getQuantity()
        let partialQuant:String = ingredient.getPartialQuantity()
        var quantString:String = ""
        if (quant == 0 && partialQuant == "0") {
            quantString = "0"
        } else if (quant != 0 && partialQuant == "0") {
            quantString = String(quant)
        } else if (quant == 0 && partialQuant != "0") {
            quantString = partialQuant
        } else {
            quantString = "\(String(quant)) \(partialQuant)"
        }
        
        self.ingredient.text = ingredient.getName()
        self.quantity.text = quantString
        self.unit.text = ingredient.getUnit()
        
        if (self.uncheckedButton != nil && self.checkedButton != nil) {
            
            if (!ingredient.getChecked()) {
                self.uncheckedButton.hidden = false
                self.checkedButton.hidden = true
            } else {
                self.uncheckedButton.hidden = true
                self.checkedButton.hidden = false
            }
        }
    }
    
    // Function to toggle checked button
    func toggleCheckImage() {
        self.shoppingListController.toggleChecked(self.shoppingListIndex)
        self.uncheckedButton.hidden = !self.uncheckedButton.hidden
        self.checkedButton.hidden = !self.checkedButton.hidden
    }
    
    func setCheckImage(checked: Bool) {
        if checked {
            self.uncheckedButton.hidden = true
            self.checkedButton.hidden = false
            self.shoppingListController.setChecked(self.shoppingListIndex, checked: true)
        }
        else {
            self.uncheckedButton.hidden = false
            self.checkedButton.hidden = true
            self.shoppingListController.setChecked(self.shoppingListIndex, checked: false)
        }
    }
}
