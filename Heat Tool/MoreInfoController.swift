//
//  MoreInfoController.swift
//  Heat Tool
//
//  Created by E J Kalafarski on 1/23/15.
//  Code is in the public domain
//

import UIKit

class MoreInfoController: UITableViewController {
    
    let moreInfoItems = ["Signs and Symptoms","First Aid","More Details","Contact OSHA","About This App"];
    let moreInfoImages = ["moreinfo_signs","moreinfo_firstAid","moreinfo_more","moreinfo_contact","moreinfo_about"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Record GA view
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "More Info Screen")
        tracker.send(GAIDictionaryBuilder.createAppView().build() as [NSObject : AnyObject])
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moreInfoItems.count
    }
    
    // Init each option in the table
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("infoCell")! 
        
        cell.textLabel!.text = NSLocalizedString(moreInfoItems[indexPath.row], comment: moreInfoItems[indexPath.row] + " Title")
        
        let imageName = UIImage(named: moreInfoImages[indexPath.row])
        cell.imageView!.layer.masksToBounds = true
        cell.imageView!.layer.cornerRadius = 7.0
        cell.imageView!.image = imageName
        
        return cell
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make sure the ugly table cell selection is cleared when returning to this view
        if (self.tableView.indexPathForSelectedRow != nil) {
            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: false)
        }
    }
    
    // Allow more info view to be closed
    @IBAction func dismissMoreInfo(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Load content for the selected web view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "webViewSegue" {
            let destinationViewController = segue.destinationViewController as! WebViewController
            destinationViewController.infoContent = moreInfoItems[tableView.indexPathForSelectedRow!.row]
        }
    }
    
}
