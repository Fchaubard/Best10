//
//  ParseFetcher.h
//  Best10
//
//  Created by Francois Chaubard on 10/7/14.
//  Copyright (c) 2014 Chaubard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseFetcher : NSObject

@property (nonatomic, strong) ParseFetcher * parseFetcher;



+ (ParseFetcher*)sharedSingleton;
+ (NSString*) escapeUnicodeString:(NSString*)string;
+ (NSString*) unescapeUnicodeString:(NSString*)string;

- (BOOL)updateFriends:(void (^)(NSArray*, NSError*))block;
- (BOOL)updateChat:(NSString *)friendID;
- (void)updateUserStatus:(NSUInteger)gerundNumber;

@end
