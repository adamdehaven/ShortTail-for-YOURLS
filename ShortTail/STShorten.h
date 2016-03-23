/* ==========================================================
 * STShorten.h
 * ShortTail for YOURLS v1.6.5
 * https://github.com/adamdehaven/ShortTail
 *
 * Author: Adam DeHaven ( Twitter, GitHub: @adamdehaven )
 * http://adamdehaven.com/
 *
 *
 * Copyright (c) 2016 Adam Dehaven. All rights reserved.
 * ========================================================== */

#import <Foundation/Foundation.h>

@interface STShorten : NSObject

+ (void)shortenURL:(NSString *)shortURL customKeyword:(NSString *)keywordForURL customTitle:(NSString *)titleForURL withCallback:(void (^)(NSString *error, NSString *errorTag, NSString *urlKeyword, NSString *urlTitle))callback;

@end
