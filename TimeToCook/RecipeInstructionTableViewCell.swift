//
//  RecipeInstructionTableViewCell.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 3/22/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class RecipeInstructionTableViewCell: UITableViewCell {

    @IBOutlet weak var instruction: UILabel!
    @IBOutlet weak var number: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Function to load data from step into @IBOutlets
    func loadData(row:Int, step:Step) {
        
        self.number.text = "\(String(row + 1))."
        self.instruction.text = step.getDirections()
    }
}
