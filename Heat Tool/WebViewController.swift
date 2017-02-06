//
//  WebViewController.swift
//  Heat Tool
//
//  Created by E J Kalafarski on 2/28/15.
//  Code is in the public domain
//

import UIKit

class WebViewController: GAITrackedViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var infoContent = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View name for Google Analytics
        self.screenName = "Info Content Screen"
        
        // Do any additional setup after loading the view.
        webView.delegate = self
        
        // Set navigation bar title
        self.title = NSLocalizedString(infoContent, comment: infoContent + " Title")
        
        // Get the contents of the file to load
        let localFilePath = NSBundle.mainBundle().pathForResource(infoContent, ofType: "html")
        do {
        let contents = try NSString(contentsOfFile: localFilePath!, encoding: NSUTF8StringEncoding)
        
        // Get the base URL of the file so we can access its resources
        let baseUrl = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath)
        
        // Load contents into the webview
        webView.loadHTMLString(contents as String, baseURL: baseUrl)
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType nt: UIWebViewNavigationType) -> Bool {
        // If it's a web link
        if request.URL!.scheme == "http" {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        
        //-------------------------------------------------------------------------------------------
        //Gino: Block added to handle links clicked when navigating from inner pages of More Info beyond
        //the first screen.
        
        // If it's a local html page link that was clicked
        if nt == UIWebViewNavigationType.LinkClicked {
        
           // Set the base URL for the web view so we can access resources
           let baseURL2 = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath)
            
           // Set file name of target clicked link
           let fileName = request.URL!.URLByDeletingPathExtension?.lastPathComponent
            
           // Set local file to be loaded into webView
           let htmlFile = NSBundle.mainBundle().pathForResource(fileName, ofType: "html")
        
            do {
                // Set contents to local html content
                let contents = try String(contentsOfFile: htmlFile!, encoding: NSUTF8StringEncoding)
                
                // Load contents into the webview
                webView.loadHTMLString(contents as String , baseURL: baseURL2)
                
            } catch {
                print(error)
            }
            return false
            
        }
        //-------------------------------------------------------------------------------------------
        
        
        // If it's the initial load
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
