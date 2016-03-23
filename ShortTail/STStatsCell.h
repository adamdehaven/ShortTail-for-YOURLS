/* ==========================================================
 * STStatsCell.h
 * ShortTail for YOURLS v1.6.5
 * https://github.com/adamdehaven/ShortTail
 *
 * Author: Adam DeHaven ( Twitter, GitHub: @adamdehaven )
 * http://adamdehaven.com/
 *
 *
 * Copyright (c) 2016 Adam Dehaven. All rights reserved.
 * ========================================================== */

#import <UIKit/UIKit.h>

@interface STStatsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *yourlsLinkTitle;
@property (weak, nonatomic) IBOutlet UILabel *yourlsKeyword;
@property (weak, nonatomic) IBOutlet UILabel *yourlsShortUrl;
@property (weak, nonatomic) IBOutlet UILabel *yourlsLongUrl;
@property (weak, nonatomic) IBOutlet UILabel *yourlsClicks;

@end
