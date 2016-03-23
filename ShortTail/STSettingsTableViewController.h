/* ==========================================================
 * STSettingsTableViewController.h
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
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface STSettingsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate, MFMailComposeViewControllerDelegate> {
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (weak, nonatomic) IBOutlet UITextField *baseURLField;
@property (weak, nonatomic) IBOutlet UITextField *signatureField;
@property (weak, nonatomic) IBOutlet UISwitch *urlProtocol;
@property (weak, nonatomic) IBOutlet UILabel *urlProtocolLabel;
@property (weak, nonatomic) IBOutlet UITextField *maxLinksField;
@property (strong, nonatomic) IBOutlet UISegmentedControl *colorControl;
@property (nonatomic, assign) NSInteger colorControlIndex;
@property (weak, nonatomic) IBOutlet UIButton *writeReviewButton;
@property (weak, nonatomic) IBOutlet UIButton *suggestFeatureButton;
@property (weak, nonatomic) IBOutlet UIButton *needHelpButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *shorttailappButton;

- (IBAction)saveSettings;
- (IBAction)cancelSettings;
- (IBAction)protocolSwitch;
- (IBAction)colorControlIndexChanged;
- (IBAction)signOut;
- (IBAction)writeReview;
- (IBAction)suggestFeature;
- (IBAction)emailSupport;
- (IBAction)twitterMe;
- (IBAction)openShortTailAppCom;

@end
