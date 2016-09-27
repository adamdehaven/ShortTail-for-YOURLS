/* ==========================================================
 * STSettingsTableViewController.m
 * ShortTail for YOURLS v1.6.5
 * https://github.com/adamdehaven/ShortTail
 *
 * Author: Adam DeHaven ( Twitter, GitHub: @adamdehaven )
 * http://adamdehaven.com/
 *
 *
 * Copyright (c) 2016 Adam Dehaven. All rights reserved.
 * ========================================================== */

#import "STSettingsTableViewController.h"
#import "CAKeyFrameAnimation+Jumping.h"
#import "iRate.h"
#import "RTSpinKitView.h"

#define UIColorFromRGB(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]


@interface STSettingsTableViewController () {
    NSUserDefaults *settings;
    
    UITextField *activeTextField;
    
    UIBarButtonItem *previousButton;
    UIBarButtonItem *nextButton;
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *flexSpace;
    UIBarButtonItem *fixedSpace;
    UIBarButtonItem *doneButton;
    
    UIColor *accentColor;
    UIColor *errorColor;
    
    BOOL valueChanged;
}

@end

@implementation STSettingsTableViewController

@synthesize settingsView, saveButton, signOutButton, baseURLField, signatureField, urlProtocol, urlProtocolLabel, maxLinksField, colorControl, colorControlIndex, writeReviewButton, suggestFeatureButton, needHelpButton, twitterButton, shorttailappButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    settings = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.adamdehaven.ShortTail"];
    
    [self setAccentColor];
    
    // disable save button
    if([settings boolForKey:@"needVerifySettings"]) {
        self.saveButton.enabled = YES;
        [settings setBool:NO forKey:@"needVerifySettings"];
    } else {
        self.saveButton.enabled = NO;
    }
    
    [saveButton setAccessibilityLabel:@"Save"];
    [saveButton setAccessibilityHint:@"Save Settings and return to main screen."];
    [cancelButton setAccessibilityLabel:@"Cancel"];
    [cancelButton setAccessibilityHint:@"Close Settings without saving and return to main screen."];
    
    valueChanged = NO;
    
    urlProtocol.on = [settings boolForKey:@"savedProtocolBool"];
    
    if([settings stringForKey:@"savedProtocol"].length > 1){
        urlProtocolLabel.text = [settings stringForKey:@"savedProtocol"];
    } else {
        [settings setObject:@"http://" forKey:@"savedProtocol"];
    }
    if([settings stringForKey:@"savedBaseUrl"].length > 1){
        baseURLField.text = [settings stringForKey:@"savedBaseUrl"];
    }
    if([settings stringForKey:@"savedSignature"].length > 1){
        signatureField.text = [settings stringForKey:@"savedSignature"];
    }
    if([settings stringForKey:@"savedMaxLinks"].length > 0){
        maxLinksField.text = [settings stringForKey:@"savedMaxLinks"];
    } else {
        maxLinksField.text = @"1200";
    }
    
    [settings synchronize];
    
}
    
- (void)viewWillAppear:(BOOL)animated {
    [self setupUI];
    
    // Set colorControl Index
    colorControl.selectedSegmentIndex = [settings integerForKey:@"colorControlIndex"];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Settings View"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}
    
- (void)setupUI {
    
    [self setAccentColor];
    
    // Navigation Bar Colors
    self.navigationController.navigationBar.barTintColor = accentColor;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    // Status Bar Color
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    baseURLField.textColor = accentColor;
    baseURLField.tintColor = accentColor;
    signatureField.textColor = accentColor;
    signatureField.tintColor = accentColor;
    [signOutButton setTitleColor:accentColor forState:UIControlStateNormal];
    [signOutButton setTitleColor:UIColorFromRGB(0x34495e, 1.0) forState:UIControlStateHighlighted];
    urlProtocol.onTintColor = accentColor;
    colorControl.tintColor = accentColor;
    // Prevent UISegmentedControl from becoming "grayed out"
    colorControl.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    
    [writeReviewButton setTitleColor:accentColor forState:UIControlStateNormal];
    [writeReviewButton setTintColor:accentColor];
    [suggestFeatureButton setTitleColor:accentColor forState:UIControlStateNormal];
    [suggestFeatureButton setTintColor:accentColor];
    [needHelpButton setTitleColor:accentColor forState:UIControlStateNormal];
    [needHelpButton setTintColor:accentColor];
    [twitterButton setTitleColor:accentColor forState:UIControlStateNormal];
    [twitterButton setTintColor:accentColor];
    [twitterButton setImage:[[UIImage imageNamed:@"twitter"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [shorttailappButton setTitleColor:accentColor forState:UIControlStateNormal];
    [shorttailappButton setTintColor:accentColor];
    [shorttailappButton setImage:[[UIImage imageNamed:@"squirrel-reg"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    self.tableView.separatorColor = accentColor;
}

- (IBAction)colorControlIndexChanged {
    
    UIColor *newColor;
    UIColor *saveErrorColor;
    
    /** GA Events **/
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    switch (colorControl.selectedSegmentIndex) {
        case 0:
            // orange
            newColor = UIColorFromRGB(0xe67e22, 1.0);
            saveErrorColor = UIColorFromRGB(0xe67e22, 0.2);
            [settings setInteger:0 forKey:@"colorControlIndex"];
            /** GA Events **/
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"settings" // Event category (required)
                                                                  action:@"flavor" // Event action (required)
                                                                   label:@"orange" // Event label
                                                                   value:nil] build]]; // Event value
            break;
        case 1:
            // blue
            newColor = UIColorFromRGB(0x3498db, 1.0);
            saveErrorColor = UIColorFromRGB(0x3498db, 0.2);
            [settings setInteger:1 forKey:@"colorControlIndex"];
            /** GA Events **/
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"settings" // Event category (required)
                                                                  action:@"flavor" // Event action (required)
                                                                   label:@"blue" // Event label
                                                                   value:nil] build]]; // Event value
            break;
        case 2:
            // green
            newColor = UIColorFromRGB(0x2ecc71, 1.0);
            saveErrorColor = UIColorFromRGB(0x2ecc71, 0.2);
            [settings setInteger:2 forKey:@"colorControlIndex"];
            /** GA Events **/
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"settings" // Event category (required)
                                                                  action:@"flavor" // Event action (required)
                                                                   label:@"green" // Event label
                                                                   value:nil] build]]; // Event value
            break;
        case 3:
            // purple
            newColor = UIColorFromRGB(0x9b59b6, 1.0);
            saveErrorColor = UIColorFromRGB(0x9b59b6, 0.2);
            [settings setInteger:3 forKey:@"colorControlIndex"];
            /** GA Events **/
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"settings" // Event category (required)
                                                                  action:@"flavor" // Event action (required)
                                                                   label:@"purple" // Event label
                                                                   value:nil] build]]; // Event value
            break;
        case 4:
            // red
            newColor = UIColorFromRGB(0xe74c3c, 1.0);
            saveErrorColor = UIColorFromRGB(0xe74c3c, 0.2);
            [settings setInteger:4 forKey:@"colorControlIndex"];
            /** GA Events **/
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"settings" // Event category (required)
                                                                  action:@"flavor" // Event action (required)
                                                                   label:@"red" // Event label
                                                                   value:nil] build]]; // Event value
            break;
    }
    
    // Save color
    NSData *newColorData = [NSKeyedArchiver archivedDataWithRootObject:newColor];
    [settings setObject:newColorData forKey:@"accentColor"];
    
    NSData *newErrorColorData = [NSKeyedArchiver archivedDataWithRootObject:saveErrorColor];
    [settings setObject:newErrorColorData forKey:@"errorColor"];
    
    [self setupUI];
    [self.tableView reloadData];
    saveButton.enabled = YES;
    
    [settings synchronize];
}

- (void)setAccentColor {
    NSData *colorData = [settings objectForKey:@"accentColor"];
    accentColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    
    NSData *errorColorData = [settings objectForKey:@"errorColor"];
    errorColor = [NSKeyedUnarchiver unarchiveObjectWithData:errorColorData];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    activeTextField = textField;
    
    textField.keyboardAppearance = UIKeyboardAppearanceDark;

    [self animateForKeyboard:textField up:YES];
}

- (void)textFieldDidChange:(UITextField *)textField {
    valueChanged = YES;
    // enable save button
    self.saveButton.enabled = YES;
}


// animate text fields for Keyboard
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == baseURLField) {
        baseURLField.text = [baseURLField.text lowercaseString];
    }
    [self animateForKeyboard: textField up: NO];
}

// animate text fields for Keyboard
- (void)animateForKeyboard:(UITextField*)textField up:(BOOL)up
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if(screenBounds.size.height > 568){
        // if 4 inch screen
        if(activeTextField == maxLinksField) {
            const int movementDistance = 36; // tweak as needed
            const float movementDuration = 0.3f; // tweak as needed
            int movement = (up ? -movementDistance : movementDistance);
            [UIView beginAnimations: @"anim" context: nil];
            [UIView setAnimationBeginsFromCurrentState: YES];
            [UIView setAnimationDuration: movementDuration];
            self.view.frame = CGRectOffset(self.view.frame, 0, movement);
            [UIView commitAnimations];
        }
    } else {
        // if 3.5 inch screen
        if(activeTextField == maxLinksField) {
            const int movementDistance = 36; // tweak as needed
            const float movementDuration = 0.3f; // tweak as needed
            int movement = (up ? -movementDistance : movementDistance);
            [UIView beginAnimations: @"anim" context: nil];
            [UIView setAnimationBeginsFromCurrentState: YES];
            [UIView setAnimationDuration: movementDuration];
            self.view.frame = CGRectOffset(self.view.frame, 0, movement);
            [UIView commitAnimations];
        }
    }
    
}
// -- animate text fields for Keyboard

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([settings boolForKey:@"savedConnectionValid"] == YES) {
        baseURLField.userInteractionEnabled = NO;
        baseURLField.textColor = UIColorFromRGB(0x9E9E9E, 1.0);
        signatureField.userInteractionEnabled = NO;
        signatureField.textColor = UIColorFromRGB(0x9E9E9E, 1.0);
    } else {
        baseURLField.userInteractionEnabled = YES;
        baseURLField.textColor = accentColor;
        baseURLField.tintColor = accentColor;
        signatureField.userInteractionEnabled = YES;
        signatureField.textColor = accentColor;
        signatureField.tintColor = accentColor;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle;
    
    switch (section)
    {
        case 0:
            if([settings boolForKey:@"savedConnectionValid"] == YES) {
                return nil;
            } else {
                headerTitle = @"Connect";
                return headerTitle;
            }
            break;
        case 1:
            if([settings boolForKey:@"savedConnectionValid"] == YES) {
                return nil;
            } else {
                headerTitle = @"API Signature Token";
                return headerTitle;
            }
            break;
        case 2:
            if([settings boolForKey:@"savedConnectionValid"] == YES) {
                headerTitle = [settings stringForKey:@"savedBaseUrl"];
                return headerTitle;
            } else {
                return nil;
            }
            break;
        case 3:
            headerTitle = @"Links";
            return headerTitle;
            break;
        case 4:
            headerTitle = @"Flavor";
            return headerTitle;
            break;
        case 5:
            headerTitle = @"About";
            return headerTitle;
            break;
        default:
            return nil;
            break;
    }
    // return headerTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *footerTitle;
    
    switch (section)
    {
        case 0:
            if([settings boolForKey:@"savedConnectionValid"] == YES) {
                return nil;
            } else {
                footerTitle = @"The URL leading to the YOURLS installation, with no trailing slash.";
                return footerTitle;
            }
            break;
        case 1:
            if([settings boolForKey:@"savedConnectionValid"] == YES) {
                return nil;
            } else {
                footerTitle = @"Enter your YOURLS Signature Token, found under 'Tools' on your YOURLS installation, to allow for API calls without your username and password. If your service is open for public use, leave this field empty.";
                return footerTitle;
            }
            break;
        case 2:
            if([settings boolForKey:@"savedConnectionValid"] == YES) {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                [numberFormatter setGroupingSeparator:[[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
                [numberFormatter setGroupingSize:3];
                footerTitle = [NSString stringWithFormat:@"Your installation of YOURLS has %@ links with %@ clicks.", [numberFormatter stringFromNumber:[NSNumber numberWithInteger:[[settings objectForKey:@"savedTotalLinks"] integerValue]]], [numberFormatter stringFromNumber:[NSNumber numberWithInteger:[[settings objectForKey:@"savedTotalClicks"] integerValue]]]];
                return footerTitle;
            } else {
                return nil;
            }
            break;
        case 3:
            footerTitle = @"Links are displayed by date created in decending order. The more links you load, the longer the wait depending on your connection.";
            return footerTitle;
            break;
        case 4:
            return nil;
            break;
        case 5:
            return nil;
            break;
        default:
            return nil;
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: // baseURL and protocol
            if([settings boolForKey:@"savedConnectionValid"] == YES) {
                return 0;
            } else {
                return 2;
            }
            break;
        case 1: // API Signature
            if([settings boolForKey:@"savedConnectionValid"] == YES) {
                return 0;
            } else {
                return 1;
            }
            break;
        case 2: // Disconnect
            if([settings boolForKey:@"savedConnectionValid"] == YES) {
                return 1;
            } else {
                return 0;
            }
        case 5:
            return 5;
        default:
            return 1;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // Hide empty section headers
    switch (section) {
        case 0:
        case 1:
            if([settings boolForKey:@"savedConnectionValid"] == YES) {
                return 0.1;
            } else {
                return 44.0;
            }
            break;
        case 2:
            if([settings boolForKey:@"savedConnectionValid"] == YES) {
                return 44.0;
            } else {
                return 0.1;
            }
        default:
            return 44.0;
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ([indexPath section]) {
        case 0:
        case 1:
            if([settings boolForKey:@"savedConnectionValid"] == YES) {
                return 0;
            } else {
                return 44.0;
            }
            break;
        case 2:
            if([settings boolForKey:@"savedConnectionValid"] == YES) {
                return 44.0;
            } else {
                return 0;
            }
        default:
            return 44.0;
            break;
    }
}

-(void)goToPrevTextfield{
    if(activeTextField == signatureField) {
        [activeTextField resignFirstResponder];
        [baseURLField becomeFirstResponder];
        return;
    } else if(activeTextField == maxLinksField) {
        [activeTextField resignFirstResponder];
        [signatureField becomeFirstResponder];
        return;
    }
}

-(void)goToNextTextfield{
    if (activeTextField == baseURLField) {
        [activeTextField resignFirstResponder];
        [signatureField becomeFirstResponder];
        return;
    } else if(activeTextField == signatureField) {
        [activeTextField resignFirstResponder];
        [maxLinksField becomeFirstResponder];
        return;
    }
}

-(void)doneWithKeyboard{
    [baseURLField resignFirstResponder];
    [signatureField resignFirstResponder];
    [maxLinksField resignFirstResponder];
}

-(void)cancelKeyboard{
    [activeTextField resignFirstResponder];
    if([settings stringForKey:@"savedMaxLinks"].length > 0){
        maxLinksField.text = [settings stringForKey:@"savedMaxLinks"];
    } else {
        maxLinksField.text = @"1200";
    }
}

// Limit the number of characters allowed in textField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // limit maxLinksField to 4 characters
    if(textField == maxLinksField){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 4) ? NO : YES;
    }
    
    return YES;
}

-(IBAction)protocolSwitch {
    if(!urlProtocol.on) {
        urlProtocolLabel.text = @"http://";
    } else {
        urlProtocolLabel.text = @"https://";
    }
}

- (IBAction)saveSettings {
    valueChanged = NO;
    
    // disable save button
    self.saveButton.enabled = NO;
    
    NSString *savedBaseUrl = [baseURLField.text lowercaseString];
    NSString *savedSignature = signatureField.text;
    NSString *savedMaxLinks = maxLinksField.text;
    
    [activeTextField resignFirstResponder];
    
    // Clear error colors
    baseURLField.backgroundColor = [UIColor clearColor];
    signatureField.backgroundColor = [UIColor clearColor];
    maxLinksField.backgroundColor = [UIColor clearColor];
    
    if(savedBaseUrl.length == 0) {
        [settings setBool:NO forKey:@"savedConnectionValid"];
        
        NSLog(@"Missing baseURL.");
        if ([UIAlertController class]) {
            NSLog(@"use UIAlertController");
            UIAlertController *baseURLAlert = [UIAlertController
                                                alertControllerWithTitle:@"Nuts..."
                                                message:@"Please enter your base URL."
                                                preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"Dismiss"
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"Dismiss");
                                               // Scroll to baseURLField, bounce, and change background color
                                               [self performSelector:@selector(scrollToTextField:) withObject:baseURLField afterDelay:0.0];
                                               [self performSelector:@selector(textFieldError:) withObject:baseURLField afterDelay:0.2];
                                           }];
            
            [baseURLAlert addAction:cancelAction];
            [self presentViewController:baseURLAlert animated:YES completion:nil];
            NSLog(@"Missing info in Settings.");
        } else {
            NSLog(@"use UIAlertView");
            
            UIAlertView *baseURLAlert = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                   message:@"Please enter your base URL."
                                                                  delegate:self
                                                         cancelButtonTitle:@"Dismiss"
                                                         otherButtonTitles:nil];
            [baseURLAlert setTag:1];
            [baseURLAlert show];
        }
        
    } else if(savedMaxLinks.length == 0) {
        [settings setBool:NO forKey:@"savedConnectionValid"];
        
        NSLog(@"Missing max links value.");
        if ([UIAlertController class]) {
            NSLog(@"use UIAlertController");
            UIAlertController *baseURLAlert = [UIAlertController
                                               alertControllerWithTitle:@"Nuts..."
                                               message:@"Please enter the maximum number of links to load."
                                               preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"Dismiss"
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"Dismiss");
                                               // Scroll to baseURLField, bounce, and change background color
                                               [self performSelector:@selector(scrollToTextField:) withObject:baseURLField afterDelay:0.0];
                                               [self performSelector:@selector(textFieldError:) withObject:baseURLField afterDelay:0.2];
                                           }];
            
            [baseURLAlert addAction:cancelAction];
            [self presentViewController:baseURLAlert animated:YES completion:nil];
            
        } else {
            NSLog(@"use UIAlertView");
            
            UIAlertView *maxLinksAlert = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                    message:@"Please enter the maximum number of links to load."
                                                                   delegate:self
                                                          cancelButtonTitle:@"Dismiss"
                                                          otherButtonTitles:nil];
            [maxLinksAlert setTag:3];
            [maxLinksAlert show];
        }
        
    } else { // save
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.color = UIColorFromRGB(0x34495e, 1.0);
        HUD.backgroundColor = UIColorFromRGB(0x34495e, 0.3);
        HUD.square = YES;
        HUD.mode = MBProgressHUDModeCustomView;
        RTSpinKitView *animatedSpinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleBounce color:[UIColor whiteColor]];
        HUD.customView = animatedSpinner;
        [animatedSpinner startAnimating];
        HUD.labelText = @"Verifying";
        HUD.detailsLabelText = @"Connection";
        HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
        HUD.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        [settings setBool:urlProtocol.on forKey:@"savedProtocolBool"];
        if(!urlProtocol.on) {
            [settings setObject:@"http://" forKey:@"savedProtocol"];
            
        } else {
            [settings setObject:@"https://" forKey:@"savedProtocol"];
        }
        
        // GA Events
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"settings" // Event category (required)
                                                              action:@"save_protocol" // Event action (required)
                                                               label:[settings stringForKey:@"savedProtocol"] // Event label
                                                               value:nil] build]]; // Event value
        
        NSURL *saveURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/yourls-api.php", [settings stringForKey:@"savedProtocol"], baseURLField.text]];
        NSMutableURLRequest *saveRequest = [NSMutableURLRequest requestWithURL:saveURL];
        NSString *postData = [NSString stringWithFormat:@"action=db-stats&signature=%@&format=json", signatureField.text];
        [saveRequest setHTTPMethod:@"POST"];
        [saveRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:saveRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if (!error) {
                NSDictionary *API = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                // get the URL keyword, and errors if any
                NSString *testStatus = API[@"message"];
                
                if([testStatus isEqualToString:@"success"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // set connection status to valid & save settings
                        [settings setBool:YES forKey:@"savedConnectionValid"];
                        [settings setObject:savedBaseUrl forKey:@"savedBaseUrl"];
                        [settings setObject:savedSignature forKey:@"savedSignature"];
                        [settings setObject:savedMaxLinks forKey:@"savedMaxLinks"];
                        [settings setBool:NO forKey:@"extensionNeedsLogin"];
                        [settings synchronize];
                        
                        baseURLField.userInteractionEnabled = NO;
                        baseURLField.textColor = UIColorFromRGB(0x9E9E9E, 1.0);
                        signatureField.userInteractionEnabled = NO;
                        signatureField.textColor = UIColorFromRGB(0x9E9E9E, 1.0);
                        signatureField.tintColor = accentColor;
                        
                        // GA Events
                        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"settings" // Event category (required)
                                                                              action:@"save_domain" // Event action (required)
                                                                               label:[settings stringForKey:@"savedBaseUrl"] // Event label
                                                                               value:nil] build]]; // Event value
                        
                        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"settings" // Event category (required)
                                                                              action:@"save_max_links" // Event action (required)
                                                                               label:[settings stringForKey:@"savedMaxLinks"] // Event label
                                                                               value:nil] build]]; // Event value
                        
                        // hide the activity indicator
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                        
                        [self.tableView reloadData];
                        
                        NSLog(@"Credentials correct & settings Saved");
                        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                        
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // set connection status to invalid
                        [settings setBool:NO forKey:@"savedConnectionValid"];
                        [settings synchronize];
                        
                        // hide the activity indicator
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                        
                        if ([UIAlertController class]) {
                            NSLog(@"use UIAlertController");
                            UIAlertController *settingsError = [UIAlertController
                                                               alertControllerWithTitle:@"Nuts..."
                                                               message:@"Could not connect to your server. Please verify your settings and network connection."
                                                               preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction *cancelAction = [UIAlertAction
                                                           actionWithTitle:@"Dismiss"
                                                           style:UIAlertActionStyleCancel
                                                           handler:^(UIAlertAction *action)
                                                           {
                                                               NSLog(@"Dismiss");
                                                               // Scroll to baseURLField, then bounce and change background color of baseURLField and signatureField
                                                               [self performSelector:@selector(textFieldError:) withObject:signatureField afterDelay:0.2];
                                                               [self performSelector:@selector(textFieldError:) withObject:baseURLField afterDelay:0.2];
                                                           }];
                            
                            [settingsError addAction:cancelAction];
                            [self presentViewController:settingsError animated:YES completion:nil];
                            NSLog(@"Base URL or Signature Incorrect in Settings or no connection.");
                        } else {
                            NSLog(@"use UIAlertView");
                            
                            UIAlertView *settingsError = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                                    message:@"Could not connect to your server. Please verify your settings and network connection."
                                                                                   delegate:self
                                                                          cancelButtonTitle:@"Dismiss"
                                                                          otherButtonTitles:nil];
                            NSLog(@"Base URL or Signature Incorrect in Settings or no connection.");
                            
                            [settingsError setTag:4];
                            [settingsError show];
                        }
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // set connection status to invalid
                    [settings setBool:NO forKey:@"savedConnectionValid"];
                    
                    // hide the activity indicator
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    
                    if ([UIAlertController class]) {
                        NSLog(@"use UIAlertController");
                        UIAlertController *settingsError = [UIAlertController
                                                            alertControllerWithTitle:@"Nuts..."
                                                            message:@"Could not connect to your server. Please verify your settings and network connection."
                                                            preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *cancelAction = [UIAlertAction
                                                       actionWithTitle:@"Dismiss"
                                                       style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action)
                                                       {
                                                           NSLog(@"Dismiss");
                                                           // Scroll to baseURLField, then bounce and change background color of baseURLField and signatureField
                                                           [self performSelector:@selector(textFieldError:) withObject:signatureField afterDelay:0.2];
                                                           [self performSelector:@selector(textFieldError:) withObject:baseURLField afterDelay:0.2];
                                                       }];
                        
                        [settingsError addAction:cancelAction];
                        [self presentViewController:settingsError animated:YES completion:nil];
                         NSLog(@"saveSettings: %@", error.localizedDescription);
                    } else {
                        NSLog(@"use UIAlertView");
                        
                        UIAlertView *settingsError = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                                message:@"Could not connect to your server. Please verify your settings and network connection."
                                                                               delegate:self
                                                                      cancelButtonTitle:@"Dismiss"
                                                                      otherButtonTitles:nil];
                        NSLog(@"saveSettings: %@", error.localizedDescription);
                        
                        [settingsError setTag:4];
                        [settingsError show];
                    }
                    
                });
            }
            
        }] resume];
    }
}

- (IBAction)signOut {
    if ([UIAlertController class]) {
        NSLog(@"use UIAlertController");
        UIAlertController *signOutConfirmAlert = [UIAlertController
                                            alertControllerWithTitle:@"Disconnect"
                                            message:@"Are you sure you want to disconnect?\n\nNo data is available without a connection to YOURLS."
                                            preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel");
                                       }];
        
        UIAlertAction *disconnectAction = [UIAlertAction
                                       actionWithTitle:@"Disconnect"
                                       style:UIAlertActionStyleDestructive
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Disconnect");
                                           [self signOutProcess];
                                       }];
        
        [signOutConfirmAlert addAction:disconnectAction];
        [signOutConfirmAlert addAction:cancelAction];
        [self presentViewController:signOutConfirmAlert animated:YES completion:nil];
        
    } else {
        NSLog(@"use UIAlertView");
        
        UIAlertView *signOutConfirmAlert = [[UIAlertView alloc] initWithTitle:@"Disconnect"
                                                                      message:@"Are you sure you want to disconnect?\n\nNo data is available without a connection to YOURLS."
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                            otherButtonTitles:@"Disconnect",nil];
        [signOutConfirmAlert setTag:5];
        [signOutConfirmAlert show];
    }
}

- (IBAction)signOutProcess {
    valueChanged = NO;
    // enable save button
    self.saveButton.enabled = NO;
    
    baseURLField.userInteractionEnabled = YES;
    baseURLField.text = @"";
    baseURLField.textColor = UIColorFromRGB(0x34495e, 1.0);
    signatureField.userInteractionEnabled = YES;
    signatureField.text = @"";
    signatureField.textColor = accentColor;
    signatureField.tintColor = accentColor;
    
    [[iRate sharedInstance] setDeclinedThisVersion:NO];
    
    /** GA Events **/
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"settings" // Event category (required)
                                                          action:@"disconnect" // Event action (required)
                                                           label:[settings stringForKey:@"savedBaseUrl"] // Event label
                                                           value:nil] build]]; // Event value
    
    // save previous baseURL to prevent pasting into long URL field
    [settings setObject:[settings stringForKey:@"savedBaseUrl"] forKey:@"disconnectedBaseUrl"];
    // Clear Saved Settings
    [settings removeObjectForKey:@"savedBaseUrl"];
    [settings removeObjectForKey:@"savedSignature"];
    [settings removeObjectForKey:@"savedMaxLinks"];
    [settings removeObjectForKey:@"savedConnectionValid"];
    [settings removeObjectForKey:@"sortOrdersBy"];
    // Reset Quick Share Tip in Stats TableView
    [settings removeObjectForKey:@"quickShareMessageHUDSeen"];
    [settings synchronize];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.color = UIColorFromRGB(0x34495e, 1.0);
    HUD.backgroundColor = UIColorFromRGB(0x34495e, 0.3);
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verify"]];
    HUD.labelText = @"Disconnected";
    HUD.detailsLabelText = @"from YOURLS";
    HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    HUD.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hide:YES afterDelay:1.5];
    
    [self.tableView reloadData];
}

-(IBAction) cancelSettings {
    [baseURLField resignFirstResponder];
    [signatureField resignFirstResponder];
    [maxLinksField resignFirstResponder];
    if(valueChanged == YES || (![maxLinksField.text isEqualToString:[settings stringForKey:@"savedMaxLinks"]] && ![maxLinksField.text isEqualToString:@"1200"] && maxLinksField.text.length > 0)){
        // enable save button
        self.saveButton.enabled = YES;
        [self showSaveSettingsAlert];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"Cancel Settings");
    }
}

- (void)showSaveSettingsAlert {
    if ([UIAlertController class]) {
        NSLog(@"use UIAlertController");
        UIAlertController *valueChangedAlert = [UIAlertController
                                                  alertControllerWithTitle:@"Save Changes"
                                                  message:@"Would you like to save your changes?"
                                                  preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:@"No"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"No");
                                           valueChanged = NO;
                                           maxLinksField.text = [settings stringForKey:@"savedMaxLinks"];
                                           // disable save button
                                           self.saveButton.enabled = NO;
                                           [self cancelSettings];
                                       }];
        
        UIAlertAction *saveAction = [UIAlertAction
                                           actionWithTitle:@"Save"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"Save");
                                               // save settings
                                               [self saveSettings];
                                           }];
        
        [valueChangedAlert addAction:saveAction];
        [valueChangedAlert addAction:cancelAction];
        [self presentViewController:valueChangedAlert animated:YES completion:nil];
        
    } else {
        NSLog(@"use UIAlertView");
        
        UIAlertView *valueChangedAlert = [[UIAlertView alloc] initWithTitle:@"Save Changes"
                                                                    message:@"Would you like to save your changes?"
                                                                   delegate:self
                                                          cancelButtonTitle:@"No"
                                                          otherButtonTitles:@"Save",nil];
        [valueChangedAlert setTag:6];
        [valueChangedAlert show];
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 1) {
        
        // Scroll to baseURLField, bounce, and change background color
        [self performSelector:@selector(scrollToTextField:) withObject:baseURLField afterDelay:0.0];
        [self performSelector:@selector(textFieldError:) withObject:baseURLField afterDelay:0.2];
        
    } else if(alertView.tag == 2) {
        
        // Scroll to signatureField, bounce, and change background color
        [self performSelector:@selector(scrollToTextField:) withObject:signatureField afterDelay:0.0];
        [self performSelector:@selector(textFieldError:) withObject:signatureField afterDelay:0.2];
        
    } else if(alertView.tag == 3) {
        
        // Scroll to maxLinksField, bounce, and change background color
        [self performSelector:@selector(scrollToTextField:) withObject:maxLinksField afterDelay:0.0];
        [self performSelector:@selector(textFieldError:) withObject:maxLinksField afterDelay:0.2];
        
    } else if(alertView.tag == 4) {
        
        // Scroll to baseURLField, then bounce and change background color of baseURLField and signatureField
        [self performSelector:@selector(textFieldError:) withObject:signatureField afterDelay:0.2];
        [self performSelector:@selector(textFieldError:) withObject:baseURLField afterDelay:0.2];
        
    } else if(alertView.tag == 5 && buttonIndex == 1) {
        
        [self signOutProcess];
    } else if((alertView.tag == 6) && buttonIndex == 1){
        // save settings
        [self saveSettings];
    } else if(alertView.tag == 6 && buttonIndex == 0){
        valueChanged = NO;
        maxLinksField.text = [settings stringForKey:@"savedMaxLinks"];
        // disable save button
        self.saveButton.enabled = NO;
        [self cancelSettings];
    }
}

-(void)scrollToTextField:(id)sender {
    UITextField *textField = (UITextField *)sender;
    [textField becomeFirstResponder];
}

-(void)textFieldError:(id)sender {
    UITextField *textField = (UITextField *)sender;
    
    // baseURLField is blank or incorrect
    CAKeyframeAnimation *textFieldAnimation = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:5];
    textField.backgroundColor = errorColor;
    [textField.layer addAnimation:textFieldAnimation forKey:@"jumping"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self doneWithKeyboard];
    [textField resignFirstResponder];
    return YES;
}

# pragma mark Other Actions

- (IBAction)suggestFeature {
    // Check that a mail account is available
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
        emailController.mailComposeDelegate = self;
        [[emailController navigationBar] setBarStyle:UIBarStyleBlackOpaque];
        [[emailController navigationBar] setTintColor:[UIColor whiteColor]];
        
        [emailController setToRecipients:[NSArray arrayWithObjects:@"shorttail@adamdehaven.com", nil]];
        
        [emailController setSubject:@"ShortTail Feature Suggestion"];
        [emailController setMessageBody:@"<p><strong>I have a feature suggestion for ShortTail for YOURLS. Here's my idea:</strong><hr> </p><br>" isHTML:YES];
        
        [self presentViewController:emailController animated:YES completion:nil];
    } else {
        if ([UIAlertController class]) {
            NSLog(@"use UIAlertController");
            UIAlertController *emailAccountsAlert = [UIAlertController
                                                    alertControllerWithTitle:@"Nuts..."
                                                    message:@"You must first configure your email account in Settings in order to send an email."
                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"Dismiss"
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"Dismiss");
                                           }];
            
            [emailAccountsAlert addAction:cancelAction];
            [self presentViewController:emailAccountsAlert animated:YES completion:nil];
            
        } else {
            NSLog(@"use UIAlertView");
            
            UIAlertView *emailAccountsAlert = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                         message:@"You must first configure your email account in Settings in order to send an email."
                                                                        delegate:self
                                                               cancelButtonTitle:@"Dismiss"
                                                               otherButtonTitles:nil];
            [emailAccountsAlert show];
        }
    }
}

- (IBAction)emailSupport {
    // Check that a mail account is available
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
        emailController.mailComposeDelegate = self;
        [[emailController navigationBar] setBarStyle:UIBarStyleBlackOpaque];
        [[emailController navigationBar] setTintColor:[UIColor whiteColor]];
        
        [emailController setToRecipients:[NSArray arrayWithObjects:@"shorttail@adamdehaven.com", nil]];
        
        [emailController setSubject:@"ShortTail App Support"];
        [emailController setMessageBody:@"<p><strong>I'm having trouble using the ShortTail for YOURLS iPhone app. The details are listed below:</strong><hr> </p><br>" isHTML:YES];
        
        [self presentViewController:emailController animated:YES completion:nil];
    } else {
        if ([UIAlertController class]) {
            NSLog(@"use UIAlertController");
            UIAlertController *emailAccountsAlert = [UIAlertController
                                                     alertControllerWithTitle:@"Nuts..."
                                                     message:@"You must first configure your email account in Settings in order to send an email."
                                                     preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"Dismiss"
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"Dismiss");
                                           }];
            
            [emailAccountsAlert addAction:cancelAction];
            [self presentViewController:emailAccountsAlert animated:YES completion:nil];
            
        } else {
            NSLog(@"use UIAlertView");
            
            UIAlertView *emailAccountsAlert = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                         message:@"You must first configure your email account in Settings in order to send an email."
                                                                        delegate:self
                                                               cancelButtonTitle:@"Dismiss"
                                                               otherButtonTitles:nil];
            [emailAccountsAlert show];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // GA Events
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    switch(result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail Draft saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.color = UIColorFromRGB(0x34495e, 1.0);
            HUD.backgroundColor = UIColorFromRGB(0x34495e, 0.3);
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
            HUD.labelText = @"Email";
            HUD.detailsLabelText = @"Sent";
            HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
            HUD.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
            HUD.removeFromSuperViewOnHide = YES;
            [HUD hide:YES afterDelay:1.2];
            
            // GA Events
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Settings_View" // Event category (required)
                                                                  action:@"email" // Event action (required)
                                                                   label:@"emailed_wirecrafters" // Event label
                                                                   value:nil] build]]; // Event value
            
            // Log iRate event, and once threshold is reached, show iRate on next launch
            [[iRate sharedInstance] logEvent:YES];
            
            break;
        case MFMailComposeResultFailed: {
            if ([UIAlertController class]) {
                NSLog(@"use UIAlertController");
                UIAlertController *emailFailedAlert = [UIAlertController
                                                         alertControllerWithTitle:@"Nuts..."
                                                         message:@"Your email could not be sent at this time."
                                                         preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction
                                               actionWithTitle:@"Dismiss"
                                               style:UIAlertActionStyleCancel
                                               handler:^(UIAlertAction *action)
                                               {
                                                   NSLog(@"Dismiss");
                                               }];
                
                [emailFailedAlert addAction:cancelAction];
                [self presentViewController:emailFailedAlert animated:YES completion:nil];
                
            } else {
                NSLog(@"use UIAlertView");
                
                UIAlertView *emailFailedAlert = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                           message:@"Your email could not be sent at this time."
                                                                          delegate:self
                                                                 cancelButtonTitle:@"Dismiss"
                                                                 otherButtonTitles:nil];
                [emailFailedAlert show];
            }
        }
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)writeReview {
    //reset event count
    [iRate sharedInstance].eventCount = 0;
    [iRate sharedInstance].ratedThisVersion = YES;
    
    [[iRate sharedInstance] openRatingsPageInAppStore];
}

- (IBAction)twitterMe {
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
        // open in Twitter App
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=adamdehaven"]];
    } else {
        // open in webView
        [settings setBool:YES forKey:@"openLink"];
        NSString *url = @"http://twitter.com/adamdehaven";
        [settings setObject:url forKey:@"urlToOpen"];
        [settings setObject:@"Adam Dehaven (adamdehaven) | Twitter" forKey:@"urlToOpenTitle"];
        [settings setObject:url forKey:@"urlToOpenDisplayLink"];
        [settings synchronize];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (IBAction)openShortTailAppCom {
    
    [settings setBool:YES forKey:@"openLink"];
    NSString *url = @"http://adamdehaven.com/blog/2015/05/shorttail-for-yourls-an-elegant-yourls-client-for-iphone/";
    [settings setObject:[NSString stringWithFormat:@"%@?utm_source=ShortTail_for_iOS&utm_medium=ShortTail_App&utm_campaign=ShortTail", url] forKey:@"urlToOpen"];
    [settings setObject:@"ShortTail - An elegant YOURLS client for iPhone | Adam DeHaven" forKey:@"urlToOpenTitle"];
    [settings setObject:url forKey:@"urlToOpenDisplayLink"];
    [settings synchronize];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
}

@end
