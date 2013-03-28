//
//  SecondaryView.h
//  Heat Safety
//
//  Created by mkeefe on 8/4/11.
//  Copyright 2011 PixelBit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondaryView : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView *webView;
    
}

-(IBAction)doneHandler;
- (void)displayPage:(NSString *)theURL;

@property (nonatomic, retain) UIWebView *webView;

@end