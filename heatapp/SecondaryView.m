//
//  SecondaryView.m
//  Heat Safety
//
//  Created by mkeefe on 8/4/11.
//  
//

#import "SecondaryView.h"
#import "Language.h"

@implementation SecondaryView

@synthesize webView, testLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        // Custom initialization
    }
    return self;
}

NSURL *pageURL;

-(IBAction)doneHandler { 
    NSLog(@"[doneHandler]");
    [self.view removeFromSuperview];
}

- (void)displayPage:(NSString *)theURL {
    
    testLabel.text = @"helloooo!";
    NSLog(@"label text is: %@", testLabel.text);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:theURL ofType:@"htm" inDirectory:[Language getLocalizedString:@"HTML_PATH"]];
//    NSURL *url = [NSURL fileURLWithPath:path];
    pageURL = [NSURL fileURLWithPath:path];
//    NSURL *goog = [NSURL URLWithString:@"http://www.google.com"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    NSLog(@"URL is: %@", request);
    
//    [webView loadRequest:request];
//    webView.delegate = self;
    
    NSLog(@"%@", self.webView);
    
}

#pragma mark UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)wv {
	NSLog(@"webViewDidStartLoad:");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self setTitle:theTitle];
    NSURLRequest *requestPage = [NSURLRequest requestWithURL:pageURL];
    
    [self.webView loadRequest:requestPage];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    testLabel.text = @"helloooo!";
    NSLog(@"label text is: %@", testLabel.text);

    if (!webView) {
        NSLog(@"it's nil!");
       // NSURL *url = [NSURL fileURLWithPath:pageURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:pageURL];
        [webView loadRequest:request];
        NSLog(@"URL2 is: %@", request);
 
    } else {
        NSLog(@"not nil!");
        NSURLRequest *request = [NSURLRequest requestWithURL:pageURL];
        [webView loadRequest:request];
        NSLog(@"URL2 is: %@", request);
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
} 

@end
