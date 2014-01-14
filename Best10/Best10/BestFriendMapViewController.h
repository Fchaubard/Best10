//
//  WolfMapViewController.h
//  WolfPack
//
//  Created by Francois Chaubard on 3/1/13.
//  Copyright (c) 2013 Francois Chaubard. All rights reserved.
//

#import "MapViewController.h"
#import "WYPopoverController.h"
#import <UIKit/UIKit.h>


@interface BestFriendMapViewController : MapViewController <WYPopoverControllerDelegate>



@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;
@property (strong, nonatomic) IBOutlet UIButton *viewWolfPackButton;
@property (strong, nonatomic) IBOutlet UIButton *viewCurrentLocationButton;
@property (strong, nonatomic) IBOutlet UIButton *chatButton;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) WYPopoverController *popover;
@property (strong, nonatomic) IBOutlet UIButton *adjectiveButton;
@property (strong, nonatomic) IBOutlet UIView *headerUIView;



-(void)selectedTableRow:(NSUInteger)rowNum;
- (IBAction)viewCurrentLocation:(UIButton *)sender;

@end
