//
//  LoginViewController.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 4/3/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        self.statusLabel.text = ""
        print(DBManager.getPath())
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
        
        if (identifier == "LoginSegue") {
            if emailTextField.text == "" || passwordTextField.text == "" {
                statusLabel.text = "Please enter both email and password"
                return false
            }
            
            // Validate login
            let result = DBManager.login(emailTextField.text!, password: passwordTextField.text!)
            
            if result == false {
                self.statusLabel.text = "Failed to sign in"
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
        if segue.identifier == "LoginSegue" {
            let destinationVC = segue.destinationViewController as! TabBarController
            destinationVC.email = emailTextField.text!
        }
    }
    
}