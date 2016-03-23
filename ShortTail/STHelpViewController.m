/* ==========================================================
 * STHelpViewController.m
 * ShortTail for YOURLS v1.6.5
 * https://github.com/adamdehaven/ShortTail
 *
 * Author: Adam DeHaven ( Twitter, GitHub: @adamdehaven )
 * http://adamdehaven.com/
 *
 *
 * Copyright (c) 2016 Adam Dehaven. All rights reserved.
 * ========================================================== */

#import "STHelpViewController.h"
#import "iRate.h"
#define UIColorFromRGB(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

@interface STHelpViewController ()

@end

@implementation STHelpViewController {
    NSUserDefaults *settings;
    UIButton *twitterButton;
}

@synthesize helpTextView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    settings = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.adamdehaven.ShortTail"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self setupUI];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Help View"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)setupUI {
    // Navigation Bar Colors
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x34495e, 1.0);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    // Status Bar Color
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [helpTextView setTextContainerInset:UIEdgeInsetsMake(20, 20, 20, 20)];
    [helpTextView setTextAlignment:NSTextAlignmentLeft];
}
    
-(IBAction) closeHelpView {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end