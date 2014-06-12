//
//  ChatViewController.h
//  Best10
//
//  Created by Francois Chaubard on 12/28/13.
//  Copyright (c) 2013 Chaubard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSMessagesViewController.h"
#import "Friend+MKAnnotation.h"
@interface ChatViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *timestamps;
@property (strong, nonatomic) NSMutableArray *subtitles;
@property (strong, nonatomic) NSDictionary *avatars;
@property (strong, nonatomic) Friend *friend;

@end
