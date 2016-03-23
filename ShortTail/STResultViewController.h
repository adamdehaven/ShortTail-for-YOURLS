/* ==========================================================
 * STResultViewController.h
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
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface STResultViewController : GAITrackedViewController <MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet UITextField *shortenedURLField;
@property (strong, nonatomic) NSString *shareTitle;
@property (strong, nonatomic) NSString *shortenedURL;
@property (strong, nonatomic) NSString *resultLongURL;
@property (nonatomic, strong) IBOutlet UILabel *urlLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property(nonatomic,getter=isToolbarHidden) BOOL toolbarHidden;
@property (nonatomic, strong) IBOutlet UIButton *circleCopyButton;
@property (nonatomic, strong) IBOutlet UIButton *circleOpenButton;
@property (nonatomic, strong) IBOutlet UIButton *circleShareButton;
@property (nonatomic, strong) IBOutlet UIImageView *yourlsLogo;
@property (nonatomic, strong) IBOutlet UILabel *poweredBy;

@end
