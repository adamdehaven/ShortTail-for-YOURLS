/* ==========================================================
 * STResultViewController.m
 * ShortTail for YOURLS v1.6.5
 * https://github.com/adamdehaven/ShortTail
 *
 * Author: Adam DeHaven ( Twitter, GitHub: @adamdehaven )
 * http://adamdehaven.com/
 *
 *
 * Copyright (c) 2016 Adam Dehaven. All rights reserved.
 * ========================================================== */

#import "STResultViewController.h"
#import "STStatsTableWebViewController.h"
#import "STViewController.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "iRate.h"

#define UIColorFromRGB(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

@interface STResultViewController () {
    NSUserDefaults *settings;
    UIColor *accentColor;
}

- (void)copyURL;
- (void)shareURL;

@end

@implementation STResultViewController

@synthesize resultView, shortenedURLField, shortenedURL, resultLongURL, circleCopyButton, circleOpenButton, circleShareButton, shareTitle, urlLabel, titleLabel, yourlsLogo, poweredBy;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    settings = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.adamdehaven.ShortTail"];
    
    shareTitle = [self.shareTitle stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
    
    [self setAccentColor];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [circleCopyButton setHidden:YES];
    [circleOpenButton setHidden:YES];
    [circleShareButton setHidden:YES];
    [yourlsLogo setHidden:YES];
    [poweredBy setHidden:YES];
    [urlLabel setHidden:YES];
    
    // Set Navigation bar title for this view to image
    //self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"squirrel"]];
    
    self.navigationItem.title = @"ShortTail";
	
    resultView.backgroundColor = accentColor;
    
    urlLabel.text = shortenedURL;
    urlLabel.backgroundColor = [UIColor clearColor];    
    shortenedURLField.text = [urlLabel.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@%@/", [settings stringForKey:@"savedProtocol"],[settings stringForKey:@"savedBaseUrl"]] withString:@""];
    
    [self performSelector:@selector(animateButtons:) withObject:circleCopyButton afterDelay:0.3];
    [self performSelector:@selector(animateButtons:) withObject:circleOpenButton afterDelay:0.6];
    [self performSelector:@selector(animateButtons:) withObject:circleShareButton afterDelay:0.9];
    [self performSelector:@selector(animateUrlLabel:) withObject:urlLabel afterDelay:1.2];
    [self performSelector:@selector(animateLabel:) withObject:poweredBy afterDelay:3.5];
    [self performSelector:@selector(animateLogo:) withObject:yourlsLogo afterDelay:3.5];
    
    // Subscribe to Notification, and perform 'handleDidBecomeActive'
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleDidBecomeActive:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    // Result Title
    //UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 118)];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    titleLabel.frame = CGRectMake(20, 20, screenBounds.size.width - 40, 118);
    titleLabel.numberOfLines = 4;
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0];
    titleLabel.layer.cornerRadius = 4;
    [titleLabel.layer setMasksToBounds:YES];
    titleLabel.textColor = UIColorFromRGB(0x34495E, 1.0);
    titleLabel.backgroundColor = [UIColor clearColor];
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:3.5];
    NSMutableAttributedString *titleLabelText = [[NSMutableAttributedString alloc] initWithString:shareTitle];
    [titleLabelText addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [titleLabelText length])];
    titleLabel.attributedText = titleLabelText;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    //[self.view addSubview:titleLabel];*/
}

-(void)viewWillAppear:(BOOL)animated {
    [self setAccentColor];
    [self setupUI];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.screenName = @"Result View"; // GA
}

- (void)setAccentColor {
    NSData *colorData = [settings objectForKey:@"accentColor"];
    accentColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
}
    
- (void)setupUI {
    // Navigation Bar Colors
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x34495e, 1.0);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    // Status Bar Color
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    shortenedURLField.tintColor = UIColorFromRGB(0x34495e, 1.0);
    shortenedURLField.textColor = UIColorFromRGB(0x34495e, 1.0);
    
    resultView.backgroundColor = accentColor;
}

-(void)animateButtons:(id)sender {
    UIButton *button = (UIButton *)sender;
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position" function:BackEaseInOut fromPoint:CGPointMake(button.center.x, button.center.y + screenSize.size.height) toPoint:button.center keyframeCount:120];
	animation.duration = 1.0;
    
	[button.layer addAnimation:animation forKey:@"easing"];
    [button setHidden:NO];
}

-(void)animateLogo:(id)sender {
    UIImageView *logo = (UIImageView *)sender;
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position" function:BackEaseInOut fromPoint:CGPointMake(logo.center.x, logo.center.y + screenSize.size.height) toPoint:logo.center keyframeCount:120];
	animation.duration = 1.0;
    
	[logo.layer addAnimation:animation forKey:@"easing"];
    [logo setHidden:NO];
}

-(void)animateLabel:(id)sender {
    UILabel *label = (UILabel *)sender;
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position" function:BackEaseInOut fromPoint:CGPointMake(label.center.x, label.center.y + screenSize.size.height) toPoint:label.center keyframeCount:120];
	animation.duration = 1.0;
    
	[label.layer addAnimation:animation forKey:@"easing"];
    [label setHidden:NO];
}

-(void)animateUrlLabel:(id)sender {
    UILabel *label = (UILabel *)sender;
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position" function:BackEaseInOut fromPoint:CGPointMake(label.center.x, label.center.y + screenSize.size.height) toPoint:label.center keyframeCount:120];
    animation.duration = 1.0;
    
    [label.layer addAnimation:animation forKey:@"easing"];
    [label setHidden:NO];
}

- (void)viewDidUnload {
    
    [self setShortenedURLField:nil];
    [self setResultView:nil];
    [self setShortenedURL:nil];
    [self setShareTitle:nil];
    [self setResultLongURL:nil];
    [super viewDidUnload];
}

- (void)copyURL {
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setURL:[NSURL URLWithString:shortenedURL]];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.color = UIColorFromRGB(0x34495e, 1.0);
    HUD.backgroundColor = UIColorFromRGB(0xffffff, 0.3);
    HUD.square = YES;
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
	HUD.labelText = @"Copied";
    HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    HUD.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
	HUD.removeFromSuperViewOnHide = YES;
    [HUD hide:YES afterDelay:1.5];
    
    // Log iRate event, and once threshold is reached, show iRate on next launch
    [[iRate sharedInstance] logEvent:YES];
}

- (IBAction)copyTextField {
    [self copyURL];
    
    /** GA Events **/
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"result_view" // Event category (required)
                                                          action:@"copy_url" // Event action (required)
                                                           label:@"copy_button" // Event label
                                                           value:nil] build]]; // Event value
}

- (IBAction)sendToWebView {
    /** GA Events **/
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"result_view" // Event category (required)
                                                          action:@"open_in_webView" // Event action (required)
                                                           label:@"open_button" // Event label
                                                           value:nil] build]]; // Event value
    
    [settings setObject:shortenedURL forKey:@"savedShortURL"];
    [settings synchronize];
    
    // Log iRate event, and once threshold is reached, show iRate on next launch
    [[iRate sharedInstance] logEvent:YES];
    
    [self performSegueWithIdentifier:@"resultsToWebView" sender:self];
}

- (void)shareURL {
    // Share URL
    NSArray *activityItems = nil;
    NSURL *shareShortTailURL = [NSURL URLWithString:shortenedURL];
    activityItems = @[shareTitle, shareShortTailURL];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    [activityController setValue:shareTitle forKey:@"subject"];
    
    activityController.completionHandler = ^(NSString *activityType, BOOL completed) {
        if(completed) {
            NSString *completionLabel;
            NSString *completionDetailsLabel;
            
            if([activityType isEqualToString:UIActivityTypeMessage]) {
                completionLabel = @"Message";
                completionDetailsLabel = @"Sent";
            } else if([activityType isEqualToString:UIActivityTypeMail]) {
                completionLabel = @"Email";
                completionDetailsLabel = @"Sent";
            } else if([activityType isEqualToString:UIActivityTypePostToTwitter]) {
                completionLabel = @"Posted to";
                completionDetailsLabel = @"Twitter";
            } else if([activityType isEqualToString:UIActivityTypePostToFacebook]) {
               completionLabel = @"Posted to";
                completionDetailsLabel = @"Facebook";
            } else if([activityType isEqualToString:UIActivityTypePostToTencentWeibo]) {
                completionLabel = @"Posted to";
                completionDetailsLabel = @"Tencent Weibo";
            } else if([activityType isEqualToString:UIActivityTypePostToWeibo]) {
                completionLabel = @"Posted to";
                completionDetailsLabel = @"Weibo";
            }  else if([activityType isEqualToString:UIActivityTypeAddToReadingList]) {
                completionLabel = @"Added to";
                completionDetailsLabel = @"Reading List";
            } else if([activityType isEqualToString:UIActivityTypeCopyToPasteboard]) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setURL:shareShortTailURL];
                completionLabel = @"Copied";
                completionDetailsLabel = @"";
            } else {
                completionLabel = @"Success!";
                completionDetailsLabel = @"";
            }
            
            /** GA Events **/
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"result_view" // Event category (required)
                                                                  action:@"share_activityController" // Event action (required)
                                                                   label:activityType // Event label
                                                                   value:nil] build]]; // Event value
            
            // Show HUD Message
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.userInteractionEnabled = NO;
            HUD.square = YES;
            HUD.color = UIColorFromRGB(0x34495e, 1.0);
            HUD.backgroundColor = UIColorFromRGB(0xffffff, 0.3);
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verify"]];
            HUD.labelText = completionLabel;
            HUD.detailsLabelText = completionDetailsLabel;
            HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
            HUD.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
            HUD.removeFromSuperViewOnHide = YES;
            [HUD hide:YES afterDelay:1.5];
        }
    };
    
    [self presentViewController:activityController animated:YES completion:nil];
}

-(IBAction)shareShortUrl {
    
    // Log iRate event, and once threshold is reached, show iRate on next launch
    [[iRate sharedInstance] logEvent:YES];
    
    [self shareURL];
}

- (void) handleDidBecomeActive: (NSNotification*) sender {
    if([settings boolForKey:@"processedPassedURL"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [settings removeObjectForKey:@"processedPassedURL"];
        [settings synchronize];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSString *)result {
    if([segue.identifier isEqualToString: @"resultsToWebView"]) {
        [segue.destinationViewController setTableViewShortURL:shortenedURL];
        [segue.destinationViewController setTableViewLongURL:resultLongURL];
        [segue.destinationViewController setTableViewTitleString:shareTitle];
    }
}

@end
