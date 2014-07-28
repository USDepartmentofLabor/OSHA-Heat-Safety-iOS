//
//  heatappAppDelegate.h
//  heatapp
//
//  Created by mkeefe on 9/9/11.
//  
//

#import <UIKit/UIKit.h>

@interface heatappAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    IBOutlet UITabBarItem *tabOne;
    IBOutlet UITabBarItem *tabTwo;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UITabBarItem *tabOne;
@property (nonatomic, retain) IBOutlet UITabBarItem *tabTwo;

@end
