/* ==========================================================
 * STStatsTableWebViewController.m
 * ShortTail for YOURLS v1.6.5
 * https://github.com/adamdehaven/ShortTail
 *
 * Author: Adam DeHaven ( Twitter, GitHub: @adamdehaven )
 * http://adamdehaven.com/
 *
 *
 * Copyright (c) 2016 Adam Dehaven. All rights reserved.
 * ========================================================== */

#import "STStatsTableWebViewController.h"
#import "STStatsTableViewController.h"
#import "STViewController.h"
#import "iRate.h"
#define UIColorFromRGB(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

@interface STStatsTableWebViewController () {
    NSUserDefaults *settings;
    NSArray *toolbarButtonItems;
    UIActivityIndicatorView *activityView;
    UIBarButtonItem *spinner;
    UIBarButtonItem *refreshButton;
    UIBarButtonItem *toolbarFlexibleSpace;
    UIBarButtonItem *toolbarFixedSpace;
    NSURL *longURL;
    UIColor *accentColor;
}

@end

@implementation STStatsTableWebViewController

@synthesize tableWebView, tableViewShortURL, tableViewLongURL, tableViewTitleString, tableWebViewTitle, tableWebViewSubtitle, linkClicked, activityItems, backButton, forwardButton, stopButton, actionSheet, shareButton, actionSheetAlertController;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createAndShowToolbar];
    
    settings = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.adamdehaven.ShortTail"];
    
    tableViewShortURL = self.tableViewShortURL;
    tableViewLongURL = self.tableViewLongURL;
    tableViewTitleString = self.tableViewTitleString;
    
    if (tableViewTitleString.length < 1) {
        tableViewTitleString = @"Loading";
    }
    
    self.title = tableViewTitleString;
    [self modifyTitleToLabelWithSize:18];
    tableWebViewSubtitle.text = tableViewLongURL;
    
    [tableWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tableViewLongURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0]];
    
    tableWebView.scrollView.bounces = NO;
    
    [self setLinkClicked:NO];
    NSURL *shortURL = [NSURL URLWithString:tableViewShortURL];
    activityItems = @[tableViewTitleString, shortURL];
    
    // Subscribe to Notification, and perform 'handleDidBecomeActive'
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleDidBecomeActive:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self setupUI];
    [self createActionSheet];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Stats Table Web View"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)setupUI {
    [self setAccentColor];
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
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.tableWebView setBackgroundColor:[UIColor clearColor]];
    [self.tableWebView setOpaque:NO];
}

- (void)setAccentColor {
    NSData *colorData = [settings objectForKey:@"accentColor"];
    accentColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
}

- (void)createAndShowToolbar {
    // Create toolbar buttons
    backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left"] style:UIBarButtonItemStylePlain target:self action:@selector(webViewGoBack)];
    forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"right"] style:UIBarButtonItemStylePlain target:self action:@selector(webViewGoForward)];
    stopButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"stop"] style:UIBarButtonItemStylePlain target:self action:@selector(stopLoading)];
    refreshButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(webViewRefresh)];
    toolbarFlexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    toolbarFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    toolbarFixedSpace.width = 20.0f;
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityView setHidesWhenStopped:YES];
    spinner = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    
    toolbarButtonItems = @[backButton, toolbarFixedSpace, forwardButton, toolbarFlexibleSpace, spinner, toolbarFixedSpace, stopButton];
    [self setToolbarItems:toolbarButtonItems animated:YES];
    
    // Show Toolbar
    [self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)modifyTitleToLabelWithSize:(CGFloat)fontSize {
    // Title Modification
    UILabel *tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    tlabel.numberOfLines = 2;
    tlabel.text = self.navigationItem.title;
    tlabel.textColor = [UIColor whiteColor];
    tlabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
    tlabel.backgroundColor = [UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth = YES;
    tlabel.minimumScaleFactor = 0.8;
    tlabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = tlabel;
}

- (IBAction)webViewGoBack {
    if([self.tableWebView canGoBack]) {
        [self.tableWebView goBack];
    }
}

- (IBAction)webViewGoForward {
    if([self.tableWebView canGoForward]) {
        [self.tableWebView goForward];
    }
}

- (IBAction)stopLoading {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.tableWebView stopLoading];
    stopButton.enabled = NO;
    [self createActionSheet];
    toolbarButtonItems = @[backButton, toolbarFixedSpace, forwardButton, toolbarFlexibleSpace, refreshButton, toolbarFixedSpace, stopButton];
    [self setToolbarItems:toolbarButtonItems animated:YES];
}

- (IBAction)webViewRefresh {
    [self.tableWebView reload];
    [activityView startAnimating];
    toolbarButtonItems = @[backButton, toolbarFixedSpace, forwardButton, toolbarFlexibleSpace, spinner, toolbarFixedSpace, stopButton];
    [self setToolbarItems:toolbarButtonItems animated:YES];
    stopButton.enabled = YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [self setLinkClicked:YES];
        self.title = @"Loading";
        [self modifyTitleToLabelWithSize:18];
        tableWebViewSubtitle.text = tableViewLongURL;
    }
    return YES;
}

- (IBAction)shareURL {
    // Share URL    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
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
            }  else if([activityType isEqualToString:UIActivityTypePostToTencentWeibo]) {
                completionLabel = @"Posted to";
                completionDetailsLabel = @"Tencent Weibo";
            } else if([activityType isEqualToString:UIActivityTypePostToWeibo]) {
                completionLabel = @"Posted to";
                completionDetailsLabel = @"Weibo";
            } else if([activityType isEqualToString:UIActivityTypeAddToReadingList]) {
                completionLabel = @"Added to";
                completionDetailsLabel = @"Reading List";
            } else if([activityType isEqualToString:UIActivityTypeCopyToPasteboard]) {
                completionLabel = @"Copied";
                completionDetailsLabel = @"";
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                if(linkClicked){
                    [pasteboard setURL:[NSURL URLWithString:[[self.tableWebView.request mainDocumentURL] absoluteString]]];
                } else {
                    [pasteboard setURL:[NSURL URLWithString:tableViewShortURL]];
                }
            } else {
                completionLabel = @"Success!";
                completionDetailsLabel = @"";
            }
            
            /** GA Events **/
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"stats_table_web_view" // Event category (required)
                                                                  action:@"share_activityController" // Event action (required)
                                                                   label:activityType // Event label
                                                                   value:nil] build]]; // Event value
            
            // Log iRate event, and once threshold is reached, show iRate on next launch
            [[iRate sharedInstance] logEvent:YES];
            
            // Show HUD Message
            HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            HUD.userInteractionEnabled = NO;
            HUD.color = UIColorFromRGB(0x34495e, 1.0);
            HUD.backgroundColor = UIColorFromRGB(0x34495e, 0.3);
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

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
    [activityView startAnimating];
    
    if([activityView isAnimating]) {
        toolbarButtonItems = @[backButton, toolbarFixedSpace, forwardButton, toolbarFlexibleSpace, spinner, toolbarFixedSpace, stopButton];
        [self setToolbarItems:toolbarButtonItems animated:YES];
    } else {
        toolbarButtonItems = @[backButton, toolbarFixedSpace, forwardButton, toolbarFlexibleSpace, refreshButton, toolbarFixedSpace, stopButton];
        [self setToolbarItems:toolbarButtonItems animated:YES];
    }
    
    if([self.tableWebView canGoBack]) {
        backButton.enabled = YES;
    } else {
        backButton.enabled = NO;
    }
    
    if([self.tableWebView canGoForward]) {
        forwardButton.enabled = YES;
    } else {
        forwardButton.enabled = NO;
    }
    
    if(linkClicked){
        longURL = [NSURL URLWithString:[[self.tableWebView.request mainDocumentURL] absoluteString]];
        activityItems = @[tableWebViewTitle.text, longURL];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
    [activityView stopAnimating];
    
    // Set page title
    self.title = [self.tableWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    actionSheet.title = self.title;
    [self modifyTitleToLabelWithSize:18];
    // Set subtitle to URL
    tableWebViewSubtitle.text = [[tableWebView.request mainDocumentURL] absoluteString];
    
    if([activityView isAnimating]) {
        toolbarButtonItems = @[backButton, toolbarFixedSpace, forwardButton, toolbarFlexibleSpace, spinner, toolbarFixedSpace, stopButton];
        [self setToolbarItems:toolbarButtonItems animated:YES];
    } else {
        toolbarButtonItems = @[backButton, toolbarFixedSpace, forwardButton, toolbarFlexibleSpace, refreshButton, toolbarFixedSpace, stopButton];
        [self setToolbarItems:toolbarButtonItems animated:YES];
    }
    
    if(tableWebView.isLoading) {
        return;
    } else {
        stopButton.enabled = NO;
    }
    
    [self createActionSheet];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}
    
- (void) handleDidBecomeActive: (NSNotification*) sender {
    if([settings boolForKey:@"processedPassedURL"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    if ([self->tableWebView isLoading]) {
        [self->tableWebView stopLoading];
    }
    // Set page title
    self.title = @"";
    [self modifyTitleToLabelWithSize:18];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
    
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if ([self.tableWebView isLoading]) {
        [self.tableWebView stopLoading];
    }
    
    if((error.code == NSURLErrorCancelled) || (error.code == 102 && [error.domain isEqualToString:@"WebKitErrorDomain"])) {
        return;
    }
    
    if ([error code] != NSURLErrorCancelled) {
        
        self.title = @"Network Error";
        [self modifyTitleToLabelWithSize:18];
        tableWebViewSubtitle.text = @"Please enable WiFi or check your connection.";
        
        //show error alert, etc.
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        
        NSLog(@"error:%@", error);
        
        if ([UIAlertController class]) {
            NSLog(@"use UIAlertController");
            UIAlertController *networkError = [UIAlertController
                                                         alertControllerWithTitle:@"Nuts..."
                                                         message:@"Please enable WiFi or check your network connection."
                                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"Dismiss"
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"Dismiss");
                                               HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                                               HUD.userInteractionEnabled = NO;
                                               HUD.color = UIColorFromRGB(0x34495e, 1.0);
                                               HUD.mode = MBProgressHUDModeCustomView;
                                               HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
                                               HUD.labelText = @"Connection";
                                               HUD.detailsLabelText = @"Failed";
                                               HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
                                               HUD.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
                                               HUD.removeFromSuperViewOnHide = YES;
                                               
                                               [self.navigationController setToolbarHidden:YES animated:YES];
                                           }];
            
            [networkError addAction:cancelAction];
            [self presentViewController:networkError animated:YES completion:nil];
            NSLog(@"2. Network Connection Error");
        } else {
            NSLog(@"use UIAlertView");
            
            UIAlertView *networkError = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                   message:@"Please enable WiFi or check your network connection."
                                                                  delegate:self
                                                         cancelButtonTitle:@"Dismiss"
                                                         otherButtonTitles:nil];
            [networkError setTag:1];
            [networkError show];
        }
        
    }
}

- (IBAction)showActionSheet:(id)sender //Define method to show action sheet
{
    if ([UIAlertController class]) {
        NSLog(@"use UIAlertController");
        [self presentViewController:actionSheetAlertController animated:YES completion:nil];
    } else {
        NSLog(@"use UIActionSheet");
        if(self.toolbarHidden != YES) {
            [actionSheet showFromToolbar:self.navigationController.toolbar];
        } else {
            // Show action sheet
            [actionSheet showInView:self.view];
        }
    }
}

#pragma mark - UIActionSheetDelegate Methods
- (void)createActionSheet {
    NSString *actionSheetTitle = tableViewTitleString; //[self.tableWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *share = @"Share";
    NSString *safariButton = @"Open in Safari";
    NSString *cancelButton = @"Cancel";
    
    if ([UIAlertController class]) {
        NSLog(@"use UIAlertController");
        
        NSString *urlToDisplay;
        if(linkClicked){
            urlToDisplay = [[self.tableWebView.request mainDocumentURL] absoluteString];
        } else {
            urlToDisplay = tableViewShortURL;
        }
        
        actionSheetAlertController = [UIAlertController
                                      alertControllerWithTitle:actionSheetTitle
                                      message:urlToDisplay
                                      preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *shareAction = [UIAlertAction
                                       actionWithTitle:share
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Share");
                                           [self shareURL];
                                       }];
        [actionSheetAlertController addAction:shareAction];
        
        UIAlertAction *safariAction = [UIAlertAction
                                      actionWithTitle:safariButton
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action)
                                      {
                                          NSLog(@"Open in Safari");
                                          // Open in Safari
                                          if(linkClicked){
                                              [[UIApplication sharedApplication] openURL:longURL];
                                          } else {
                                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tableViewLongURL]];
                                          }
                                      }];
        [actionSheetAlertController addAction:safariAction];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:cancelButton
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel");
                                       }];
        [actionSheetAlertController addAction:cancelAction];
        
    } else {
        NSLog(@"use UIActionSheet");
        actionSheet = [[UIActionSheet alloc] init];
        actionSheet.delegate = self;
        [actionSheet addButtonWithTitle:share];
        [actionSheet addButtonWithTitle:safariButton];
        // Add title
        actionSheet.title = actionSheetTitle;
        // Add Cancel button
        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:cancelButton];
    }
    
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    // Change actionSheet button colors/attributes
    
    for (UIView *subview in self.actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            if([button.titleLabel.text isEqualToString:@"Cancel"]) {
                [button setTitleColor:UIColorFromRGB(0x363636, 1.0) forState:UIControlStateNormal];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            } else {
                [button setTitleColor:UIColorFromRGB(0x3498DB, 1.0) forState:UIControlStateNormal];
                [button setTitleColor:UIColorFromRGB(0x2980B9, 1.0) forState:UIControlStateHighlighted];
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Get the name of the current pressed button
    NSString *buttonTitle = [self.actionSheet buttonTitleAtIndex:buttonIndex];
    
    if([buttonTitle isEqualToString:@"Open in Safari"]) {
        // Open in Safari
        if(linkClicked){
            [[UIApplication sharedApplication] openURL:longURL];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tableViewLongURL]];
        }
        
    } else if([buttonTitle isEqualToString:@"Share"]) {
        [self shareURL];
    } else if ([buttonTitle isEqualToString:@"Cancel"]) {
        NSLog(@"Dismiss pressed --> Cancel ActionSheet");
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == 1) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.userInteractionEnabled = NO;
        HUD.color = UIColorFromRGB(0x34495e, 1.0);
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
        HUD.labelText = @"Connection";
        HUD.detailsLabelText = @"Failed";
        HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
        HUD.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
        HUD.removeFromSuperViewOnHide = YES;
        
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}
    
- (void)viewWillDisappear:(BOOL)animated {
    
    if ([self.tableWebView isLoading]) {
        [self.tableWebView stopLoading];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
    
}

@end