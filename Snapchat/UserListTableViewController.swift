//
//  UserListTableViewController.swift
//  Snapchat
//
//  Created by geine on 15/3/9.
//  Copyright (c) 2015年 isee. All rights reserved.
//

import UIKit

class UserListTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var UsersArr = [String]()
    var ActiveRecipient = 0
    var Timer = NSTimer()

    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        var imageToSend = PFObject(className: "image")
        //parse limit 128K
        imageToSend["photo"] = PFFile(name: "image.png", data: UIImageJPEGRepresentation(image, 0.5))
        imageToSend["senderUsername"] = PFUser.currentUser().username
        imageToSend["recipientUsername"] = UsersArr[ActiveRecipient]
        imageToSend.saveInBackgroundWithBlock(nil)
    }
    
    func pickImage() {
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Logout" {
            PFUser.logOut()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var query = PFUser.query()
        query.whereKey("username", notEqualTo: PFUser.currentUser().username)
        query.findObjectsInBackgroundWithBlock { (results:[AnyObject]!, error) -> Void in
            if results != nil {
                for result in results {
                    self.UsersArr.append(result.username)
                }
                self.tableView.reloadData()
            } else {
                println("find error.")
            }
        }
        
        Timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("checkForMessage"), userInfo: nil, repeats: true)
    }
    
    func checkForMessage() {
        var query = PFQuery(className: "image")
        query.whereKey("recipientUsername", equalTo: PFUser.currentUser().username)
        var images = query.findObjects()
        var done = false
        
        for image in images {
            if done == false {
                var imageView = PFImageView()
                imageView.file = image["photo"] as PFFile
                imageView.loadInBackground({ (photo, error) -> Void in
                    if error == nil {
                        var senderUsername = ""
                        if image["senderUsername"] != nil {
                            senderUsername = image["senderUsername"] as String
                        } else {
                            senderUsername = "unknown user"
                        }
                        
                        var alert = UIAlertController(title: "You have a message", message: "Message From \(senderUsername)", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            
                            var backgroundView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                            backgroundView.backgroundColor = UIColor.blackColor()
                            backgroundView.alpha = 0.8
                            backgroundView.tag = 10086
                            self.view.addSubview(backgroundView)
                            
                            var displayImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                            displayImage.image = photo
                            displayImage.tag = 10086
                            displayImage.contentMode = UIViewContentMode.ScaleAspectFit
                            self.view.addSubview(displayImage)
                            image.delete()
                            
                            self.Timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("hideMessage"), userInfo: nil, repeats: false)
                        }))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
                
                done = true
            }
        }
    }
    
    func hideMessage() {
        for subview in self.view.subviews {
            if subview.tag == 10086 {
                subview.removeFromSuperview()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return UsersArr.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell

        cell.textLabel?.text = UsersArr[indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        ActiveRecipient = indexPath.row
        
        pickImage()
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
