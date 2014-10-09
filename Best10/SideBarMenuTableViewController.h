//
//  SideBarMenuTableViewController.h
//  Best10
//
//  Created by Francois Chaubard on 12/27/13.
//  Copyright (c) 2013 Chaubard. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OrderedDictionary.h"

@interface SideBarMenuTableViewController : UITableViewController  <UIActionSheetDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet PFImageView *imageUser;
@property (nonatomic,retain) OrderedDictionary *titlesClassesDictionary;

@end
