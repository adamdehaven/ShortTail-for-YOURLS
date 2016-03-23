/* ==========================================================
 * STStatsTableWebViewController.h
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
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface STStatsTableWebViewController : UIViewController <MFMailComposeViewControllerDelegate, UIActionSheetDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property (nonatomic, strong) IBOutlet UIWebView *tableWebView;
@property (nonatomic, strong) NSString *tableViewShortURL;
@property (nonatomic, strong) NSString *tableViewLongURL;
@property (nonatomic, strong) NSString *tableViewTitleString;
@property (nonatomic, strong) IBOutlet UILabel *tableWebViewTitle;
@property (nonatomic, strong) IBOutlet UILabel *tableWebViewSubtitle;
@property (nonatomic, assign) BOOL linkClicked;
@property (nonatomic, strong) NSArray *activityItems;
@property(nonatomic,getter=isToolbarHidden) BOOL toolbarHidden;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *stopButton;
@property (strong, nonatomic) IBOutlet UIActionSheet *actionSheet;
@property (strong, nonatomic) IBOutlet UIAlertController *actionSheetAlertController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@end
