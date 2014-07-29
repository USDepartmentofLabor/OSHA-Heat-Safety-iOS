//
//  PrecautionsView.h
//  Heat Safety
//
//  Created by mkeefe on 8/17/11.
//  
//

#import <UIKit/UIKit.h>

@interface PrecautionsView : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView *webView;
    IBOutlet UILabel *riskLevelLabel;
    IBOutlet UILabel *heatIndexLabel;
    IBOutlet UILabel *heatIndexValue;
    IBOutlet UILabel *heatIndexCatLabel;
    IBOutlet UILabel *noaaTime;
}

-(IBAction)doneHandler;

- (void)redrawApp;
- (void)updateTime:(NSString *)time;
- (void)displayPage:(NSString *)theURL withHeatIndex:(NSString *)heatIndex andHeatIndexCat:(NSString *)heatIndexCat;

@property (nonatomic, retain) NSString *heatIndexVal;
@property (nonatomic, retain) NSString *savedHeatIndexVal;
@property (nonatomic, retain) NSString *heatIndexCategory;
@property (nonatomic, retain) NSURL *precautionsPageURL;
@property (nonatomic, retain) UIWebView *webView;

@property (nonatomic, retain) IBOutlet UILabel *riskLevelLabel;
@property (nonatomic, retain) IBOutlet UILabel *heatIndexLabel;
@property (nonatomic, retain) IBOutlet UILabel *heatIndexValue;
@property (nonatomic, retain) IBOutlet UILabel *heatIndexCatLabel;
@property (nonatomic, retain) IBOutlet UILabel *noaaTime;

@end