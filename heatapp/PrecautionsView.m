//
//  PrecautionsView.m
//  Heat Safety
//
//  Created by mkeefe on 8/17/11.
//  
//

#import "PrecautionsView.h"
#import "SecondaryView.h"
#import "Language.h"

@implementation PrecautionsView

@synthesize webView, heatIndexVal, savedHeatIndexVal;
@synthesize riskLevelLabel, heatIndexLabel, heatIndexValue, heatIndexCatLabel, noaaTime, heatIndexCategory, precautionsPageURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)doneHandler { 
    NSLog(@"[doneHandler]");
    [self.view removeFromSuperview];
}

- (void)displayPage:(NSString *)theURL withHeatIndex:(NSString *)heatIndex andHeatIndexCat:(NSString *)heatIndexCat {
    
    NSLog(@"[displayPage] heatIndex: %@", heatIndex);
    NSLog(@" - theURL: %@", theURL);
    NSLog(@" - heatIndexCat: %@", heatIndexCat);
    
    [self updateTime:@""];
    
    if(heatIndex == nil) {
        heatIndexVal = nil;
    } else {
        heatIndexVal = heatIndex;
        savedHeatIndexVal = heatIndex;
        heatIndexCategory = heatIndexCat;
    }
    
    // set heat index
//    heatIndexValue.text = heatIndex;
    NSLog(@"Setting displayed heat index value.  Was: %@, changing it to: %@", heatIndexValue.text, heatIndex);
    [heatIndexValue setText:heatIndex];
    NSLog(@"Set displayed heat index value.  Changed it to: %@", heatIndexValue.text);
   
    /*
     Heat Level colors (rgb)
     -------------------------------
     low        r:255, g:255, b:0
     moderate   r:254, g:211, b:156
     high       r:247, g:142, b:1
     extreme    r:254, g:0, b:0
     -------------------------------
     */
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:theURL ofType:@"htm" inDirectory:[Language getLocalizedString:@"HTML_PATH"]];
    precautionsPageURL = [NSURL fileURLWithPath:path];
   // NSLog(@"URL is: %@", url);
}

- (void)updateTime:(NSString *)time {
    noaaTime.text = time;
}

- (NSString *)cleanHeatIndex:(NSString *)str {
    return [str stringByReplacingOccurrencesOfString:@" °F" withString:@""];
}

#pragma mark UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)wv {
	//NSLog(@"webViewDidStartLoad:");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // remove ' °F' from string, causes app to bark!
    if(heatIndexVal != nil) {
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"set_heat_index(%@);", [self cleanHeatIndex:heatIndexVal]]];
    } else {
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"set_heat_index(%@);", [self cleanHeatIndex:savedHeatIndexVal]]];
    }
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
	NSLog(@"webView:didFailLoadWithError:");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {  
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *requestURL = [request URL];
        // Only load "live" links in Safari
        if([[requestURL scheme] isEqualToString: @"http"] || [[requestURL scheme] isEqualToString: @"https"]) { 
            [[UIApplication sharedApplication] openURL:requestURL];
            return NO;
        } else {
            return YES;
        }
    } else {
        return YES;
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)redrawApp {    
    [riskLevelLabel setText:[Language getLocalizedString:@"RISK_LEVEL"]];
    [heatIndexLabel setText:[Language getLocalizedString:@"HEAT_INDEX"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [heatIndexValue setText:heatIndexVal];
    NSLog(@"Set displayed heat index value.  Changed it to: %@", heatIndexValue.text);
    
    
    // Set heat index cat
    if([heatIndexCategory  isEqual: @"extreme"]) {
        heatIndexCatLabel.text = [Language getLocalizedString:@"LVL_EXTREME"];
        [heatIndexCatLabel setBackgroundColor:[UIColor colorWithRed:254.0/255 green:0/255 blue:0/255 alpha:1]];
    } else if([heatIndexCategory  isEqual: @"high"]) {
        heatIndexCatLabel.text = [Language getLocalizedString:@"LVL_HIGH"];
        [heatIndexCatLabel setBackgroundColor:[UIColor colorWithRed:247.0/255 green:142.0/255 blue:1.0/255 alpha:1]];
    } else if([heatIndexCategory  isEqual: @"moderate"]) {
        heatIndexCatLabel.text = [Language getLocalizedString:@"LVL_MODERATE"];
        [heatIndexCatLabel setBackgroundColor:[UIColor colorWithRed:254.0/255 green:211.0/255 blue:156.0/255 alpha:1]];
    } else if([heatIndexCategory  isEqual: @"lower"]) {
        heatIndexCatLabel.text = [Language getLocalizedString:@"LVL_LOWER"];
        [heatIndexCatLabel setBackgroundColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:0/255 alpha:1]];
    } else {
        heatIndexCatLabel.text = [Language getLocalizedString:@"LVL_LOWER"];
        [heatIndexCatLabel setBackgroundColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:0/255 alpha:1]];
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:precautionsPageURL];
    [webView loadRequest:request];
    webView.delegate = self;


    [self redrawApp];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [webView release];
    [heatIndexVal release];
    [savedHeatIndexVal release];
    [riskLevelLabel release];
    [heatIndexLabel release];
    [heatIndexValue release];
    [heatIndexCatLabel release];
    [noaaTime release];
}

/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
 {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }*/

@end