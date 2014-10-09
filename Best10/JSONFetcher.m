//
//  JSONFetcher.m
//  Best10
//
//  Created by Francois Chaubard on 12/28/13.
//  Copyright (c) 2013 Chaubard. All rights reserved.
//

#import "JSONFetcher.h"
#import "AppDelegate.h"


#define FRIEND_PHONE_NUMBER @"phone"


typedef enum {
	FlickrPhotoFormatSquare = 1,
	FlickrPhotoFormatLarge = 2,
	FlickrPhotoFormatOriginal = 64
} FlickrPhotoFormat;


@implementation JSONFetcher

+ (NSArray *)pullFriendsData{
    
    
        
    NSString *sessionid =[(AppDelegate *)[UIApplication sharedApplication].delegate getUserToken];
    NSString *str = [NSString stringWithFormat:@"http://busbookie.com/serverlets/getmywolfpackjson.php?session=%@",sessionid];
    NSURL *URL = [NSURL URLWithString:str];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    //request.HTTPMethod = @"POST";
    
    //NSString *params = @"access_token=asdf&action_name=get_apptracker_info";
    
    //NSData *data = [params dataUsingEncoding:NSUTF8StringEncoding];
    //[request addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    //[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //[request addValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-Length"];
    //[request setHTTPBody:data];
    //NSError *error = [[NSError alloc] init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:responseData
                          encoding:NSUTF8StringEncoding];
    
    
    NSLog(@"JSON response: %@",jsonString);
    NSArray *jsonArray;
    NSError *e;
    // if ([NSJSONSerialization isValidJSONObject:responseData]) {
    if ([jsonString length]>1){
        jsonArray = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&e];
        if (jsonArray == Nil) {
            NSLog(@"%@",e);
        }
        for (NSMutableDictionary *dict in jsonArray) {
            NSLog(@"%@", [dict allKeys]);
            NSLog(@"%@", [dict allValues]);
            
        }
        return jsonArray;
    }
    else{
        return nil;
    }
}

+ (void)updateUserStatus:(NSUInteger)gerundNumber{
    
    
    dispatch_queue_t fetchQ = dispatch_queue_create("Update Status", NULL);
    dispatch_async(fetchQ, ^{
        
        CLLocation *loc = [(AppDelegate *)[UIApplication sharedApplication].delegate getUserCurrentLocation];
        
        NSString *sessionid =[(AppDelegate *)[UIApplication sharedApplication].delegate getUserToken];
        
        NSString *status =
        [JSONFetcher escapeUnicodeString:[NSString stringWithFormat:@"%@",
                                          [[(AppDelegate *)[UIApplication sharedApplication].delegate getGerunds] objectAtIndex:gerundNumber]] ];
        
        //NSString *strippedStatus = [status stringByReplacingOccurrencesOfString:@" " withString:@"!!_____!_____!!"];
        NSString *str = [NSString stringWithFormat:@"http://busbookie.com/serverlets/updatemystatusjson.php?session=%@&adjective=%d&lat=%f&long=%f&status=%@&statusUpdate=%@",sessionid,0,loc.coordinate.latitude,loc.coordinate.longitude,status,@"idk"];
        //str = [str stringByReplacingOccurrencesOfString:@" " withString:@"!!_____!_____!!"];
        str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@",str);
        NSURL *URL = [NSURL URLWithString:str];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        //NSError *error = [[NSError alloc] init];
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        NSString * string = [[NSString alloc] initWithData:responseData encoding:
                             NSASCIIStringEncoding];
        
        
        
        if (string.intValue == 1) {
            NSLog(@"asdfa");
        } else {
            NSLog(@"asdfaasd");
        }
        
        /*dispatch_async(dispatch_get_main_queue(), ^ {
         
         [SVProgressHUD dismiss];
         int64_t delayInSeconds = 0.6;
         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
         
         [self.mapViewController refreshWithoutHUD];
         [self.mapViewController updateRegion:@2]; // slinky thing
         });
         
         });
         */
        
        
    });
    return;
}

+ (NSArray *)pullChatData{
    return nil;
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


@end
