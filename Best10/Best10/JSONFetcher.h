//
//  JSONFetcher.h
//  Best10
//
//  Created by Francois Chaubard on 12/28/13.
//  Copyright (c) 2013 Chaubard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONFetcher : NSObject

+ (NSArray *)pullFriendsData;
+ (NSArray *)pullChatData;
+ (NSString*) escapeUnicodeString:(NSString*)string;
+ (NSString*) unescapeUnicodeString:(NSString*)string;

@end
