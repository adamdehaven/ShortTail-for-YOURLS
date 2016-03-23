/* ==========================================================
 * STViewController.h
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
#import "MBProgressHUD.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface STViewController : UIViewController <MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *statsButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *infoButton;
@property (strong, nonatomic) IBOutlet UITextField *shortURLField;
@property (weak, nonatomic) IBOutlet UITextField *urlKeywordField;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (strong, nonatomic) IBOutlet UIButton *shortenButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *optionalLabel;
@property (weak, nonatomic) IBOutlet UILabel *longURLLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSString *titleString;
@property (nonatomic,getter=isToolbarHidden) BOOL toolbarHidden;

- (IBAction)shorten;
- (IBAction)viewStats:(id)sender;

@end
