//
//  Friend.h
//  Best10
//
//  Created by Francois Chaubard on 12/30/13.
//  Copyright (c) 2013 Chaubard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friend : NSManagedObject

@property (nonatomic, retain) NSNumber * friendStatus;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * pictureURL;
@property (nonatomic, retain) NSNumber * sessionID;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSNumber * userID;

@end
