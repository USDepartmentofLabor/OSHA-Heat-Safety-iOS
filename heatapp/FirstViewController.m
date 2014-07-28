//
//  FirstViewController.m
//  heatapp
//
//  Created by mkeefe on 9/9/11.
//  
//

#import "FirstViewController.h"
#import "PrecautionsView.h"
#import "Language.h"

@implementation FirstViewController

@synthesize calculateBtn, getCurrentBtn, getTodayMaxBtn, precautionsBtn;
@synthesize heatIndexLabel, riskLevelLabel, temperatureLabel, humidityLabel, heatIndexValue, riskLevelValue, temperatureField, humidityField, locationManager;
@synthesize noaaTime, masthead, scrollView;

// stored values
NSString *heatLevel;
NSString *currentHeatIndex;
NSString *currentMode = nil;
float temperature;
float humidity;

// location
float curLat = 42.46;
float curLon = -71.25;

// Date/Time/Temp items
NSMutableArray *_temperature;
NSMutableArray *_humidity;
NSMutableArray *_time;
NSMutableArray *validIndexes;
NSInteger day;
NSInteger hour;
NSInteger min;

// NOAA data
NSInteger noaaHour;
NSString *noaaAMPM = nil;
//Ilya 6/13/14 changed generic code to a reverse engineered URL
NSString *noaaURL = @"<Insert Web service call URL (Weather Web Service Call to NOAA Web Site). To use service, contact www.noaa.gov>";

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:[Language getLocalizedString:@"HEAT_INDEX"]];
    
    temperatureField.keyboardType = UIKeyboardTypeDecimalPad;
    humidityField.keyboardType = UIKeyboardTypeDecimalPad;
    
    //[scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height)];
    //curLanguage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
    
    // default to English, just in case.
    //if(curLanguage == nil) curLanguage = @"en";
    //[Language setLanguage:curLanguage];
    NSLog(@"Current Language: %@", [Language getLanguage]);
    
    [self redrawApp];
}

#pragma mark - Location Handlers

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
    
    NSLog(@"Coords: %@", [NSString stringWithFormat:@"Latitude: %f Longitude: %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude]);
    NSLog(@"currentMode: %@", currentMode);
    
    curLat = newLocation.coordinate.latitude;
    curLon = newLocation.coordinate.longitude;
    
    if([currentMode isEqualToString:@"getMax"]) {
        [self getMaxHeatIndex];
    } else if([currentMode isEqualToString:@"getCurrent"]) {
        [self getCurrentHeatIndex];
    } else {
        // do nothing
    }
    
    currentMode = nil;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError*)error {
    if([(NSString *)[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"]) {
        
        // default location, for testing.
        curLat = 42.46;
        curLon = -71.25;
        NSLog(@"Could not determine your location");
        
        if([currentMode isEqualToString:@"getMax"]) {
            [self getMaxHeatIndex];
        } else if([currentMode isEqualToString:@"getCurrent"]) {
            [self getCurrentHeatIndex];
        }
        
        return;
        
    } else {
        [self alertBox:[Language getLocalizedString:@"NOTIFICATION"] withMessage:[Language getLocalizedString:@"NO_GPS"] andLabel:[Language getLocalizedString:@"OK"]];
    }
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Interface Builder Methods

- (void)resetApp {
    heatLevel = nil;
    currentHeatIndex = nil;
    currentMode = nil;
    temperature = 0;
    humidity = 0;
    _temperature = nil;
    _humidity = nil;
    _time = nil;
    validIndexes = nil;
    day = 0;
    hour = 0;
    min = 0;
    noaaHour = 0;
    noaaAMPM = nil;
    
    noaaTime.text = @"";
    temperatureField.text = @"";
    humidityField.text = @"";
    heatIndexValue.text = @"";
    riskLevelValue.text = @"";
    [riskLevelValue setBackgroundColor:[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1]];
}

-(IBAction)getCurrent { 
    NSLog(@"[getCurrent]");
    [self hideKeyboard];
    currentMode = @"getCurrent";
    
    if([(NSString *)[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"]) {
        [self getCurrentHeatIndex];
        return;
    }
    
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

-(IBAction)getTodayMax {
    NSLog(@"[getTodayMax]");
    [self hideKeyboard];
    currentMode = @"getMax";
    
    if([(NSString *)[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"]) {
        [self getMaxHeatIndex];
        return;
    }
    
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

-(IBAction)showPrecautions { 
    NSLog(@"[showPrecautions]");
    
    [self hideKeyboard];
    
    NSString *tmpHeatIndex = heatIndexValue.text;
    PrecautionsView* subView = [[PrecautionsView alloc] initWithNibName:@"PrecautionsView" bundle:nil];
    //[self.view addSubview:subView.view];
    //subView.view.frame = self.view.bounds;
    
    subView.title = [Language getLocalizedString:@"PRECAUTIONS"];
    [self.navigationController pushViewController:subView animated:YES];
    
    //[subView release];
    NSLog(@"Heat level: %@", heatLevel);
    
    // set risk level, used all over the app
    if([heatLevel isEqualToString:@"extreme"]) {
        NSLog(@"EXTREME!");
        [subView displayPage:@"precautions_veryhigh" withHeatIndex:tmpHeatIndex andHeatIndexCat:@"extreme"];
    } else if([heatLevel isEqualToString:@"high"]) {
        [subView displayPage:@"precautions_high" withHeatIndex:tmpHeatIndex andHeatIndexCat:@"high"];
    } else if([heatLevel isEqualToString:@"moderate"]) {
        [subView displayPage:@"precautions_moderate" withHeatIndex:tmpHeatIndex andHeatIndexCat:@"moderate"];
    } else if([heatLevel isEqualToString:@"lower"]) {
        NSLog(@"If determined %@ is not equal to extreme, but is lower", heatLevel);
        [subView displayPage:@"precautions_lower" withHeatIndex:tmpHeatIndex andHeatIndexCat:@"lower"];
    } else {
        NSLog(@"If determined %@ is not equal to extreme", heatLevel);
        [subView displayPage:@"precautions_lower" withHeatIndex:tmpHeatIndex andHeatIndexCat:@"lower"];
    }
    
    if(![noaaTime.text isEqualToString:@""]) {
       [subView updateTime:noaaTime.text];
    }
}

-(IBAction)calculatePressed {
    NSLog(@"[calculatePressed]"); 
    [self hideKeyboard];
    
    noaaTime.text = @"";
    
    temperature = [temperatureField.text floatValue];
    humidity = [humidityField.text floatValue];
    [self calculateHeatIndex:temperature withHumidity:humidity];
}

#pragma mark - Heat Index Methods

- (void)updateHeatLevel:(double)level {
    
    // Check heat level
    if(level > 115) {
        heatLevel = @"extreme";
    } else if(level > 103 & level <= 115) {
        heatLevel = @"high";
    } else if(level >= 91 & level <= 103) {
        heatLevel = @"moderate";
    } else if(level < 91) {
        heatLevel = @"lower";
    } else {
        heatLevel = @"lower";
    }
    
    // set heat index value
    currentHeatIndex = [NSString stringWithFormat:@"%.1f", level];
    heatIndexValue.text = [NSString stringWithFormat:@"%@ °F", currentHeatIndex];
    
    /*
     Heat Level colors (rgb)
     -------------------------------
     low        r:255, g:255, b:0
     moderate   r:254, g:211, b:156
     high       r:247, g:142, b:1
     extreme    r:254, g:0, b:0
     -------------------------------
     */
    
    // set risk level, used all over the app
    if([heatLevel isEqualToString:@"extreme"]) {
        riskLevelValue.text = [Language getLocalizedString:@"LVL_EXTREME"];
        [riskLevelValue setBackgroundColor:[UIColor colorWithRed:254.0/255 green:0/255 blue:0/255 alpha:1]];
    } else if([heatLevel isEqualToString:@"high"]) {
        riskLevelValue.text = [Language getLocalizedString:@"LVL_HIGH"];
        [riskLevelValue setBackgroundColor:[UIColor colorWithRed:247.0/255 green:142.0/255 blue:1.0/255 alpha:1]];
    } else if([heatLevel isEqualToString:@"moderate"]) {
        riskLevelValue.text = [Language getLocalizedString:@"LVL_MODERATE"];
        [riskLevelValue setBackgroundColor:[UIColor colorWithRed:254.0/255 green:211.0/255 blue:156.0/255 alpha:1]];
    } else if([heatLevel isEqualToString:@"lower"]) {
        riskLevelValue.text = [Language getLocalizedString:@"LVL_LOWER"];
        [riskLevelValue setBackgroundColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:0/255 alpha:1]];
    } else {
        riskLevelValue.text = [Language getLocalizedString:@"LVL_LOWER"];
        [riskLevelValue setBackgroundColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:0/255 alpha:1]];
    }
}

- (void)calculateHeatIndex:(float)temperature withHumidity:(float)humidity {
    NSLog(@"[calculateHeatIndex] temperature: %f, humidity: %f", temperature, humidity);
    
    BOOL errors = FALSE;
    
    temperatureField.text = [NSString stringWithFormat:@"%.1f", temperature];
    humidityField.text = [NSString stringWithFormat:@"%.1f", humidity];
    
    if(temperature == 0 && humidity == 0) {
        [self alertBox:[Language getLocalizedString:@"ERROR"] withMessage:[Language getLocalizedString:@"ALERT_TEMP_EMPTY"] andLabel:[Language getLocalizedString:@"OK"]];
        errors = TRUE;
    } else if(temperature == 0) {
        [self alertBox:[Language getLocalizedString:@"ERROR"] withMessage:[Language getLocalizedString:@"ALERT_TEMP_EMPTY"] andLabel:[Language getLocalizedString:@"OK"]];
        errors = TRUE;
    } else if(humidity == 0) {
        [self alertBox:[Language getLocalizedString:@"ERROR"] withMessage:[Language getLocalizedString:@"ALERT_HUMID_EMPTY"] andLabel:[Language getLocalizedString:@"OK"]];
        errors = TRUE;
    }
    
    if(temperature > 0 && humidity > 0) {
        if(temperature < 80) {
            [self alertBox:[Language getLocalizedString:@"ALERT"] withMessage:[Language getLocalizedString:@"TEMP_UNDER_80"] andLabel:[Language getLocalizedString:@"OK"]];
            errors = TRUE;
        } else if(humidity > 100) {
            [self alertBox:[Language getLocalizedString:@"ALERT"] withMessage:[Language getLocalizedString:@"HUMID_OVER_100"] andLabel:[Language getLocalizedString:@"OK"]];
            errors = TRUE;
        }
        
        [self updateHeatLevel:[self getHeatIndex:temperature withHumidity:humidity]];
        precautionsBtn.enabled = true;
        
        if(errors) {
            noaaTime.text = @"";
            //riskLevelValue.text = @"";
            heatIndexValue.text = @"";
            //[riskLevelValue setBackgroundColor:[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1]];
        }
    }
}

- (float)getHeatIndex:(float)temp withHumidity:(float)humidity {
    
    NSLog(@"[getHeatIndex] temp: %f, humidity: %f", temp, humidity);
    
    float hIndex = 
    -42.379 + 2.04901523 * temp 
    + 10.14333127 * humidity 
    - 0.22475541 * temp * humidity 
    - 6.83783 * pow(10, -3) * temp * temp 
    - 5.481717 * pow(10, -2) * humidity * humidity 
    + 1.22874 * pow(10, -3) * temp * temp * humidity 
    + 8.5282 * pow(10, -4) * temp * humidity * humidity 
    - 1.99 * pow(10, -6) * temp * temp * humidity * humidity;
    
    //hIndex = round(hIndex);
    NSLog(@"-Heat Index: %f", hIndex);
    return hIndex;
}

- (void)getCurrentHeatIndex {
    [self getNOAAData];
    
    noaaTime.text = @"";
    
    for(id obj in validIndexes) {
        NSInteger tmpHour = [[[_time objectAtIndex:[obj integerValue]] substringWithRange:NSMakeRange(11, 2)] integerValue];
        if(hour == tmpHour) {
            NSString *time = [_time objectAtIndex:[obj integerValue]];
            float temperature = [[_temperature objectAtIndex:[obj integerValue]] floatValue];
            float humidity = [[_humidity objectAtIndex:[obj integerValue]] floatValue];
            
            NSLog(@"time: %@", time);
            
            NSString *ampm = nil;
            
            if(tmpHour < 12) { 
                ampm = @"am"; 
            } else { 
                if(tmpHour > 12) {
                    tmpHour = (tmpHour - 12);
                }
                ampm = @"pm";
            }
            
            noaaHour = tmpHour;
            noaaAMPM = ampm;
            noaaTime.text = [NSString stringWithFormat:[Language getLocalizedString:@"NOAA_TIME"], noaaHour, noaaAMPM];
            
            [self calculateHeatIndex:temperature withHumidity:humidity];
            break;
        }
    }
}

- (void)getMaxHeatIndex {
    [self getNOAAData];
    
    noaaTime.text = @"";
    
    float tmpHeatIndex = 0;
    float tmpMaxHeatIndex = 0;
    float tmpTemperature = 0;
    float tmpHumidity = 0;
    
    for(id obj in validIndexes) {
        NSInteger tmpHour = [[[_time objectAtIndex:[obj integerValue]] substringWithRange:NSMakeRange(11, 2)] integerValue];
        if(tmpHour > hour) {
            NSLog(@"getMaxHeatIndex - Hour %ld", (long)tmpHour);
            float temperature = [[_temperature objectAtIndex:[obj integerValue]] floatValue];
            float humidity = [[_humidity objectAtIndex:[obj integerValue]] floatValue];
            tmpHeatIndex = [self getHeatIndex:temperature withHumidity:humidity];
            if(tmpHeatIndex > tmpMaxHeatIndex)
            {
                tmpMaxHeatIndex = tmpHeatIndex;
                tmpTemperature = temperature;
                tmpHumidity = humidity;
                
                NSString *ampm = nil;

                if(tmpHour < 12) { 
                    ampm = @"am"; 
                } else { 
                    if(tmpHour > 12) {
                        tmpHour = (tmpHour - 12); 
                    }
                    ampm = @"pm";
                }
                
                noaaHour = tmpHour;
                noaaAMPM = ampm;
                noaaTime.text = [NSString stringWithFormat:[Language getLocalizedString:@"NOAA_TIME"], noaaHour, noaaAMPM];
            }
        }
    }
    
    if(tmpTemperature < 80.0) {
        noaaTime.text = @"";
        [self getCurrentHeatIndex];
        return;
    }
    
    NSLog(@"tmpMaxHeatIndex: %f", tmpMaxHeatIndex);
    //[self updateHeatLevel:tmpMaxHeatIndex];
    [self calculateHeatIndex:tmpTemperature withHumidity:tmpHumidity];
}

#pragma mark - NOAA Methods

- (void)getNOAAData {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Process request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:noaaURL, curLat, curLon]]];
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSLog(@"NSURLRequest request: %@", request.URL);
    
    // Parse the XML Data
    _xmlDictionary = [XMLReader dictionaryForXMLData:xmlData error:&error];
    
    //
    // Pull in relevent information, clean data, then parse (very involved..)
    //
    
    // get temperature data (ex: 73)
    //Ilya 6/13/14 changed 0 to 2 to get the hourly instead of the dew point
    NSDictionary *_tempDict = [_xmlDictionary retrieveForPath:[NSString stringWithFormat:@"dwml.data.parameters.temperature.%d", 2]];
    
    if(_tempDict == nil) {
        [self alertBox:[Language getLocalizedString:@"NOTICE"] withMessage:[Language getLocalizedString:@"NOAA_UNAVAILABLE"] andLabel:[Language getLocalizedString:@"OK"]];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        return;
    }
    
    NSMutableArray *_temp2 = [NSMutableArray arrayWithArray:[_tempDict allValues]];[_temp2 removeObjectAtIndex:0];[_temp2 removeObjectAtIndex:0];
    _temperature = [NSMutableArray arrayWithArray:[_temp2 objectAtIndex:0]];
    
    // get humidity data (ex: 84)
    NSDictionary *_humidityDict = [_xmlDictionary retrieveForPath:[NSString stringWithFormat:@"dwml.data.parameters.humidity", nil]];
    NSMutableArray *_humidity2 = [NSMutableArray arrayWithArray:[_humidityDict allValues]];

    //Ilya 6/16/14 added try/catch statement to account for 64bit architecture
    @try {
        _humidity = [NSMutableArray arrayWithArray:[_humidity2 objectAtIndex:0]];
    }
    @catch (NSException * e) {
        _humidity = [NSMutableArray arrayWithArray:[_humidity2 objectAtIndex:1]];
    }
    
    // get time data (ex: 2011-08-10T10:00:00-04:00)
    _time = [_xmlDictionary retrieveForPath:@"dwml.data.time-layout.start-valid-time"];
    
    // Get current date
    NSDate* now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit| NSSecondCalendarUnit) fromDate:now];
    day = [dateComponents day];
    hour = [dateComponents hour];
    min = [dateComponents minute];
    
    validIndexes = [[NSMutableArray alloc] init];
    
    //if(min > 30) hour++;
    hour++;
    
    int curID = 0;
    for(id object in _time) {
        NSInteger tmpDay = [[object substringWithRange:NSMakeRange(8, 2)] integerValue];
        if(tmpDay == day) {
            [validIndexes addObject:[NSNumber numberWithInteger:curID]];
        }
        ++curID;
    }
    
    NSLog(@"Date %@", [NSString stringWithFormat:@"Day: %ld, Hour: %ld", (long)day, (long)hour]);
    
    //NSLog(@"_time: %@", _time);
    //NSLog(@"_temperature: %@", _temperature);
    //NSLog(@"_humidity: %@", _humidity);
    //NSLog(@"validIndexes: %@", validIndexes);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - UI Methods

- (void)redrawApp {
    
    [calculateBtn setTitle:[Language getLocalizedString:@"CALCULATE"] forState:UIControlStateNormal];
    [precautionsBtn setTitle:[Language getLocalizedString:@"PRECAUTIONS"] forState:UIControlStateNormal];
    [getCurrentBtn setTitle:[Language getLocalizedString:@"GET_CURRENT"] forState:UIControlStateNormal];
    [getTodayMaxBtn setTitle:[Language getLocalizedString:@"GET_TODAY_MAX"] forState:UIControlStateNormal];
    
    [temperatureLabel setText:[Language getLocalizedString:@"TEMPERATURE"]];
    [humidityLabel setText:[Language getLocalizedString:@"HUMIDITY"]];
    
    [heatIndexLabel setText:[Language getLocalizedString:@"HEAT_INDEX"]];
    [riskLevelLabel setText:[Language getLocalizedString:@"RISK_LEVEL"]];
    
    if(heatLevel != nil) {
        if([heatLevel isEqualToString:@"extreme"]) {
            riskLevelValue.text = [Language getLocalizedString:@"LVL_EXTREME"];
        } else if([heatLevel isEqualToString:@"high"]) {
            riskLevelValue.text = [Language getLocalizedString:@"LVL_HIGH"];
        } else if([heatLevel isEqualToString:@"moderate"]) {
            riskLevelValue.text = [Language getLocalizedString:@"LVL_MODERATE"];
        } else if([heatLevel isEqualToString:@"lower"]) {
            riskLevelValue.text = [Language getLocalizedString:@"LVL_LOWER"];
        }
    }
    
    // Time
    if(noaaAMPM != nil) {
        noaaTime.text = [NSString stringWithFormat:[Language getLocalizedString:@"NOAA_TIME"], noaaHour, noaaAMPM];
    }
    
    masthead.image = [UIImage imageNamed:[Language getLocalizedString:@"MASTHEAD"]];
}

- (void)hideKeyboard {
    // Hide keyboard!
    [temperatureField resignFirstResponder];
    [humidityField resignFirstResponder];
}

- (void)alertBox:(NSString *)title withMessage:(NSString *)message andLabel:(NSString *)buttonLabel {
    NSString *errorTitle = title;
    NSString *errorString = message;
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:errorTitle message:errorString delegate:self cancelButtonTitle:nil otherButtonTitles:buttonLabel, nil];
    [errorView show];
    [errorView autorelease];
}

- (void)viewDidUnload
{
    [self setLocationManager:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [calculateBtn release];
    [getCurrentBtn release];
    [getTodayMaxBtn release];
    [precautionsBtn release];
    [heatIndexLabel release];
    [riskLevelLabel release];
    [temperatureLabel release];
    [humidityLabel release];
    [heatIndexValue release];
    [riskLevelValue release];
    [temperatureField release];
    [humidityField release];
    [noaaTime release];
    [locationManager release];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self hideKeyboard];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
    if(interfaceOrientation == UIInterfaceOrientationPortrait) {
        [scrollView setContentSize:CGSizeMake(0, scrollView.frame.size.height)];
    } else if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, (scrollView.frame.size.height - 65))];
    }
    
    return YES;
} 

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [locationManager release];
    [super dealloc];
}

@end