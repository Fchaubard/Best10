//
//  SideBarMenuTableViewController.m
//  Best10
//
//  Created by Francois Chaubard on 12/27/13.
//  Copyright (c) 2013 Chaubard. All rights reserved.
//
#import "AppDelegate.h"

#import "SideBarMenuTableViewController.h"
#import "BestFriendMapViewController.h"
#import "FriendRequestTVC.h"
#import "BestFriendListCDTVC.h"
#import "MyGerundListTVC.h"
#import "SettingsViewController.h"
#import "SendFeedbackViewController.h"
#import "ChatViewController.h"

#import "MSMenuTableViewHeader.h"
#import "MSMenuCell.h"
#import "OrderedDictionary.h"

NSString * const MSMenuCellReuseIdentifier = @"Drawer Cell";
NSString * const MSDrawerHeaderReuseIdentifier = @"Drawer Header";

@interface SideBarMenuTableViewController ()

@property (nonatomic,retain) OrderedDictionary *titlesClassesDictionary;

@end

@implementation SideBarMenuTableViewController


- (void)initialize
{
    
  
    
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    /*@{
     @"Home Map":[BestFriendMapViewController class],
     @"Friend Requests":[FriendRequestTVC class],
     @"My Best Friends":[BestFriendMapViewController class],
     @"My Gerunds":[MyGerundListTVC class],
     @"Settings":[SettingsViewController class],
     @"Send Feedback":[SendFeedbackViewController class]
     }*/
    
    self.titlesClassesDictionary = [[OrderedDictionary alloc] init];
    
    [self.titlesClassesDictionary
     insertObject:[BestFriendMapViewController class]
     forKey:@"Home Map"];
    
    [self.titlesClassesDictionary
     insertObject:[FriendRequestTVC class]
     forKey:@"Friend Requests"];
    
    [self.titlesClassesDictionary
     insertObject:[ChatViewController class]
     forKey:@"Chat"];
    
    [self.titlesClassesDictionary
     insertObject:[BestFriendListCDTVC class]
     forKey:@"My Best Friends"];
    
    [self.titlesClassesDictionary
     insertObject:[MyGerundListTVC class]
     forKey:@"My Activities"];
    
    [self.titlesClassesDictionary
     insertObject:[SettingsViewController class]
     forKey:@"Settings"];
    
    [self.titlesClassesDictionary
     insertObject:[SendFeedbackViewController class]
     forKey:@"Send Feedback"];
    
    
    [self.tableView registerClass:[MSMenuCell class] forCellReuseIdentifier:MSMenuCellReuseIdentifier];
    [self.tableView registerClass:[MSMenuTableViewHeader class] forHeaderFooterViewReuseIdentifier:MSDrawerHeaderReuseIdentifier];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    
    [self.tableView addSubview:self.windowBackground];
    [self.tableView sendSubviewToBack:self.windowBackground];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    return;
}

#pragma mark - MSAppDelegate
UIImageView *windowBackground;

- (UIImageView *)windowBackground
{
    if (!windowBackground) {
        windowBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Window Background"]];
    }
    return windowBackground;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return [self.titlesClassesDictionary count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:MSDrawerHeaderReuseIdentifier];
    headerView.textLabel.text = @"";
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new]; // Hacky way to prevent extra dividers after the end of the table from showing
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN; // Hacky way to prevent extra dividers after the end of the table from showing
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSMenuCellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MSMenuCellReuseIdentifier];
    }

    cell.textLabel.text = [self.titlesClassesDictionary  keyAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self transitionToNewViewController:[self.titlesClassesDictionary keyAtIndex:indexPath.row]];
    
    // Prevent visual display bug with cell dividers
    /*[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView reloadData];
    });*/
}


-(void)transitionToNewViewController:(NSString *)newRootViewControllerName{
    
    [[(AppDelegate *)[UIApplication sharedApplication].delegate getSidebarVC]
     transitionToNewViewController:newRootViewControllerName];
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
