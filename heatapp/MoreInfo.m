//
//  MoreInfo.m
//  Heat Tool
//
//  Created by mkeefe on 9/10/11.
//  
//

#import "SecondaryView.h"
#import "MoreInfo.h"
#import "Language.h"
#import <QuartzCore/QuartzCore.h>

@implementation MoreInfo

@synthesize cellOne;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self setTitle:[Language getLocalizedString:@"MORE_INFO"]];
    
    if([[Language getLanguage] isEqualToString:@"en"]) {
        tableRows = [[NSArray alloc] initWithObjects:@"Signs and Symptoms", @"First Aid", @"More Detail", @"Contact OSHA", @"About This App", nil];
    } else if([[Language getLanguage] isEqualToString:@"es"]) {
        tableRows = [[NSArray alloc] initWithObjects:@"Signos y Síntomas", @"Primeros Auxilios", @"Más Detalles", @"Contacte a OSHA", @"Sobre la aplicación", nil];
    }
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
} 

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableRows count];
}

//MyIdentifier

// Customize the appearance
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"MoreInfoCell" owner:self options:nil];
        cell = cellOne;
        self.cellOne = nil;
    }
    
    NSString *title = [tableRows objectAtIndex:indexPath.row];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:0];
    label.text = title;
    
    if([title  isEqualToString:@"Signs and Symptoms"] || [title isEqualToString:@"Signos y Síntomas"]) {
        cell.imageView.image = [UIImage imageNamed:@"moreinfo_signs.png"];
    } else if([title  isEqualToString:@"First Aid"] || [title isEqualToString:@"Primeros Auxilios"]) {
        cell.imageView.image = [UIImage imageNamed:@"moreinfo_firstAid.png"];
    } else if([title isEqualToString:@"More Detail"] || [title  isEqual: @"Más Detalles"]) {
        cell.imageView.image = [UIImage imageNamed:@"moreinfo_more.png"];
    } else if([title  isEqualToString:@"Contact OSHA"] || [title isEqualToString:@"Contacte a OSHA"]) {
        cell.imageView.image = [UIImage imageNamed:@"moreinfo_contact.png"];
    } else if([title  isEqualToString:@"About This App"] || [title isEqualToString:@"Sobre la aplicación" ]) {
        cell.imageView.image = [UIImage imageNamed:@"moreinfo_about.png"];
    }
    
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 5.0;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SecondaryView* subView = [[SecondaryView alloc] initWithNibName:@"SecondaryView" bundle:nil];
    //[self.view addSubview:subView.view];
    //subView.view.frame = self.view.bounds;
    
    [self.navigationController pushViewController:subView animated:YES];
    
    NSString *title = [tableRows objectAtIndex:indexPath.row];
    
    if([title  isEqualToString:@"Signs and Symptoms"] || [title isEqualToString:@"Signos y Síntomas"]) {
        [subView displayPage:@"Signs and Symptoms"];
    } else if([title isEqualToString:@"First Aid"] || [title  isEqualToString:@"Primeros Auxilios"]) {
        [subView displayPage:@"First Aid"];
    } else if([title  isEqualToString:@"More Detail"] || [title isEqualToString:@"Más Detalles"]) {
        [subView displayPage:@"More Detail"];
    } else if([title  isEqualToString:@"Contact OSHA"] || [title isEqualToString:@"Contacte a OSHA"]) {
        [subView displayPage:@"Contact OSHA"];
    } else if([title isEqualToString:@"About This App"] || [title  isEqualToString:@"Sobre la aplicación"]) {
        [subView displayPage:@"About This App"];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

@end
