/* ==========================================================
 * STViewController.m
 * ShortTail for YOURLS v1.6.5
 * https://github.com/adamdehaven/ShortTail
 *
 * Author: Adam DeHaven ( Twitter, GitHub: @adamdehaven )
 * http://adamdehaven.com/
 *
 *
 * Copyright (c) 2016 Adam Dehaven. All rights reserved.
 * ========================================================== */

#import "STViewController.h"
#import "STResultViewController.h"
#import "STSettingsTableViewController.h"
#import "STStatsTableWebViewController.h"
#import "STHelpViewController.h"
#import "STShorten.h"
#import "CAKeyFrameAnimation+Jumping.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "iRate.h"

#define UIColorFromRGB(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

@interface STViewController () {
    NSUserDefaults *settings;
    UIColor *accentColor;
}

-(void) checkPasteboard;

@end

@implementation STViewController

@synthesize mainView, settingsButton, statsButton, infoButton, shortURLField, urlKeywordField, titleField, titleLabel, optionalLabel, shortenButton, titleString, longURLLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    settings = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.adamdehaven.ShortTail"];
    
    [self setAccentColor];
    
    // Set Navigation bar title for this view to image
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"squirrel"]];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"squirrel"] style:UIBarButtonItemStylePlain target:nil action:nil];
    [settingsButton setAccessibilityLabel:@"View Settings"];
    [statsButton setAccessibilityLabel:@"View Statistics"];
    [infoButton setAccessibilityLabel:@"About ShortTail"];
    [infoButton setAccessibilityHint:@"Allows user to view helpful information about how to use ShortTail for YOURLS"];
    
    mainView.backgroundColor = accentColor;
    
    [shortenButton setHidden:YES];
    [urlKeywordField setHidden:YES];
    [optionalLabel setHidden:YES];
    [shortURLField setHidden:YES];
    [longURLLabel setHidden:YES];
    [titleField setHidden:YES];
    [titleLabel setHidden:YES];
    
    // registering an ovbserver to know when the app has finished launching
    // and check for a URL in the pasteboard using "checkPasteboard"
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkPasteboard)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    // Subscribe to Notification, and perform 'handleDidBecomeActive'
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleDidBecomeActive:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    // animations
    [self performSelector:@selector(animateButton:) withObject:shortenButton afterDelay:0.3];
    [self performSelector:@selector(animateTextFields:) withObject:titleField afterDelay:0.5];
    [self performSelector:@selector(animateLabel:) withObject:titleLabel afterDelay:0.5];
    [self performSelector:@selector(animateTextFields:) withObject:urlKeywordField afterDelay:0.7];
    [self performSelector:@selector(animateLabel:) withObject:optionalLabel afterDelay:0.7];
    [self performSelector:@selector(animateTextFields:) withObject:shortURLField afterDelay:0.9];
    [self performSelector:@selector(animateLabel:) withObject:longURLLabel afterDelay:0.9];
}

- (void)dismissQuickShareMessage {
    // Dissmiss HUD
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // Test Connection and Update table
    [self performSegueWithIdentifier:@"viewSettingsModal" sender:self];
}

-(void)animateButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position" function:CircularEaseOut fromPoint:CGPointMake(button.center.x, button.center.y - screenSize.size.height) toPoint:button.center keyframeCount:120];
	animation.duration = 0.8;
    
	[button.layer addAnimation:animation forKey:@"easing"];
    [button setHidden:NO];
}

-(void)animateTextFields:(id)sender {
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    UITextField *textField = (UITextField *)sender;
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position" function:CircularEaseOut fromPoint:CGPointMake(textField.center.x, textField.center.y - screenSize.size.height) toPoint:textField.center keyframeCount:120];
	animation.duration = 0.8;
    
	[textField.layer addAnimation:animation forKey:@"easing"];
    [textField setHidden:NO];
}

-(void)animateLabel:(id)sender {
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    UILabel *label = (UILabel *)sender;
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position" function:CircularEaseOut fromPoint:CGPointMake(label.center.x, label.center.y - screenSize.size.height) toPoint:label.center keyframeCount:120];
	animation.duration = 0.8;
    
	[label.layer addAnimation:animation forKey:@"easing"];
    
    if ([shortURLField.text length] < 1 && label == longURLLabel) {
        [longURLLabel setHidden:YES];
    } else {
        [label setHidden:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self setAccentColor];
    [self setupUI];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self checkPasteboard];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Main View"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    if ([settings boolForKey:@"openLink"]) {
        [settings removeObjectForKey:@"openLink"];
        [settings synchronize];
        [self performSegueWithIdentifier:@"openLinkInModal" sender:self];
    }
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
    // Toolbar Colors
    self.navigationController.toolbar.barTintColor = UIColorFromRGB(0x34495e, 1.0);
    self.navigationController.toolbar.tintColor = [UIColor whiteColor];
    self.navigationController.toolbar.translucent = NO;
    // Status Bar Color
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    shortURLField.tintColor = UIColorFromRGB(0x34495e, 1.0);
    shortURLField.textColor = UIColorFromRGB(0x34495e, 1.0);
    titleField.tintColor = UIColorFromRGB(0x34495e, 1.0);
    titleField.textColor = UIColorFromRGB(0x34495e, 1.0);
    
    mainView.backgroundColor = accentColor;
    urlKeywordField.tintColor = accentColor;
    urlKeywordField.textColor = accentColor;
}

// checks for URL on pasteboard, if so, pastes into the URL field.
- (void) checkPasteboard {
    
    NSString *pasteProtocol = [settings stringForKey:@"savedProtocol"];
    NSString *pasteBase = [settings stringForKey:@"savedBaseUrl"];
    NSString *myDomain = [NSString stringWithFormat:@"%@%@",pasteProtocol,pasteBase];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    // if URL and not URL on YOURLS shortened domain, paste into field.
    if (pasteboard.string &&
        ([[pasteboard.string lowercaseString] hasPrefix:@"http://"] || [[pasteboard.string lowercaseString] hasPrefix:@"https://"]) &&
        ![[pasteboard.string lowercaseString] hasPrefix:myDomain] &&
        ![pasteboard.string hasPrefix:[NSString stringWithFormat:@"%@%@", pasteProtocol, [settings stringForKey:@"disconnectedBaseUrl"]]]) {
        
        shortURLField.text = pasteboard.string;
    }
    
}

- (void)viewDidUnload {
    [self setShortURLField:nil];
    [self setUrlKeywordField:nil];
    [self setTitleField:nil];
    [super viewDidUnload];
}

- (IBAction)shorten {
    
    [shortURLField resignFirstResponder];
    [urlKeywordField resignFirstResponder];
    [titleField resignFirstResponder];
    
    NSString *shortURL = shortURLField.text;
    // Keyword
    NSString *keywordForURL = urlKeywordField.text;
    NSString *trimmedKeyword = [keywordForURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedKeyword length] < 1 || [trimmedKeyword isEqualToString:@""]) {
        keywordForURL = @"";
    }
    // Title
    NSString *titleForURL = titleField.text;
    NSString *trimmedTitle = [titleForURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedTitle length] < 1 || [trimmedTitle isEqualToString:@""]) {
        titleForURL = @"";
    }
    
    // if Settings are not configured, show alert
    if([settings stringForKey:@"savedBaseUrl"].length == 0 || [settings stringForKey:@"savedSignature"].length == 0) {
        // show an error massage if we don't have a short URL
        if ([UIAlertController class]) {
            NSLog(@"use UIAlertController");
            UIAlertController *configureSettingsAlert = [UIAlertController
                                                     alertControllerWithTitle:@"Nuts..."
                                                     message:@"Please configure your settings."
                                                     preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"Dismiss"
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"Dismiss");
                                           }];
            
            UIAlertAction *settingsAction = [UIAlertAction
                                           actionWithTitle:@"Settings"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               // Settings button clicked
                                               [self performSegueWithIdentifier:@"viewSettingsModal" sender:self];
                                               [shortenButton setHidden:NO]; // Show Shorten button
                                           }];
            
            [configureSettingsAlert addAction:cancelAction];
            [configureSettingsAlert addAction:settingsAction];
            [self presentViewController:configureSettingsAlert animated:YES completion:nil];
            NSLog(@"Missing info in Settings.");
        } else {
            NSLog(@"use UIAlertView");
            
            UIAlertView *configureSettingsAlert = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                             message:@"Please configure your settings."
                                                                            delegate:self
                                                                   cancelButtonTitle:@"Dismiss"
                                                                   otherButtonTitles:@"Settings",nil];
            NSLog(@"Missing info in Settings.");
            [configureSettingsAlert setTag:1];
            [configureSettingsAlert show];
        }
        
        return;
    }
    
    if (shortURL.length == 0) {
        // show an error massage if we don't have a long URL
        if ([UIAlertController class]) {
            NSLog(@"use UIAlertController");
            UIAlertController *emptyFieldAlert = [UIAlertController
                                                         alertControllerWithTitle:@"Nuts..."
                                                         message:@"You first need a long URL to shorten."
                                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"Dismiss"
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"Dismiss");
                                               // bounce shortURLField after alert dismiss
                                               CAKeyframeAnimation *animation = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:16];
                                               [shortURLField.layer addAnimation:animation forKey:@"jumping"];
                                               [longURLLabel.layer addAnimation:animation forKey:@"jumping"];
                                               [shortenButton setHidden:NO]; // Show Shorten button
                                           }];
            
            [emptyFieldAlert addAction:cancelAction];
            [self presentViewController:emptyFieldAlert animated:YES completion:nil];
            NSLog(@"shortUrl is empty.");
        } else {
            NSLog(@"use UIAlertView");
            
            UIAlertView *emptyFieldAlert = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                      message:@"You first need a long URL to shorten."
                                                                     delegate:self
                                                            cancelButtonTitle:@"Dismiss"
                                                            otherButtonTitles:nil];
            NSLog(@"shortUrl is empty.");
            [emptyFieldAlert setTag:2];
            [emptyFieldAlert show];
        }
        
        // return to "exit" the function
        return;
    }
    
    if (![shortURL hasPrefix:@"http://"] && ![shortURL hasPrefix:@"https://"]) {
        // show an error massage if we don't have a short URL
        if ([UIAlertController class]) {
            NSLog(@"use UIAlertController");
            UIAlertController *emptyFieldAlert = [UIAlertController
                                                  alertControllerWithTitle:@"Nuts..."
                                                  message:@"Please enter a valid URL.\n Make sure your URL starts with http:// or https://"
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"Dismiss"
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"Dismiss");
                                               // bounce shortURLField after alert dismiss
                                               CAKeyframeAnimation *animation = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:16];
                                               [shortURLField.layer addAnimation:animation forKey:@"jumping"];
                                               [longURLLabel.layer addAnimation:animation forKey:@"jumping"];
                                               [shortenButton setHidden:NO]; // Show Shorten button
                                           }];
            
            [emptyFieldAlert addAction:cancelAction];
            [self presentViewController:emptyFieldAlert animated:YES completion:nil];
            NSLog(@"shortUrl does not start with http or https");
        } else {
            NSLog(@"use UIAlertView");
            
            UIAlertView *emptyFieldAlert = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                      message:@"Please enter a valid URL.\n Make sure your URL starts with http:// or https://"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Dismiss"
                                                            otherButtonTitles:nil];
            NSLog(@"shortUrl does not start with http or https");
            [emptyFieldAlert setTag:3];
            [emptyFieldAlert show];
        }
        
        // return to "exit" the function
        return;
    }
    
    if ([shortURL hasPrefix:[NSString stringWithFormat:@"%@%@", [settings stringForKey:@"savedProtocol"], [settings stringForKey:@"savedBaseUrl"]]]) {
        // show an error massage if trying to shorten an already shortened URL
        if ([UIAlertController class]) {
            NSLog(@"use UIAlertController");
            UIAlertController *alreadyShortAlert = [UIAlertController
                                                  alertControllerWithTitle:@"Nuts..."
                                                  message:@"This URL has already been shortened"
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"Dismiss"
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"Dismiss");
                                               // bounce shortURLField after alert dismiss
                                               CAKeyframeAnimation *animation = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:16];
                                               [shortURLField.layer addAnimation:animation forKey:@"jumping"];
                                               [longURLLabel.layer addAnimation:animation forKey:@"jumping"];
                                               [shortenButton setHidden:NO]; // Show Shorten button
                                           }];
            
            [alreadyShortAlert addAction:cancelAction];
            [self presentViewController:alreadyShortAlert animated:YES completion:nil];
            NSLog(@"URL is already shortened");
        } else {
            NSLog(@"use UIAlertView");
            
            UIAlertView *alreadyShortAlert = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                        message:@"This URL has already been shortened"
                                                                       delegate:self
                                                              cancelButtonTitle:@"Dismiss"
                                                              otherButtonTitles:nil];
            NSLog(@"URL is already shortened");
            [alreadyShortAlert setTag:6];
            [alreadyShortAlert show];
        }
        
        // return to "exit" the function
        return;
    }
    
    [shortenButton setHidden:YES];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.userInteractionEnabled = NO;
    HUD.color = UIColorFromRGB(0x34495e, 1.0);
    HUD.backgroundColor = UIColorFromRGB(0x34495e, 0.3);
    HUD.square = YES;
    HUD.labelText = @"Shortening";
    HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    HUD.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [STShorten shortenURL:shortURL customKeyword:keywordForURL customTitle:titleForURL withCallback:^(NSString *error, NSString *errorTag, NSString *urlKeyword, NSString *urlTitle) {
        
        // hide the activity indicator
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (urlKeyword) { // success
            titleString = urlTitle; // grab title for Results View
            
            /** GA Events **/
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"shorten" // Event category (required)
                                                                  action:[settings stringForKey:@"savedBaseUrl"] // Event action (required)
                                                                   label:shortURLField.text // Event label
                                                                   value:nil] build]]; // Event value
            
            // Log iRate event, and once threshold is reached, show iRate on next launch
            [[iRate sharedInstance] logEvent:YES];
            
            // so we have a long URL, perform the segue and send the long URL along with it
            [self performSegueWithIdentifier:@"goToResultsSegue" sender:urlKeyword];
        } else if([errorTag isEqualToString:@"keywordExistsError"]) {
            // show an error message if keyword already exists
            if ([UIAlertController class]) {
                NSLog(@"use UIAlertController");
                UIAlertController *noResultAlert = [UIAlertController
                                                        alertControllerWithTitle:@"Nuts..."
                                                        message:error
                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction
                                               actionWithTitle:@"Dismiss"
                                               style:UIAlertActionStyleCancel
                                               handler:^(UIAlertAction *action)
                                               {
                                                   NSLog(@"Dismiss");
                                                   // bounce shortURLField after alert dismiss
                                                   CAKeyframeAnimation *animationField = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:12];
                                                   [optionalLabel.layer addAnimation:animationField forKey:@"jumping"];
                                                   
                                                   // bounce shortURLField after alert dismiss
                                                   CAKeyframeAnimation *animationLabel = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:12];
                                                   [urlKeywordField.layer addAnimation:animationLabel forKey:@"jumping"];
                                                   [shortenButton setHidden:NO]; // Show Shorten button
                                               }];
                
                [noResultAlert addAction:cancelAction];
                [self presentViewController:noResultAlert animated:YES completion:nil];
                
            } else {
                NSLog(@"use UIAlertView");
                
                UIAlertView *noResultAlert = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                        message:error
                                                                       delegate:self
                                                              cancelButtonTitle:@"Dismiss"
                                                              otherButtonTitles:nil];
                [noResultAlert setTag:4];
                [noResultAlert show];
            }
            
            [shortenButton setHidden:NO]; // Show Shorten button
        } else {
            // show an error message if we don't have a long URL
            if ([UIAlertController class]) {
                NSLog(@"use UIAlertController");
                UIAlertController *noResultAlert = [UIAlertController
                                                    alertControllerWithTitle:@"Nuts..."
                                                    message:error
                                                    preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction
                                               actionWithTitle:@"Dismiss"
                                               style:UIAlertActionStyleCancel
                                               handler:^(UIAlertAction *action)
                                               {
                                                   NSLog(@"Dismiss");
                                               }];
                
                [noResultAlert addAction:cancelAction];
                [self presentViewController:noResultAlert animated:YES completion:nil];
                
            } else {
                NSLog(@"use UIAlertView");
                
                UIAlertView *noResultAlert = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                        message:error
                                                                       delegate:self
                                                              cancelButtonTitle:@"Dismiss"
                                                              otherButtonTitles:nil];
                NSLog(@"Show error message from STShorten.m");
                [noResultAlert setTag:5];
                [noResultAlert show];
            }
            
            [shortenButton setHidden:NO]; // Show Shorten button
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if((alertView.tag == 1 || alertView.tag == 7) && buttonIndex == 1){
        // Settings button clicked
        [self performSegueWithIdentifier:@"viewSettingsModal" sender:self];
        [shortenButton setHidden:NO]; // Show Shorten button
    } else if(alertView.tag == 2 || alertView.tag == 3 || alertView.tag == 6) {
        if(buttonIndex == 0){
            // bounce shortURLField after alert dismiss
            CAKeyframeAnimation *animation = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:16];
            [shortURLField.layer addAnimation:animation forKey:@"jumping"];
            [longURLLabel.layer addAnimation:animation forKey:@"jumping"];
            [shortenButton setHidden:NO]; // Show Shorten button
        }
    } else if(alertView.tag == 4) {
        // bounce shortURLField after alert dismiss
        CAKeyframeAnimation *animationField = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:12];
        [optionalLabel.layer addAnimation:animationField forKey:@"jumping"];
        
        // bounce shortURLField after alert dismiss
        CAKeyframeAnimation *animationLabel = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:12];
        [urlKeywordField.layer addAnimation:animationLabel forKey:@"jumping"];
        [shortenButton setHidden:NO]; // Show Shorten button
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(NSString *)result {
    
    if([segue.identifier isEqualToString:@"goToResultsSegue"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [segue.destinationViewController setResultLongURL:shortURLField.text];
        [segue.destinationViewController setShareTitle:titleString];
        [segue.destinationViewController setShortenedURL:[NSString stringWithFormat: @"%@%@/%@", [settings stringForKey:@"savedProtocol"], [settings stringForKey:@"savedBaseUrl"], result]];
    } else if ([segue.identifier isEqualToString:@"openLinkInModal"]) {
        [segue.destinationViewController setTableViewLongURL:[settings objectForKey:@"urlToOpen"]];
        [segue.destinationViewController setTableViewShortURL:[settings objectForKey:@"urlToOpenDisplayLink"]];
        if ([settings objectForKey:@"urlToOpenTitle"]) {
            [segue.destinationViewController setTableViewTitleString:[settings objectForKey:@"urlToOpenTitle"]];
        }
        
        [settings removeObjectForKey:@"urlToOpen"];
        [settings removeObjectForKey:@"urlToOpenTitle"];
        [settings removeObjectForKey:@"urlToOpenDisplayLink"];
        [settings synchronize];
    }
    
    // clear long url and keyword and title fields
    shortURLField.text = @"";
    urlKeywordField.text = @"";
    titleField.text = @"";
}

// handle the 'Done' button on the soft keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

// animate text fields for Keyboard
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.keyboardAppearance = UIKeyboardAppearanceDark;
    
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self animateForKeyboard:textField up:YES];
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    if ([shortURLField.text length] > 0) {
        [longURLLabel setHidden:NO];
    } else {
        [longURLLabel setHidden:YES];
    }
    
    if ([urlKeywordField.text length] > 0) {
        optionalLabel.text = @"Keyword";
        [optionalLabel setHidden:NO];
    } else {
        optionalLabel.text = @"optional";
        [optionalLabel setHidden:NO];
    }
    
    if ([titleField.text length] > 0) {
        titleLabel.text = @"Custom Title";
        [titleLabel setHidden:NO];
    } else {
        titleLabel.text = @"optional";
        [titleLabel setHidden:NO];
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([urlKeywordField.text length] > 0) {
        optionalLabel.text = @"Keyword";
        [optionalLabel setHidden:NO];
    } else {
        optionalLabel.text = @"optional";
        [optionalLabel setHidden:NO];
    }
    
    if ([shortURLField.text length] > 0) {
        [longURLLabel setHidden:NO];
    } else {
        [longURLLabel setHidden:YES];
    }
    
    if ([titleField.text length] > 0) {
        titleLabel.text = @"Custom Title";
        [titleLabel setHidden:NO];
    } else {
        titleLabel.text = @"optional";
        [titleLabel setHidden:NO];
    }
    
    [self animateForKeyboard:textField up:NO];
}

- (void)animateForKeyboard: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 70; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if(textField.tag == 2 && screenBounds.size.height < 568){
        [UIView beginAnimations: @"anim" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
        [UIView commitAnimations];
    }
}
// -- animate text fields for Keyboard

- (void)handleDidBecomeActive: (NSNotification*) sender
{
    // If custom URL scheme "shorttail://" or "ShortTail://" is used and is valid URL, paste URL into field.
    if([settings stringForKey:@"savedPassedURL"]) {
        [self processPassedURL];
    }
    
    // If extension needs login, go to Settings
    if ([settings boolForKey:@"extensionNeedsLogin"] == YES) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.mode = MBProgressHUDModeText;
        HUD.margin = 15.0f;
        //HUD.dimBackground = YES;
        HUD.color = UIColorFromRGB(0x34495e, 1.0);
        HUD.backgroundColor = UIColorFromRGB(0x34495e, 0.3);
        HUD.labelText = @"Share Extension";
        HUD.detailsLabelText = @"\nTo use the Share Extension, please connect your domain.\n\n(Touch to view Settings)";
        HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Regular" size:20.0];
        HUD.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
        [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissQuickShareMessage)]];
        HUD.removeFromSuperViewOnHide = YES;
        
        // Set BOOL to NO after user sees message
        [settings setBool:NO forKey:@"extensionNeedsLogin"];
        [settings synchronize];
    }
}
    
- (void)processPassedURL {
    NSString *passedURL = [settings stringForKey:@"savedPassedURL"];
    shortURLField.text = [NSString stringWithFormat:@"http://%@", passedURL];
    [longURLLabel setHidden:YES];
    [settings removeObjectForKey:@"savedPassedURL"];
    [settings setBool:YES forKey:@"processedPassedURL"];
    [settings synchronize];
    NSLog(@"processPassedURL");
}

- (IBAction)viewStats:(id)sender {
    // if Settings are not configured, show alert
    if([settings stringForKey:@"savedProtocol"].length < 1 || [settings stringForKey:@"savedBaseUrl"].length < 1 || [settings boolForKey:@"savedConnectionValid"] == NO) {
        // show an error massage if missing login credentials
        if ([UIAlertController class]) {
            NSLog(@"use UIAlertController");
            UIAlertController *settingsAlert = [UIAlertController
                                                alertControllerWithTitle:@"Nuts..."
                                                message:@"Please configure your settings."
                                                preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"Dismiss"
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"Dismiss");
                                           }];
            
            UIAlertAction *settingsAction = [UIAlertAction
                                           actionWithTitle:@"Settings"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"Settings");
                                               // Settings button clicked
                                               [self performSegueWithIdentifier:@"viewSettingsModal" sender:self];
                                               [shortenButton setHidden:NO]; // Show Shorten button
                                           }];
            
            [settingsAlert addAction:cancelAction];
            [settingsAlert addAction:settingsAction];
            [self presentViewController:settingsAlert animated:YES completion:nil];
            NSLog(@"Missing info in Settings.");
        } else {
            NSLog(@"use UIAlertView");
            
            UIAlertView *settingsAlert = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                    message:@"Please configure your settings."
                                                                   delegate:self
                                                          cancelButtonTitle:@"Dismiss"
                                                          otherButtonTitles:@"Settings",nil];
            NSLog(@"Missing info in Settings.");
            [settingsAlert setTag:7];
            [settingsAlert show];
        }
        
        return;
    } else {
        [self performSegueWithIdentifier:@"viewStatsSegue" sender:self];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // limit urlKeywordField to 25 characters
    if(textField == urlKeywordField){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 25) ? NO : YES;
    }
    
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [shortenButton setHidden:NO]; // Show Shorten button
    [super viewDidDisappear:animated];
}

@end
