//
//  FirstViewController.h
//  heatapp
//
//  Created by mkeefe on 9/9/11.
//  
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "XMLReader.h"

@interface FirstViewController : UIViewController <CLLocationManagerDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *masthead;
    IBOutlet UIButton *calculateBtn;
    IBOutlet UIButton *getTodayMaxBtn;
    IBOutlet UIButton *getCurrentBtn;
    IBOutlet UIButton *precautionsBtn;
    IBOutlet UILabel *heatIndexLabel;
    IBOutlet UILabel *riskLevelLabel;
    IBOutlet UILabel *heatIndexValue;
    IBOutlet UILabel *riskLevelValue;
    IBOutlet UILabel *temperatureLabel;
    IBOutlet UILabel *humidityLabel;
    IBOutlet UITextField *temperatureField;
    IBOutlet UITextField *humidityField;
    IBOutlet UILabel *noaaTime;
    CLLocationManager *locationManager;
    NSDictionary *_xmlDictionary;
}

// Button handlers
-(IBAction)getCurrent;
-(IBAction)getTodayMax;
-(IBAction)showPrecautions;
-(IBAction)calculatePressed;

// Heat Index Methods
- (void)updateHeatLevel:(double)level;
- (void)calculateHeatIndex:(float)temperature withHumidity:(float)humidity;
- (float)getHeatIndex:(float)temp withHumidity:(float)humidity;
- (void)getCurrentHeatIndex;
- (void)getMaxHeatIndex;

- (void)resetApp;

// NOAA
- (void)getNOAAData;

// UI Methods
- (void)redrawApp;
- (void)hideKeyboard;
- (void)alertBox:(NSString *)title withMessage:(NSString *)message andLabel:(NSString *)buttonLabel;

//properties
@property (nonatomic, retain) IBOutlet UIButton *calculateBtn;
@property (nonatomic, retain) IBOutlet UIButton *getTodayMaxBtn;
@property (nonatomic, retain) IBOutlet UIButton *getCurrentBtn;
@property (nonatomic, retain) IBOutlet UIButton *precautionsBtn;
@property (nonatomic, retain) IBOutlet UILabel *temperatureLabel;
@property (nonatomic, retain) IBOutlet UILabel *humidityLabel;
@property (nonatomic, retain) IBOutlet UILabel *heatIndexLabel;
@property (nonatomic, retain) IBOutlet UILabel *riskLevelLabel;
@property (nonatomic, retain) IBOutlet UILabel *heatIndexValue;
@property (nonatomic, retain) IBOutlet UILabel *riskLevelValue;
@property (nonatomic, retain) IBOutlet UITextField *temperatureField;
@property (nonatomic, retain) IBOutlet UITextField *humidityField;
@property (nonatomic, retain) IBOutlet UILabel *noaaTime;
@property (nonatomic, retain) IBOutlet UIImageView *masthead;
@property (nonatomic, retain) IBOutlet CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@end
