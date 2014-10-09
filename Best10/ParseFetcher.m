//
//  ParseFetcher.m
//  Best10
//
//  Created by Francois Chaubard on 10/7/14.
//  Copyright (c) 2014 Chaubard. All rights reserved.
//

#import "ParseFetcher.h"
#import "AppDelegate.h"
#import "MyCLLocationManager.h"
@implementation ParseFetcher


- (id)init {
    self = [super init];
    
    if(self) {
        self.parseFetcher = [ParseFetcher new];
    }
    
    return self;
}

+ (ParseFetcher*)sharedSingleton {
    static ParseFetcher* sharedSingleton;
    if(!sharedSingleton) {
        @synchronized(sharedSingleton) {
            sharedSingleton = [ParseFetcher new];
        }
    }
    
    return sharedSingleton;
}


+ (NSString*) unescapeUnicodeString:(NSString*)string
{
    // unescape quotes and backwards slash
    NSString* firstUnescapedString = [string stringByReplacingOccurrencesOfString:@"__!__u" withString:@"\\u"];
    
    NSString* unescapedString = [firstUnescapedString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    unescapedString = [unescapedString stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    
    // tokenize based on unicode escape char
    NSMutableString* tokenizedString = [NSMutableString string];
    NSScanner* scanner = [NSScanner scannerWithString:unescapedString];
    while ([scanner isAtEnd] == NO)
    {
        // read up to the first unicode marker
        // if a string has been scanned, it's a token
        // and should be appended to the tokenized string
        NSString* token = @"";
        [scanner scanUpToString:@"\\u" intoString:&token];
        if (token != nil && token.length > 0)
        {
            [tokenizedString appendString:token];
            continue;
        }
        
        // skip two characters to get past the marker
        // check if the range of unicode characters is
        // beyond the end of the string (could be malformed)
        // and if it is, move the scanner to the end
        // and skip this token
        NSUInteger location = [scanner scanLocation];
        NSInteger extra = scanner.string.length - location - 4 - 2;
        if (extra < 0)
        {
            NSRange range = {location, -extra};
            [tokenizedString appendString:[scanner.string substringWithRange:range]];
            [scanner setScanLocation:location - extra];
            continue;
        }
        
        // move the location pas the unicode marker
        // then read in the next 4 characters
        location += 2;
        NSRange range = {location, 4};
        token = [scanner.string substringWithRange:range];
        unichar codeValue = (unichar) strtol([token UTF8String], NULL, 16);
        [tokenizedString appendString:[NSString stringWithFormat:@"%C", codeValue]];
        
        // move the scanner past the 4 characters
        // then keep scanning
        location += 4;
        [scanner setScanLocation:location];
    }
    
    // done
    return tokenizedString;
}

+ (NSString*) escapeUnicodeString:(NSString*)string
{
    // lastly escaped quotes and back slash
    // note that the backslash has to be escaped before the quote
    // otherwise it will end up with an extra backslash
    NSString* escapedString = [string stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    // convert to encoded unicode
    // do this by getting the data for the string
    // in UTF16 little endian (for network byte order)
    NSData* data = [escapedString dataUsingEncoding:NSUTF16LittleEndianStringEncoding allowLossyConversion:YES];
    size_t bytesRead = 0;
    const char* bytes = data.bytes;
    NSMutableString* encodedString = [NSMutableString string];
    
    // loop through the byte array
    // read two bytes at a time, if the bytes
    // are above a certain value they are unicode
    // otherwise the bytes are ASCII characters
    // the %C format will write the character value of bytes
    while (bytesRead < data.length)
    {
        uint16_t code = *((uint16_t*) &bytes[bytesRead]);
        if (code > 0x007E)
        {
            [encodedString appendFormat:@"\\u%04X", code];
        }
        else
        {
            [encodedString appendFormat:@"%C", code];
        }
        bytesRead += sizeof(uint16_t);
    }
    
    
    NSString* finalEncodedString = [encodedString stringByReplacingOccurrencesOfString:@"\\u" withString:@"__!__u"];
    
    // done
    return finalEncodedString;
}




- (BOOL)updateFriends:(void (^)(NSArray *objects, NSError*))block{
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"asdadf" equalTo:@"asdfasd"];
    
    
    [query findObjectsInBackgroundWithBlock:block];
    
    // block should contain...
    /*if (!error) {
     // The find succeeded.
     NSLog(@"Successfully retrieved %d scores.", objects.count);
     
     } else {
     // Log details of the failure
     NSLog(@"Error: %@ %@", error, [error userInfo]);
     }*/
    
    
    return true;
}

- (BOOL)updateChat:(NSString *)friendID{
    
    
    return true;
}

- (void)updateUserStatus:(NSUInteger)gerundNumber{
    PFUser *pf = [PFUser currentUser];
    
    // set users status
    NSString *gerund = [[(AppDelegate*)[UIApplication sharedApplication].delegate getGerunds] objectAtIndex:gerundNumber];
    [pf setObject:gerund forKey:@"status"];
    
    
    // set the users current location
    CLLocation *location = [MyCLLocationManager sharedSingleton].locationManager.location;
    CLLocationCoordinate2D coordinate = [location coordinate];
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude
                                                  longitude:coordinate.longitude];
    
    [pf setObject:geoPoint forKey:@"location"];
    
    // save this
    [pf saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        return;
        
    }];
}




@end
