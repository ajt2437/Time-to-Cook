//
//  Settings.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 4/26/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import Foundation

class Settings {
    private var autoplay:Bool = false
    private var textToSpeech:Bool = false
    
    init(autoplay:Bool, textToSpeech:Bool) {
        self.autoplay = autoplay
        self.textToSpeech = textToSpeech
    }
    
    func getAutoplay() -> Bool {
        return self.autoplay
    }
    
    func setAutoplay(autoplay:Bool) {
        self.autoplay = autoplay
    }
    
    func getTextToSpeech() -> Bool {
        return self.textToSpeech
    }
    
    func setTextToSpeech(textToSpeech:Bool) {
        self.textToSpeech = textToSpeech
    }
}