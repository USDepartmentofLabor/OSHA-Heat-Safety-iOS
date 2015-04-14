//
//  PrecautionsController.swift
//  Heat Tool
//
//  Created by E J Kalafarski on 2/17/15.
//  Copyright (c) 2015 OSHA. All rights reserved.
//

import UIKit

class PrecautionsController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var localfilePath = NSURL()
    var precautionLevel = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var localFilePath = NSBundle.mainBundle().pathForResource(precautionLevel, ofType: "html")
        var contents = NSString(contentsOfFile: localFilePath!, encoding: NSUTF8StringEncoding, error: nil)
        
        // Set the base URL for the web view so we can access resources
        var path = NSBundle.mainBundle().bundlePath
        var baseUrl  = NSURL.fileURLWithPath("\(path)")
        
        webView.delegate = self
        webView.loadHTMLString(contents as! String, baseURL: baseUrl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        // If it's a web link
        if request.URL!.scheme == "http" {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        
        // If it's a local link
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
