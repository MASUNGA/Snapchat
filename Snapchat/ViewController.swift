//
//  ViewController.swift
//  Snapchat
//
//  Created by geine on 15/3/9.
//  Copyright (c) 2015年 isee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var UsernameField: UITextField!

    @IBAction func SigninPress(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(UsernameField.text, password:"mypass") {
            (user: PFUser!, error: NSError!) -> Void in
            if user != nil {
                self.performSegueWithIdentifier("UserList", sender: self)
            } else {
                self.userSignUp()
            }
        }
    }
    
    func userSignUp() {
        var user = PFUser()
        user.username = UsernameField.text
        user.password = "mypass"
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool!, error: NSError!) -> Void in
            if error == nil {
                println("succefully!")
                self.performSegueWithIdentifier("UserList", sender: self)
            } else {
                println("Sign up error!")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

