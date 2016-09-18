//
//  Recipe.swift
//  TimeToCook
//
//  Created by Cody Stanfield on 3/21/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import Foundation
import UIKit

class Recipe {
    private var id:Int = -1
    private var name:String = ""
    private var type:String = ""
    private var steps:[Step] = [Step]()
    private var time:Int = 0
    private var image:UIImage = UIImage(named:"NoImageSet.png")!
    
    init(name:String, type:String, steps:[Step]) {
        self.name = name
        self.type = type
        self.steps = steps
        
        self.time = 0
        
        for step in steps {
            self.time += step.getTime()
        }
    }
    
    init(name: String) {
        self.name = name
    }
    
    init() {
    }
    
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
    
    func getType() -> String {
        return self.type
    }
    
    func setType(type:String) {
        self.type = type
    }
    
    func getSteps() -> [Step] {
        return self.steps
    }
    
    func setSteps(steps:[Step]) {
        self.steps = steps
    }
    
    func addStep(step: Step) {
        self.steps.append(step)
    }
    
    func getTime() -> Int {
        return self.time
    }
    
    func getImage() -> UIImage {
        return self.image
    }
    
    func setImage(image:UIImage) {
        self.image = image
    }
    
    func initializeTime() {
        var time = 0
        
        for step in self.steps {
            time += step.getTime()
        }
        
        self.time = time
    }
    
    // Formats the time as a string
    func getFormattedTime() -> String {
        return Step.getFormattedTime(self.time)
    }
    
    func setTime(time:Int) {
        self.time = time
    }
}