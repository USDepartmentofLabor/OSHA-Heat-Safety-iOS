//
//  MoreInfo.h
//  Heat Tool
//
//  Created by mkeefe on 9/10/11.
//  Copyright 2011 PixelBit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreInfo : UIViewController <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate> {
    IBOutlet UITableView *tblMoreInfo;
    NSArray *tableRows;
    IBOutlet UITableViewCell *cellOne;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *cellOne;

@end
