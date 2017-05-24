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
        tracker?.set(kGAIScreenName, value: "More Info Screen")
        tracker?.send(GAIDictionaryBuilder.createAppView().build() as! [AnyHashable: Any])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moreInfoItems.count
    }
    
    // Init each option in the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell")! 
        
        cell.textLabel!.text = NSLocalizedString(moreInfoItems[indexPath.row], comment: moreInfoItems[indexPath.row] + " Title")
        
        let imageName = UIImage(named: moreInfoImages[indexPath.row])
        cell.imageView!.layer.masksToBounds = true
        cell.imageView!.layer.cornerRadius = 7.0
        cell.imageView!.image = imageName
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make sure the ugly table cell selection is cleared when returning to this view
        if (self.tableView.indexPathForSelectedRow != nil) {
            self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: false)
        }
    }
    
    // Allow more info view to be closed
    @IBAction func dismissMoreInfo(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Load content for the selected web view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webViewSegue" {
            let destinationViewController = segue.destination as! WebViewController
            destinationViewController.infoContent = moreInfoItems[tableView.indexPathForSelectedRow!.row]
        }
    }
    
}
