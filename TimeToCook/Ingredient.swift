//
//  Ingredient.swift
//  TimeToCook
//
//  Created by Cody Stanfield on 3/21/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import Foundation

class Ingredient {
    private var id:Int = -1
    private var name:String = ""
    private var quantity:Int = 0
    private var partialQuantity:String = "0"
    private var unit:String = "units"
    private var checked:Bool = false
    
    init(name:String, quantity:Int, partialQuantity:String, unit:String, id: Int) {
        self.name = name
        self.quantity = quantity
        self.partialQuantity = partialQuantity
        self.unit = unit
        self.id = id
    }
    
    init(name:String, quantity:Int, partialQuantity:String, unit:String) {
        self.name = name
        self.quantity = quantity
        self.partialQuantity = partialQuantity
        self.unit = unit
    }
    
    init() {}
    
    func getId() -> Int {
        return self.id
    }
    
    func setId(id: Int) {
        self.id = id
    }
    
    func getName() -> String {
        return self.name
    }
    
    func setName(name:String) {
        self.name = name
    }
    
    func getQuantity() -> Int {
        return self.quantity
    }
    
    func setQuantity(quantity:Int) {
        self.quantity = quantity
    }
    
    func getPartialQuantity() -> String {
        return self.partialQuantity
    }
    
    func setPartialQuantity(partialQuantity:String) {
        self.partialQuantity = partialQuantity
    }
    
    func getUnit() -> String {
        return self.unit
    }
    
    func setUnit(unit:String) {
        self.unit = unit
    }
    
    func getChecked() -> Bool {
        return self.checked
    }
    
    func setChecked(checked:Bool) {
        self.checked = checked
    }
    
    func toggleChecked() {
        self.checked = !self.checked
    }
    
    // Merge an ingredient into a list
    static func mergeIngredients(list: [Ingredient], ingredient: Ingredient) -> [Ingredient] {
        var listTwo: [Ingredient] = [Ingredient]()
        listTwo.append(ingredient)
        return mergeIngredients(list, listTwo: listTwo)
    }
    
    // Merge two lists
    static func mergeIngredients(listOne: [Ingredient], listTwo: [Ingredient]) -> [Ingredient] {
        
        if (listTwo.isEmpty) {
            return listOne
        } else if (listOne.isEmpty) {
            return listTwo
        }
        
        var list: [Ingredient] = [Ingredient]()
        
        for i1: Ingredient in listOne {
            var i: Ingredient = i1
            for i2 in listTwo {
                if (i.getName() == i2.getName()) {
                    i = Ingredient.mergeIngredients(i, ingredient2: i2)
                }
            }
            list.append(i)
        }
        
        var merged: Bool = false
        
        for i2: Ingredient in listTwo {
            merged = false
            for i1: Ingredient in listOne {
                if (i2.getName() == i1.getName()) {
                    merged = true
                    break
                }
            }
            if (!merged) {
                list.append(i2)
            }
        }
        
        return list
    }
    
    // Merge two ingredients
    static func mergeIngredients(ingredient1: Ingredient, ingredient2: Ingredient) -> Ingredient {
        
        let ingredients = Ingredient.mergeUnits(ingredient1, ingredient2: ingredient2)
        
        let i1: Ingredient = ingredients.ingredient1
        let i2: Ingredient = ingredients.ingredient2
        
        var quantity: Int = i1.getQuantity()
        quantity += i2.getQuantity()
        let partialSum = mergePartialQuantities(i1.getPartialQuantity(), partial2: i2.getPartialQuantity())
        quantity += partialSum.quantity
        
        return Ingredient(name: i1.getName(), quantity: quantity, partialQuantity: partialSum.partialQuantity, unit: i1.getUnit(), id: i1.getId())
    }
    
    // Merge units
    private static func mergeUnits(ingredient1: Ingredient, ingredient2: Ingredient) -> (ingredient1: Ingredient, ingredient2: Ingredient) {
        
        var i1: Ingredient = ingredient1
        var i2: Ingredient = ingredient2
        
        let u1: String = i1.getUnit()
        let u2: String = i2.getUnit()
        
        // return if units are already equal
        if (u1 == u2) {
            return (ingredient1: i1, ingredient2: i2)
        }
        
        if (u1 == "units" || u2 == "units") {
            i1.setUnit("units")
            i2.setUnit("units")
            return (ingredient1: i1, ingredient2: i2)
        }
        
        if (u1 == "ounces") {
            i2.setUnit("ounces")
            let quant = Ingredient.multiplyQuantity(i2, factor: 16)
            i2.setQuantity(quant.quantity)
            i2.setPartialQuantity(quant.partialQuantity)
            return (ingredient1: i1, ingredient2: i2)
        } else if (u2 == "ounces") {
            i1.setUnit("ounces")
            let quant = Ingredient.multiplyQuantity(i1, factor: 16)
            i1.setQuantity(quant.quantity)
            i1.setPartialQuantity(quant.partialQuantity)
            return (ingredient1: i1, ingredient2: i2)
        }
        
        var u: String = "gallons"
        
        if (u1 == "teaspoons" || u2 == "teaspoons") { u = "teaspoons" }
        else if (u1 == "tablespoons" || u2 == "tablespoons") { u = "tablespoons" }
        else if (u1 == "fluid ounces" || u2 == "fluid ounces") { u = "fluid ounces" }
        else if (u1 == "cups" || u2 == "cups") { u = "cups" }
        else if (u1 == "pints" || u2 == "pints") { u = "pints" }
        else if (u1 == "quarts" || u2 == "quarts") { u = "quarts" }
        
        i1 = Ingredient.convertUnit(i1, unit: u)
        i2 = Ingredient.convertUnit(i2, unit: u)
        
        return (ingredient1: i1, ingredient2: i2)
    }
    
    // Convert units
    private static func convertUnit(ingredient: Ingredient, unit: String) -> Ingredient {
        
        var quants = (quantity: 0, partialQuantity: "0")
        
        while (ingredient.getUnit() != unit) {
            
            if (ingredient.getUnit() == "gallons") {
                ingredient.setUnit("quarts")
                quants = multiplyQuantity(ingredient, factor: 4)
            } else if (ingredient.getUnit() == "quarts") {
                ingredient.setUnit("pints")
                quants = multiplyQuantity(ingredient, factor: 2)
            } else if (ingredient.getUnit() == "pints") {
                ingredient.setUnit("cups")
                quants = multiplyQuantity(ingredient, factor: 2)
            } else if (ingredient.getUnit() == "cups") {
                ingredient.setUnit("fluid ounces")
                quants = multiplyQuantity(ingredient, factor: 8)
            } else if (ingredient.getUnit() == "fluid ounces") {
                ingredient.setUnit("tablespoons")
                quants = multiplyQuantity(ingredient, factor: 2)
            } else if (ingredient.getUnit() == "tablespoons") {
                ingredient.setUnit("teaspoons")
                quants = multiplyQuantity(ingredient, factor: 6)
            }
            
            ingredient.setQuantity(quants.quantity)
            ingredient.setPartialQuantity(quants.partialQuantity)
        }
        
        return ingredient
    }
    
    // Multiply a quantity by a factor
    private static func multiplyQuantity(ingredient: Ingredient, factor: Int) -> (quantity: Int, partialQuantity: String) {
        
        var ret = (quantity: 0, partialQuantity: "0")
        
        var quantity: Int = ingredient.getQuantity()
        quantity *= factor
        
        if (ingredient.getPartialQuantity() != "0") {
            
            let num: Int = Int(ingredient.getPartialQuantity().componentsSeparatedByString("/").first!)!
            let den: Int = Int(ingredient.getPartialQuantity().componentsSeparatedByString("/").last!)!
            
            var twentyFourths: Int = num
            
            switch den {
                case 2: twentyFourths *= 12
                case 3: twentyFourths *= 8
                case 4: twentyFourths *= 6
                case 6: twentyFourths *= 4
                case 8: twentyFourths *= 3
                case 12: twentyFourths *= 2
                
                default: break
            }
            
            twentyFourths *= factor
            quantity += twentyFourths / 24
            twentyFourths = twentyFourths % 24
            
            // Calculate partial quantity string
            switch twentyFourths {
                case 0: ret.partialQuantity = "0"
                case 2: ret.partialQuantity = "1/12"
                case 3: ret.partialQuantity = "1/8"
                case 4: ret.partialQuantity = "1/6"
                case 6: ret.partialQuantity = "1/4"
                case 8: ret.partialQuantity = "1/3"
                case 9: ret.partialQuantity = "3/8"
                case 10: ret.partialQuantity = "5/12"
                case 12: ret.partialQuantity = "1/2"
                case 14: ret.partialQuantity = "7/12"
                case 15: ret.partialQuantity = "5/8"
                case 16: ret.partialQuantity = "2/3"
                case 18: ret.partialQuantity = "3/4"
                case 20: ret.partialQuantity = "5/6"
                case 21: ret.partialQuantity = "7/8"
                case 22: ret.partialQuantity = "11/12"
                
                default: ret.partialQuantity = "\(String(twentyFourths))/24"
            }
        }
        
        ret.quantity = quantity
        
        return ret
    }
    
    // Takes two partials and returns tuple of whole and new partial
    private static func mergePartialQuantities(partial1: String, partial2: String) -> (quantity: Int, partialQuantity: String) {
        
        var ret = (quantity: 0, partialQuantity: "0")
        
        // If either is 0, return the other
        if (partial1 == "0") {
            ret.partialQuantity = partial2
            return ret
        } else if (partial2 == "0") {
            ret.partialQuantity = partial1
            return ret
        }
        
        // Get numerators and denoms
        let num1: Int = Int(partial1.componentsSeparatedByString("/").first!)!
        let num2: Int = Int(partial2.componentsSeparatedByString("/").first!)!
        let den1: Int = Int(partial1.componentsSeparatedByString("/").last!)!
        let den2: Int = Int(partial2.componentsSeparatedByString("/").last!)!
        
        // Get number of twenty-fourths
        let twentyFourths1: Int = num1 * (24 / den1)
        let twentyFourths2: Int = num2 * (24 / den2)
        var twentyFourths: Int = twentyFourths1 + twentyFourths2
        
        // If greater than 24, add 1 to quantity, add 1 and return if equal
        if (twentyFourths >= 24) {
            ret.quantity = 1
            if (twentyFourths == 24) {
                return ret
            } else {
                twentyFourths -= 24
            }
        }
        
        // Calculate partial quantity string
        switch twentyFourths {
            case 2: ret.partialQuantity = "1/12"
            case 3: ret.partialQuantity = "1/8"
            case 4: ret.partialQuantity = "1/6"
            case 6: ret.partialQuantity = "1/4"
            case 8: ret.partialQuantity = "1/3"
            case 9: ret.partialQuantity = "3/8"
            case 10: ret.partialQuantity = "5/12"
            case 12: ret.partialQuantity = "1/2"
            case 14: ret.partialQuantity = "7/12"
            case 15: ret.partialQuantity = "5/8"
            case 16: ret.partialQuantity = "2/3"
            case 18: ret.partialQuantity = "3/4"
            case 20: ret.partialQuantity = "5/6"
            case 21: ret.partialQuantity = "7/8"
            case 22: ret.partialQuantity = "11/12"
            
            default: ret.partialQuantity = "\(String(twentyFourths))/24"
        }
        
        return ret
    }
    
    // List of possible whole quantities
    static func getWholeQuantities() -> [String] {
        
        var quants:[String] = [String]()
        
        for i in 0...60 {
            quants.append(String(i))
        }
        
        return quants
    }
    
    // List of possible partial quantities
    static func getPartialQuantities() -> [String] {
        
        var quants:[String] = [String]()
        
        quants.append("0")
        quants.append("1/24")
        quants.append("1/12")
        quants.append("1/8")
        quants.append("1/6")
        quants.append("5/24")
        quants.append("1/4")
        quants.append("7/24")
        quants.append("1/3")
        quants.append("3/8")
        quants.append("5/12")
        quants.append("11/24")
        quants.append("1/2")
        quants.append("13/24")
        quants.append("7/12")
        quants.append("5/8")
        quants.append("2/3")
        quants.append("17/24")
        quants.append("3/4")
        quants.append("19/24")
        quants.append("5/6")
        quants.append("7/8")
        quants.append("11/12")
        quants.append("23/24")
        
        return quants
    }
    
    // List of possible units
    static func getUnits() -> [String] {
        
        var units:[String] = [String]()
        
        units.append("teaspoons")
        units.append("tablespoons")
        units.append("fluid ounces")
        units.append("cups")
        units.append("pints")
        units.append("quarts")
        units.append("gallons")
        //units.append("milliliters")
        //units.append("liters")
        units.append("ounces")
        units.append("pounds")
        units.append("units")
        //units.append("milligrams")
        //units.append("grams")
        //units.append("kilograms")
        
        return units
    }
}