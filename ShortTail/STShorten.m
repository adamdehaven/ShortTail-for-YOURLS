/* ==========================================================
 * STShorten.m
 * ShortTail for YOURLS v1.6.5
 * https://github.com/adamdehaven/ShortTail
 *
 * Author: Adam DeHaven ( Twitter, GitHub: @adamdehaven )
 * http://adamdehaven.com/
 *
 *
 * Copyright (c) 2016 Adam Dehaven. All rights reserved.
 * ========================================================== */

#import "STShorten.h"

@implementation STShorten

+ (void)shortenURL:(NSString *)shortURL customKeyword:(NSString *)keywordForURL customTitle:(NSString *)titleForURL withCallback:(void (^)(NSString *error, NSString *errorTag, NSString *urlKeyword, NSString *urlTitle))callback {
    
    // apply all settings and configure into urlString
    
    NSUserDefaults *settings = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.adamdehaven.ShortTail"];
    NSString *urlProtocol = [settings stringForKey:@"savedProtocol"];
    NSString *baseURL = [settings stringForKey:@"savedBaseUrl"];
    NSString *signature = [settings stringForKey:@"savedSignature"];
    
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/yourls-api.php", urlProtocol, baseURL]];
    NSMutableURLRequest *apiRequest = [NSMutableURLRequest requestWithURL:apiURL];
    NSString *postData = [NSString stringWithFormat:@"signature=%@&action=shorturl&format=json&url=%@&keyword=%@&title=%@", signature, shortURL, keywordForURL, titleForURL];
    [apiRequest setHTTPMethod:@"POST"];
    [apiRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:apiRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            NSDictionary *API = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            // get the URL keyword, and errors if any
            NSString *statusMsg = API[@"status"];
            NSString *urlKeyword = API[@"url"][@"keyword"];
            NSString *urlTitle = API[@"url"][@"title"];
            NSString *resultCode = API[@"code"];
            
            if([statusMsg isEqualToString:@"success"] && urlKeyword) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // if successful
                    callback(nil, nil, urlKeyword, urlTitle);
                });
            } else if([statusMsg isEqualToString:@"fail"] && [resultCode isEqualToString:@"error:keyword"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // if short URL keyword already exists or is reserved
                    callback([NSString stringWithFormat:@"The keyword '%@' already exists or is reserved. Try something different.", keywordForURL], @"keywordExistsError", nil, nil);
                    NSLog(@"Keyword already exists.");
                });
             } else {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     callback(@"Something went wrong. Please check your settings.", nil, nil, nil);
                     NSLog(@"Fallback error.");
                 });
             }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(@"Something went wrong. Please check your settings.", nil, nil, nil);
                    NSLog(@"STShorten: %@", error.localizedDescription);
                });
            });
        }
    }] resume];
}

@end
