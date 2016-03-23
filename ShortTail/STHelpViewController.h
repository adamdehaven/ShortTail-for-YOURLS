/* ==========================================================
 * STHelpViewController.h
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
#import <MessageUI/MessageUI.h>
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface STHelpViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextView *helpTextView;

-(IBAction) closeHelpView;

@end
