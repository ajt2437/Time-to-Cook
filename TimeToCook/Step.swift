//
//  Step.swift
//  TimeToCook
//
//  Created by Cody Stanfield on 3/21/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import Foundation
import CoreData

class Step {
    private var id:Int = -1
    private var number:Int = 0
    private var directions:String = ""
    private var time:Int = 0
    private var ingredients:[Ingredient] = [Ingredient]()
    
    init(directions:String, time:Int, ingredients:[Ingredient]) {
        self.directions = directions
        self.time = time
        self.ingredients = ingredients
    }
    
    init() {
    }
    
    func getId() -> Int {
        return self.id
    }
    
    func setId(id: Int) {
        self.id = id
    }
    
    func getNumber() -> Int {
        return self.number
    }
    
    func setNumber(number: Int) {
        self.number = number
    }
    
    func getDirections() -> String {
        return self.directions
    }
    
    func setDirections(directions:String) {
        self.directions = directions
    }
    
    func getTime() -> Int {
        return self.time
    }
    
    func getHours() -> Int {
        return self.time / 3600
    }
    
    func getMinutes() -> Int {
        return (self.time % 3600) / 60
    }
    
    func getSeconds() -> Int {
        return self.time % 60
    }
    
    func getFormattedTime() -> String {
        return Step.getFormattedTime(self.time)
    }
    
    // Formats a time as a string
    static func getFormattedTime(time: Int) -> String {
        let hours:Int = time / 3600
        let mins:Int = (time % 3600) / 60
        let secs:Int = time % 60
        
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
    
    func setTime(time:Int) {
        self.time = time
    }
    
    func getIngredients() -> [Ingredient] {
        return self.ingredients
    }
    
    func setIngredients(ingredients:[Ingredient]) {
        self.ingredients = ingredients
    }
    
    func addIngredient(ingredient: Ingredient) {
        self.ingredients = Ingredient.mergeIngredients(self.ingredients, ingredient: ingredient)
    }
}