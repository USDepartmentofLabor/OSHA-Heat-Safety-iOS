//
//  SecondaryView.h
//  Heat Safety
//
//  Created by mkeefe on 8/4/11.
//  
//

#import <UIKit/UIKit.h>

@interface SecondaryView : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView *webView;
    IBOutlet UILabel *testLabel;
}

-(IBAction)doneHandler;
- (void)displayPage:(NSString *)theURL;

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UILabel *testLabel;
@end