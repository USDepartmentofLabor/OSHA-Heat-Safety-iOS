//
//  SecondaryView.m
//  Heat Safety
//
//  Created by mkeefe on 8/4/11.
//  Copyright 2011 PixelBit Inc. All rights reserved.
//

#import "SecondaryView.h"
#import "Language.h"

@implementation SecondaryView

@synthesize webView;

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

- (void)displayPage:(NSString *)theURL {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:theURL ofType:@"htm" inDirectory:[Language getLocalizedString:@"HTML_PATH"]];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    webView.delegate = self;
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
