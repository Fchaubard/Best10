//
//  PopoverTVC.h
//  WolfPack
//
//  Created by Francois Chaubard on 5/25/13.
//  Copyright (c) 2013 Francois Chaubard. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BestFriendMapViewController;

@interface PopoverTVC : UITableViewController

@property (strong,nonatomic) NSArray *adjectives;
@property(nonatomic,assign) BestFriendMapViewController *delegate;

@end
