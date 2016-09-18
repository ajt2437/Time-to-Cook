//
//  SignUpViewController.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 4/3/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        // Do any additional setup after loading the view.
        statusLabel.text = ""
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
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if (identifier == "CreateAccountSegue") {
            if emailTextField.text == "" || passwordTextField.text == "" {
                statusLabel.text = "Please enter information for all fields"
                return false
            }
            
            // Validate create account
            let result = DBManager.signup(emailTextField.text!, password: passwordTextField.text!)
            
            if result == false {
                self.statusLabel.text = "Failed to sign up"
            }
            
            return result
        }
        
        return true;
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "CreateAccountSegue" {
            let destinationVC = segue.destinationViewController as! TabBarController
            destinationVC.email = emailTextField.text!
        }
    }
}