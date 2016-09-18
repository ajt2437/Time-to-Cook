//
//  DBManager.swift
//  TimeToCook
//
//  Created by Cody Stanfield on 4/4/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import Foundation

class DBManager {
    // Sends the signup request to the server
    static func signup(email: String, password: String) -> Bool {
        if let URL = NSURL(string: "http://159.203.75.63:5000/signup") {
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            let request = NSMutableURLRequest(URL: URL)
            request.HTTPMethod = "POST"
            request.addValue(email, forHTTPHeaderField: "email")
            request.addValue(password, forHTTPHeaderField: "password")
            var success:Bool? = nil
            
            let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if (error == nil) {
                    // Success
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    
                    if statusCode == 200 {
                        data?.writeToFile(self.getDatabasePath(), atomically: true)
                        success = true
                    }
                    else {
                        success = false
                    }
                }
                else {
                    // Failure
                    print("Failure: %@", error!.localizedDescription);
                }
            })
            task.resume()
            
            while success == nil {
                // Spin! Yay!
                // I know this is bad... Trust me. I know
            }
            
            return success!
        }
        
        return false
    }
    
    // Sends the login request to the server
    static func login(email: String, password: String) -> Bool {
        if let URL = NSURL(string: "http://159.203.75.63:5000/login") {
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            let request = NSMutableURLRequest(URL: URL)
            request.HTTPMethod = "POST"
            request.addValue(email, forHTTPHeaderField: "email")
            request.addValue(password, forHTTPHeaderField: "password")
            var success:Bool? = nil
            
            let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if (error == nil) {
                    // Success
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    
                    if statusCode == 200 {
                        data?.writeToFile(self.getDatabasePath(), atomically: true)
                        success = true
                    }
                    else {
                        success = false
                    }
                }
                else {
                    // Failure
                    print("Failure: %@", error!.localizedDescription);
                }
            })
            task.resume()
            
            while success == nil {
                // Spin! Yay!
                // I know this is bad... Trust me. I know
            }
            
            return success!
        }
        
        return false
    }
    
    // Gets the path of the database directory
    static func getDatabasePath() -> String {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let ttcDir = dirPaths[0]
        let databasePath = ttcDir + "/ttc.db"
        
        return databasePath
    }
    
    // Loads recipes from database into objects
    static func loadRecipes(email:String) -> [Recipe] {
        // Setup
        var recipes:[Recipe] = [Recipe]()
        let db = getDBConnection()
        
        // Build recipes
        if db.open() {
            // Get recipe list
            let usersRecipes = db.executeQuery("SELECT recipe_id FROM user_recipe WHERE user_id = \(self.getUserID(email))", withArgumentsInArray: nil)
            
            while usersRecipes.next() {
                let recipeResult = db.executeQuery("SELECT id, name, type FROM recipe WHERE id = \(usersRecipes.intForColumn("recipe_id"))", withArgumentsInArray: nil)
                
                // Loop through each recipe row
                while recipeResult.next() {
                    let recipe = Recipe()
                    recipe.setId(Int(recipeResult.intForColumn("id")))
                    recipe.setName(recipeResult.stringForColumn("name"))
                    recipe.setType(recipeResult.stringForColumn("type"))
                    
                    // Get the steps
                    let stepResult = db.executeQuery("SELECT id, directions, number, seconds FROM step WHERE recipe_id = \(recipeResult.intForColumn("id"))", withArgumentsInArray: nil)
                    
                    //Loop through each step row
                    while stepResult.next() {
                        let step = Step()
                        step.setId(Int(stepResult.intForColumn("id")))
                        step.setDirections(stepResult.stringForColumn("directions"))
                        step.setTime(Int(stepResult.intForColumn("seconds")))
                        step.setNumber(Int(stepResult.intForColumn("number")))
                        
                        // Get the step_ingredients
                        let stepIngredientResult = db.executeQuery("SELECT id, step_id, ingredient_id, quantity, partial_quantity, unit FROM step_ingredient WHERE step_id = \(stepResult.intForColumn("id"))", withArgumentsInArray: nil)
                        
                        // Loop through each step_ingredient
                        while stepIngredientResult.next() {
                            let ingredient = Ingredient()
                            ingredient.setQuantity(Int(stepIngredientResult.intForColumn("quantity")))
                            ingredient.setPartialQuantity(stepIngredientResult.stringForColumn("partial_quantity"))
                            ingredient.setUnit(stepIngredientResult.stringForColumn("unit"))
                            
                            // Get the ingredient rows
                            let ingredientResult = db.executeQuery("SELECT id, name FROM ingredient WHERE id = \(stepIngredientResult.intForColumn("ingredient_id"))", withArgumentsInArray: nil)
                            ingredientResult.next()
                            ingredient.setId(Int(ingredientResult.intForColumn("id")))
                            ingredient.setName(ingredientResult.stringForColumn("name"))
                            
                            step.addIngredient(ingredient)
                        }
                        recipe.addStep(step)
                    }
                    recipe.initializeTime()
                    recipes.append(recipe)
                }
            }
            db.close()
        }
        else {
            print("Error: \(db.lastErrorMessage())")
        }
        
        return recipes
    }
    
    // Saves recipes to database, and updates the server
    static func saveRecipe(recipe: Recipe, email: String) {
        var entireStatement = ""
        let db = getDBConnection()
        let userId = getUserID(email)
        
        if db.open() {
            // Save recipe
            if recipe.getId() == -1 {
                // Save to recipe table
                db.executeStatements("INSERT INTO recipe (name, type) VALUES (\"\(recipe.getName())\", \"\(recipe.getType())\")")
                entireStatement += "INSERT INTO recipe (name, type) VALUES (\"\(recipe.getName())\", \"\(recipe.getType())\");"
                
                // Update recipe object id
                let result = db.executeQuery("SELECT id FROM recipe WHERE name = \"\(recipe.getName())\"", withArgumentsInArray: nil)
                result.next()
                let recipeId = result.intForColumn("id")
                recipe.setId(Int(recipeId))
                
                // Save to user_recipe table
                db.executeStatements("INSERT INTO user_recipe (user_id, recipe_id) VALUES (\(userId), \(recipe.getId()))")
                entireStatement += "INSERT INTO user_recipe (user_id, recipe_id) VALUES (\(userId), \(recipe.getId()));"
            }
                
            else {
                db.executeUpdate("UPDATE recipe SET name = \"\(recipe.getName())\", type = \"\(recipe.getType())\" WHERE id = \(recipe.getId())", withArgumentsInArray: nil)
                entireStatement += "UPDATE recipe SET name = \"\(recipe.getName())\", type = \"\(recipe.getType())\" WHERE id = \(recipe.getId());"
            }
            
            for step in recipe.getSteps() {
                // Save step
                if step.getId() == -1 {
                    db.executeStatements("INSERT INTO step (number, directions, seconds, recipe_id) VALUES (\(step.getNumber()), \"\(step.getDirections())\", \(step.getTime()), \(recipe.getId()))")
                    entireStatement += "INSERT INTO step (number, directions, seconds, recipe_id) VALUES (\(step.getNumber()), \"\(step.getDirections())\", \(step.getTime()), \(recipe.getId()));"
                    
                    // Get the new id
                    // TODO: there's a small chance, but this could fail terribly
                    let result = db.executeQuery("SELECT id FROM step WHERE number = \(step.getNumber()) AND directions = \"\(step.getDirections())\" AND seconds = \(step.getTime()) AND recipe_id = \(recipe.getId())", withArgumentsInArray: nil)
                    result.next()
                    step.setId(Int(result.intForColumn("id")))
                }
                else {
                    db.executeUpdate("UPDATE step SET number = \(step.getNumber()), directions = \"\(step.getDirections())\", seconds = \(step.getTime()), recipe_id = \(recipe.getId()) WHERE id = \(step.getId())", withArgumentsInArray: nil)
                    entireStatement += "UPDATE step SET number = \(step.getNumber()), directions = \"\(step.getDirections())\", seconds = \(step.getTime()), recipe_id = \(recipe.getId()) WHERE id = \(step.getId());"
                }
                
                // Save ingredients
                for ingredient in step.getIngredients() {
                    // If ingredient exists in database, may need to update
                    if ingredient.getId() != -1 {
                        // Update name of ingredient TODO: will this ever even be necessary?
                        db.executeUpdate("UPDATE ingredient SET name = \"\(ingredient.getName())\" WHERE id = \(ingredient.getId())", withArgumentsInArray: nil)
                        entireStatement += "UPDATE ingredient SET name = \"\(ingredient.getName())\" WHERE id = \(ingredient.getId());"
                        
                        // Check if there are rows in step_ingredient
                        let result = db.executeQuery("SELECT id, step_id, ingredient_id FROM step_ingredient WHERE step_id = \(step.getId()) AND ingredient_id = \(ingredient.getId())", withArgumentsInArray: nil)
                        // Insert if needed
                        //                        if result == nil {
                        if !result.next() {
                            db.executeStatements("INSERT INTO step_ingredient (step_id, ingredient_id, quantity, partial_quantity, unit) VALUES (\(step.getId()), \(ingredient.getId()), \(ingredient.getQuantity()), \"\(ingredient.getPartialQuantity())\", \"\(ingredient.getUnit())\")")
                            entireStatement += "INSERT INTO step_ingredient (step_id, ingredient_id, quantity, partial_quantity, unit) VALUES (\(step.getId()), \(ingredient.getId()), \(ingredient.getQuantity()), \"\(ingredient.getPartialQuantity())\", \"\(ingredient.getUnit())\");"
                        }
                            // Update otherwise
                        else {
                            print(result.intForColumn("id"))
                            print(result.intForColumn("step_id"))
                            print(result.intForColumn("ingredient_id"))
                            db.executeUpdate("UPDATE step_ingredient SET quantity = \(ingredient.getQuantity()), partial_quantity = \"\(ingredient.getPartialQuantity())\", unit = \"\(ingredient.getUnit())\" WHERE step_id = \(step.getId()) AND ingredient_id = \(ingredient.getId())", withArgumentsInArray: nil)
                            entireStatement += "UPDATE step_ingredient SET quantity = \(ingredient.getQuantity()), partial_quantity = \"\(ingredient.getPartialQuantity())\", unit = \"\(ingredient.getUnit())\" WHERE step_id = \(step.getId()) AND ingredient_id = \(ingredient.getId());"
                        }
                    }
                        // Else simply insert
                    else {
                        // Insert ingredient
                        db.executeUpdate("INSERT INTO ingredient (name) VALUES (\"\(ingredient.getName())\")", withArgumentsInArray: nil)
                        entireStatement += "INSERT INTO ingredient (name) VALUES (\"\(ingredient.getName())\");"
                        
                        // Get new ingredient's id
                        let result = db.executeQuery("SELECT id FROM ingredient WHERE name = \"\(ingredient.getName())\"", withArgumentsInArray: nil)
                        result.next()
                        ingredient.setId(Int(result.intForColumn("id")))
                        
                        // Insert relation in step_ingredient
                        db.executeUpdate("INSERT INTO step_ingredient (step_id, ingredient_id, quantity, partial_quantity, unit) VALUES (\(step.getId()), \(ingredient.getId()), \(ingredient.getQuantity()), \"\(ingredient.getPartialQuantity())\", \"\(ingredient.getUnit())\")", withArgumentsInArray: nil)
                        entireStatement += "INSERT INTO step_ingredient (step_id, ingredient_id, quantity, partial_quantity, unit) VALUES (\(step.getId()), \(ingredient.getId()), \(ingredient.getQuantity()), \"\(ingredient.getPartialQuantity())\", \"\(ingredient.getUnit())\");"
                    }
                }
            }
            
            db.close()
        }
        sendSQL(entireStatement)
    }
    
    static func deleteRecipe(email: String, recipe: Recipe) {
        // Need to delete from step, step_ingredient, recipe, user_recipe
        let db = getDBConnection()
        
        if db.open() {
            var entireStatement = ""
            
            // Delete from user_recipe
            db.executeUpdate("DELETE FROM user_recipe WHERE user_id = \(getUserID(email)) AND recipe_id = \(recipe.getId());", withArgumentsInArray: nil)
            entireStatement += "DELETE FROM user_recipe WHERE user_id = \(getUserID(email)) AND recipe_id = \(recipe.getId());"
            
            // If no one else references the recipe, delete all data. Otherwise done.
            let result = db.executeQuery("SELECT * FROM user_recipe WHERE recipe_id = \(recipe.getId());", withArgumentsInArray: nil)
            entireStatement += "SELECT * FROM user_recipe WHERE recipe_id = \(recipe.getId());"
            if !result.next() {
                // Delete from step and step_ingredient
                for step in recipe.getSteps() {
                    // Delete step
                    db.executeUpdate("DELETE FROM step WHERE id = \(step.getId());", withArgumentsInArray: nil)
                    entireStatement += "DELETE FROM step WHERE id = \(step.getId());"
                    
                    // Delete step_ingredients
                    db.executeUpdate("DELETE FROM step_ingredient WHERE step_id = \(step.getId());", withArgumentsInArray: nil)
                    entireStatement += "DELETE FROM step_ingredient WHERE step_id = \(step.getId());"
                }
                
                // Delete from recipe
                db.executeUpdate("DELETE FROM recipe WHERE id = \(recipe.getId());", withArgumentsInArray: nil)
                entireStatement += "DELETE FROM recipe WHERE id = \(recipe.getId());"
            }
            
            sendSQL(entireStatement)
            db.close()
        }
    }
    
    static func deleteStep(step: Step, email: String) {
        let db = getDBConnection()
        
        if db.open() {
            // Delete from step_ingredient
            for ingredient in step.getIngredients() {
                deleteIngredientInStep(ingredient, step: step, email: email)
            }
            
            // Delete from step
            db.executeUpdate("DELETE FROM step WHERE id = \(step.getId());", withArgumentsInArray: nil)
            sendSQL("DELETE FROM step WHERE id = \(step.getId());")
            
            db.close()
        }
    }
    
    static func deleteIngredientInStep(ingredient: Ingredient, step: Step, email: String) {
        let db = getDBConnection()
        
        if db.open() {
            db.executeUpdate("DELETE FROM step_ingredient WHERE step_id = \(step.getId()) AND ingredient_id = \(ingredient.getId());", withArgumentsInArray: nil)
            sendSQL("DELETE FROM step_ingredient WHERE step_id = \(step.getId()) AND ingredient_id = \(ingredient.getId());")
            
            db.close()
        }
    }
    
    static func loadShoppingList(email:String) -> [Ingredient] {
        var ingredients:[Ingredient] = [Ingredient]()
        let db = getDBConnection()
        
        if db.open() {
            let shoppingListRows = db.executeQuery("SELECT ingredient_id, quantity, partial_quantity, unit, checked FROM shopping_list WHERE user_id = \(self.getUserID(email));", withArgumentsInArray: nil)
            
            if shoppingListRows != nil {
                while shoppingListRows.next() {
                    // Get the ingredient names
                    let ingredientRows = db.executeQuery("SELECT name FROM ingredient WHERE id = \(shoppingListRows.intForColumn("ingredient_id"));", withArgumentsInArray: nil)
                    
                    ingredientRows.next()
                    
                    // Create ingredient
                    let ing = Ingredient(name: ingredientRows.stringForColumn("name"), quantity: Int(shoppingListRows.intForColumn("quantity")), partialQuantity: shoppingListRows.stringForColumn("partial_quantity"), unit: shoppingListRows.stringForColumn("unit"), id: Int(shoppingListRows.intForColumn("ingredient_id")))
                    
                    // Set checked
                    ing.setChecked(shoppingListRows.stringForColumn("checked") == "true" ? true : false)
                    
                    // Add to array
                    ingredients.append(ing)
                }
            }
            
            db.close()
        }
        
        return ingredients
    }
    
    static func addToShoppingList(email: String, ingredients: [Ingredient]) {
        let db = getDBConnection()
        
        if db.open() {
            var entireStatement = ""
            
            for ingredient in ingredients {
                // Check if ingredient exists
                let row = db.executeQuery("SELECT quantity, partial_quantity, checked FROM shopping_list WHERE user_id = \(getUserID(email)) AND ingredient_id = \(ingredient.getId())", withArgumentsInArray: nil)
                
                // If ingredient already in table, update
                if row.next() {
                    // Merge the new values with the old values
                    let rowIngredient = Ingredient(name: ingredient.getName(), quantity: Int(row.intForColumn("quantity")), partialQuantity: row.stringForColumn("partial_quantity"), unit: ingredient.getUnit(), id: ingredient.getId())
                    let updatedIngredient = Ingredient.mergeIngredients(ingredient, ingredient2: rowIngredient)
                    
                    // Update row
                    entireStatement += "UPDATE shopping_list SET quantity = \(updatedIngredient.getQuantity()), partial_quantity = \"\(updatedIngredient.getPartialQuantity())\", checked = \"\(row.stringForColumn("checked"))\" WHERE user_id = \(getUserID(email)) AND ingredient_id = \(updatedIngredient.getId());"
                    db.executeUpdate("UPDATE shopping_list SET quantity = \(updatedIngredient.getQuantity()), partial_quantity = \"\(updatedIngredient.getPartialQuantity())\", checked = \"\(row.stringForColumn("checked"))\" WHERE user_id = \(getUserID(email)) AND ingredient_id = \(updatedIngredient.getId());", withArgumentsInArray: nil)
                }
                // If ingredient not in table, add
                else {
                    let checked = ingredient.getChecked() == true ? "true" : "false"
                    entireStatement += "INSERT INTO shopping_list(user_id, ingredient_id, quantity, partial_quantity, unit, checked) VALUES (\(getUserID(email)), \(ingredient.getId()), \(ingredient.getQuantity()), \"\(ingredient.getPartialQuantity())\", \"\(ingredient.getUnit())\", \"\(checked)\");"
                    db.executeStatements("INSERT INTO shopping_list(user_id, ingredient_id, quantity, partial_quantity, unit, checked) VALUES (\(getUserID(email)), \(ingredient.getId()), \(ingredient.getQuantity()), \"\(ingredient.getPartialQuantity())\", \"\(ingredient.getUnit())\", \"\(checked)\");")
                }
            }
            
            if entireStatement != "" {
                sendSQL(entireStatement)
            }
            
            db.close()
        }
    }
    
    static func removeFromShoppingList(email: String, ingredient: Ingredient) {
        let db = getDBConnection()
        
        if db.open() {
            db.executeUpdate("DELETE FROM shopping_list WHERE user_id = \(self.getUserID(email)) AND ingredient_id = \(ingredient.getId());", withArgumentsInArray: nil)
            sendSQL("DELETE FROM shopping_list WHERE user_id = \(self.getUserID(email)) AND ingredient_id = \(ingredient.getId());")
            
            db.close()
        }
    }
    
    static func toggleCheckInShoppingList(email: String, ingredient: Ingredient) {
        let db = getDBConnection()
        
        if db.open() {
            let checked = ingredient.getChecked() == true ? "true" : "false"
            
            db.executeUpdate("UPDATE shopping_list SET checked = \"\(checked)\" WHERE user_id = \(getUserID(email)) AND ingredient_id = \(ingredient.getId());", withArgumentsInArray: nil)
            
            sendSQL("UPDATE shopping_list SET checked = \"\(checked)\" WHERE user_id = \(getUserID(email)) AND ingredient_id = \(ingredient.getId());")
            
            db.close()
        }
    }
    
    static func setCheckInShoppingList(email: String, ingredient: Ingredient, checked: Bool) {
        let db = getDBConnection()
        
        if db.open() {
            let ch = checked ? "true" : "false"
            
            db.executeUpdate("UPDATE shopping_list SET checked = '\(ch)' WHERE user_id = \(getUserID(email)) AND ingredient_id = \(ingredient.getId());", withArgumentsInArray: nil)
            sendSQL("UPDATE shopping_list SET checked = '\(ch)' WHERE user_id = \(getUserID(email)) AND ingredient_id = \(ingredient.getId());")
            
            db.close()
        }
    }
    
    // TODO: I know it's terrible, please, please don't judge me. I just need it to work for now
    // Requests for the server to update the database
    static func sendSQL(sql: String) {
        if let URL = NSURL(string: "http://159.203.75.63:5000/upload") {
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            let request = NSMutableURLRequest(URL: URL)
            request.HTTPMethod = "POST"
            request.addValue(sql, forHTTPHeaderField: "sql")
            var success:Bool? = nil
            
            let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if (error == nil) {
                    // Success
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    
                    if statusCode == 200 {
                        success = true
                    }
                    else {
                        success = false
                    }
                }
                else {
                    // Failure
                    print("Failure: %@", error!.localizedDescription);
                }
            })
            task.resume()
            
            while success == nil {
                // Spin! Yay!
                // I know this is bad... Trust me. I know
            }
        }
    }
    
    // Loads ingredients from database to objects
    static func loadIngredients() -> [Ingredient] {
        let db = getDBConnection()
        var ingredients = [Ingredient]()
        
        if db.open() {
            let result = db.executeQuery("SELECT id, name FROM ingredient", withArgumentsInArray: nil)
            while result.next() {
                let ingredient = Ingredient()
                ingredient.setId(Int(result.intForColumn("id")))
                ingredient.setName(result.stringForColumn("name"))
                ingredient.setQuantity(-1)
                ingredient.setUnit("")
                
                ingredients.append(ingredient)
            }
            
            db.close()
            
            return ingredients
        }
        
        return [Ingredient]()
    }
    
    // Loads settings from database to object
    static func loadSettings(email: String) -> Settings {
        let db = getDBConnection()
        
        if db.open() {
            let result = db.executeQuery("SELECT autoplay, speech FROM settings WHERE user_id = \(getUserID(email))", withArgumentsInArray: nil)
            if result.next() {
                let autoplay = result.stringForColumn("autoplay") == "true" ? true : false
                let speech = result.stringForColumn("speech") == "true" ? true : false
                db.close()
                return Settings(autoplay: autoplay, textToSpeech: speech)
            }
        }
        
        // If no row in table or can't access DB
        return Settings(autoplay: false, textToSpeech: false)
    }
    
    static func setAutoplay(autoplay: Bool, email: String) {
        let db = getDBConnection()
        
        if db.open() {
            let auto = autoplay == true ? "true" : "false"
            
            db.executeUpdate("UPDATE settings SET autoplay = '\(auto)' WHERE user_id = \(getUserID(email));", withArgumentsInArray: nil)
            sendSQL("UPDATE settings SET autoplay = '\(auto)' WHERE user_id = \(getUserID(email));")
            
            db.close()
        }
    }
    
    static func setSpeech(speech: Bool, email: String) {
        let db = getDBConnection()
        
        if db.open() {
            let sp = speech == true ? "true" : "false"
            
            db.executeUpdate("UPDATE settings SET speech = '\(sp)' WHERE user_id = \(getUserID(email));", withArgumentsInArray: nil)
            sendSQL("UPDATE settings SET speech = '\(sp)' WHERE user_id = \(getUserID(email));")
            
            db.close()
        }
    }
    
    // Gets a user id from
    static func getUserID(email: String) -> Int {
        let db = getDBConnection()
        
        if db.open() {
            let result = db.executeQuery("SELECT id FROM user WHERE email = \"\(email)\"", withArgumentsInArray: nil)
            result.next()
            let id = result.intForColumn("id")
            db.close()
            return Int(id)
        }
        
        return -1
    }
    
    static func getDBConnection() -> FMDatabase {
        return FMDatabase(path: getDatabasePath() as String)
    }
    
    static func getPath() -> String {
        return String(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true))
    }
}