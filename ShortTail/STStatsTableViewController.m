/* ==========================================================
 * STStatsTableViewController.m
 * ShortTail for YOURLS v1.6.5
 * https://github.com/adamdehaven/ShortTail
 *
 * Author: Adam DeHaven ( Twitter, GitHub: @adamdehaven )
 * http://adamdehaven.com/
 *
 *
 * Copyright (c) 2016 Adam Dehaven. All rights reserved.
 * ========================================================== */

#import "STStatsTableViewController.h"
#import "STStatsTableWebViewController.h"
#import "STStatsCell.h"
#import "STViewController.h"
#import "CAKeyFrameAnimation+Jumping.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "iRate.h"
#import "BDBSpinKitRefreshControl.h"
#import "RTSpinKitView.h"

#define UIColorFromRGB(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

@interface STStatsTableViewController ()

@end

@implementation STStatsTableViewController {
    NSUserDefaults *settings;
    NSArray *yourlsStats;
    NSArray *searchResults;
    NSArray *filterArray;
    UIRefreshControl *refreshControl;
    NSMutableAttributedString *refreshTitle;
    BOOL didUpdate;
    UIColor *accentColor;
    BOOL didSort;
    BOOL preventAnimate;
    BOOL tapToDismiss;
    BOOL showHUD;
}

@synthesize statsTableView, API, tableURL, tableLongURL, titleString, searchBar, searchButton, sortButton, actionSheet, actionSheetAlertController;

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
    didUpdate = NO;
    searchButton.enabled = YES;
    sortButton.enabled = YES;
    searchBar.hidden = YES;
    didSort = NO;
    preventAnimate = NO;
    tapToDismiss = NO;
    showHUD = YES;
    
    [self setTitle:@"Statistics"];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    refreshControl = [BDBSpinKitRefreshControl refreshControlWithStyle:RTSpinKitViewStyleWave color:UIColorFromRGB(0x34495e, 1.0)];
    refreshControl.tintColor = UIColorFromRGB(0x34495e, 1.0);
    [refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self performSelector:@selector(resetRefreshTitle:) withObject:@"Pull" afterDelay:0.0];
    
    // Subscribe to Notification, and perform 'handleDidBecomeActive'
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleDidBecomeActive:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    // Create navigation bar buttons
    searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"] style:UIBarButtonItemStylePlain target:self action:@selector(displaySearchBar:)];
    sortButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sort"] style:UIBarButtonItemStylePlain target:self action:@selector(showSortOptions:)];
    NSArray *buttonItems = @[searchButton, sortButton];
    [self.navigationItem setRightBarButtonItems:buttonItems animated:YES];
    
    // Show Quick Share message
    if(![settings boolForKey:@"quickShareMessageHUDSeen"]) {
        [self showQuickShareMessage];
    }
    
    if([settings stringForKey:@"sortOrdersBy"] == nil || [settings stringForKey:@"activeSortButtonTitle"] == nil) {
        [settings setObject:@"recent" forKey:@"sortOrdersBy"];
        [settings setObject:@"Recent" forKey:@"activeSortButtonTitle"];
        [settings synchronize];
    }
}
    
- (void)showQuickShareMessage {
    
    sortButton.enabled = NO;
    searchButton.enabled = NO;
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.color = UIColorFromRGB(0x34495e, 1.0);
    HUD.labelText = @"Quick Share";
    HUD.detailsLabelText = @"\nPress and hold on a row to quickly share or copy the link's short URL.\n\n(Touch to dismiss)";
    HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Regular" size:20.0];
    HUD.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissQuickShareMessage)]];
    HUD.removeFromSuperViewOnHide = YES;
}
    
- (void)dismissQuickShareMessage {
    // Set BOOL to yes after user sees message
    [settings setBool:YES forKey:@"quickShareMessageHUDSeen"];
    [settings synchronize];
    // Dissmiss HUD
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    sortButton.enabled = YES;
    searchButton.enabled = YES;
     
     // Test Connection and Update table
     [self testConnection];
}

- (void)dismissHUDOnTap {
    // Dissmiss HUD
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

- (void)handleDidBecomeActive: (NSNotification*) sender {
    if([settings boolForKey:@"processedPassedURL"]) {
        [settings removeObjectForKey:@"processedPassedURL"];
        [settings synchronize];
        [self.navigationController popToRootViewControllerAnimated:YES];
        NSLog(@"present");
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self setAccentColor];
    [self setupUI];
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    // if Settings are not configured, show alert
    if(didUpdate == NO && [settings boolForKey:@"quickShareMessageHUDSeen"]) {
        [self testConnection];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Statistics View"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    // deselect tableView row on return
    [statsTableView deselectRowAtIndexPath:[statsTableView indexPathForSelectedRow] animated:YES];
    
    preventAnimate = YES;
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
    
    searchBar.tintColor = UIColorFromRGB(0x34495e, 1.0);
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:UIColorFromRGB(0x34495e, 1.0)];
}
    
- (void)testConnection {
    
    searchButton.enabled = NO;
    sortButton.enabled = NO;
    tapToDismiss = NO;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self setTitle:@"Statistics"];
    
    
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.square = YES;
    HUD.mode = MBProgressHUDModeCustomView;
    RTSpinKitView *animatedSpinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleBounce color:[UIColor whiteColor]];
    HUD.customView = animatedSpinner;
    [animatedSpinner startAnimating];
    HUD.color = UIColorFromRGB(0x34495E, 1.0);
    HUD.labelText = @"Loading";
    HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    
    NSString *testProtocol = [settings stringForKey:@"savedProtocol"];
    NSString *testBaseUrl = [settings stringForKey:@"savedBaseUrl"];
    NSString *testSignature = [settings stringForKey:@"savedSignature"];
    
    NSURL *testURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/yourls-api.php", testProtocol, testBaseUrl]];
    NSMutableURLRequest *testURLRequest = [NSMutableURLRequest requestWithURL:testURL];
    NSString *postData = [NSString stringWithFormat:@"action=db-stats&signature=%@&format=json", testSignature];
    [testURLRequest setHTTPMethod:@"POST"];
    [testURLRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:testURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            NSDictionary *testAPI = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            // get the URL keyword, and errors if any
            NSString *testStatus = testAPI[@"message"];
            
            if([testStatus isEqualToString:@"success"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // set connection status to valid & save settings
                    [settings setBool:YES forKey:@"savedConnectionValid"];
                    [settings synchronize];
                    
                    searchButton.enabled = YES;
                    sortButton.enabled = YES;
                    
                    // Turn other loading indicators off (just in case) before refreshing
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    
                    [self updateTable];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    
                    if ([UIAlertController class]) {
                        NSLog(@"use UIAlertController");
                        UIAlertController *connectionValidError = [UIAlertController
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
                                                           HUD.color = UIColorFromRGB(0x34495E, 1.0);
                                                           HUD.mode = MBProgressHUDModeCustomView;
                                                           HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
                                                           HUD.labelText = @"Connection Failed";
                                                           if (tapToDismiss) {
                                                               HUD.detailsLabelText = @"Tap to Dismiss";
                                                               HUD.userInteractionEnabled = YES;
                                                               [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissHUDOnTap)]];
                                                           } else {
                                                               HUD.detailsLabelText = @"Pull down to refresh";
                                                           }
                                                           HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0];
                                                           HUD.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
                                                           HUD.removeFromSuperViewOnHide = YES;
                                                       }];
                        
                        [connectionValidError addAction:cancelAction];
                        [self presentViewController:connectionValidError animated:YES completion:nil];
                        NSLog(@"Network Error");
                    } else {
                        NSLog(@"use UIAlertView");
                        
                        UIAlertView *connectionValidError = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                                       message:@"Please enable WiFi or check your network connection."
                                                                                      delegate:self
                                                                             cancelButtonTitle:@"Dismiss"
                                                                             otherButtonTitles:nil];
                        NSLog(@"Network Error");
                        [connectionValidError setTag:3];
                        [connectionValidError show];
                    }
                    
                    [self setTitle:@"Network Error"];
                    
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                
                if ([UIAlertController class]) {
                    NSLog(@"use UIAlertController");
                    UIAlertController *connectionValidError = [UIAlertController
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
                                                       HUD.color = UIColorFromRGB(0x34495E, 1.0);
                                                       HUD.mode = MBProgressHUDModeCustomView;
                                                       HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
                                                       HUD.labelText = @"Connection Failed";
                                                       if (tapToDismiss) {
                                                           HUD.detailsLabelText = @"Tap to Dismiss";
                                                           HUD.userInteractionEnabled = YES;
                                                           [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissHUDOnTap)]];
                                                       } else {
                                                           HUD.detailsLabelText = @"Pull down to refresh";
                                                       }
                                                       HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0];
                                                       HUD.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
                                                       HUD.removeFromSuperViewOnHide = YES;
                                                   }];
                    
                    [connectionValidError addAction:cancelAction];
                    [self presentViewController:connectionValidError animated:YES completion:nil];
                    NSLog(@"Network Error");
                } else {
                    NSLog(@"use UIAlertView");
                    
                    UIAlertView *connectionValidError = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                                   message:@"Please enable WiFi or check your network connection."
                                                                                  delegate:self
                                                                         cancelButtonTitle:@"Dismiss"
                                                                         otherButtonTitles:nil];
                    NSLog(@"testConnection: %@", error.localizedDescription);
                    [connectionValidError setTag:3];
                    [connectionValidError show];
                }
                
                [self setTitle:@"Network Error"];
            });
        }
        
    }] resume];
}

-(void)hideSearchBarAnimated:(BOOL)doAnimation {
    if (doAnimation != NO || doAnimation == YES) {
        doAnimation = YES;
    } else {
        doAnimation = NO;
    }
    [statsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:doAnimation];
}

-(IBAction)displaySearchBar:(id)sender {
    
    /** GA Events **/
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"statistics_view" // Event category (required)
                                                          action:@"search_button" // Event action (required)
                                                           label:@"initiated_search" // Event label
                                                           value:nil] build]]; // Event value
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    NSTimeInterval delay;
    if (self.tableView.contentOffset.y >1000) delay = 0.2;
    else delay = 0.0;
    [self performSelector:@selector(activateSearch) withObject:nil afterDelay:delay];
}

- (void)activateSearch
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.searchBar becomeFirstResponder];
    
}

-(void)resetRefreshTitle:(id)sender{
    
    // GA Events
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"statistics_view" // Event category (required)
                                                          action:@"refresh" // Event action (required)
                                                           label:@"pull_to_refresh" // Event label
                                                           value:nil] build]]; // Event value
    
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"'Last updated at' h:mm a"];
    NSString *lastUpdated = [dateFormatter stringFromDate: currentTime];
    
    NSString *option = (NSString *)sender;
    if([option isEqualToString:@"Fetch"]){
        refreshTitle = [[NSMutableAttributedString alloc] initWithString:@"Refreshing..."];
    } else if([option isEqualToString:@"Pull"]){
        refreshTitle = [[NSMutableAttributedString alloc] initWithString:@"Pull down to refresh"];
    } else {
        refreshTitle = [[NSMutableAttributedString alloc] initWithString:lastUpdated];
    }
    [refreshTitle addAttribute:NSFontAttributeName
                         value:[UIFont fontWithName:@"HelveticaNeue-Light" size:10] range:NSMakeRange(0, [refreshTitle length])];
    [refreshTitle addAttribute:NSForegroundColorAttributeName
                         value:UIColorFromRGB(0x34495e, 1.0) range:NSMakeRange(0, [refreshTitle length])];
    refreshControl.attributedTitle = refreshTitle;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar setPlaceholder:@"Search"];
    [self.searchBar setPrompt:@""];
    NSTimeInterval delay;
    if (self.tableView.contentOffset.y >1000) delay = 0.2;
    else delay = 0.0;
    [self performSelector:@selector(hideSearchBarAnimated:) withObject:self afterDelay:delay];
}

- (void)pullToRefresh{
    showHUD = NO;
    [self updateTable];
}

- (void)updateTable {
    // Turn other loading indicators off (just in case) before refreshing
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
    [self setTitle:@"Statistics"];
    
    
    searchButton.enabled = NO;
    sortButton.enabled = NO;
    
    [self performSelector:@selector(resetRefreshTitle:) withObject:@"Fetch" afterDelay:0.0];
    
    // Turn loading indicators on
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (showHUD) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.square = YES;
        HUD.mode = MBProgressHUDModeCustomView;
        RTSpinKitView *animatedSpinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleBounce color:[UIColor whiteColor]];
        HUD.customView = animatedSpinner;
        [animatedSpinner startAnimating];
        HUD.color = UIColorFromRGB(0x34495E, 1.0);
        if(didSort) {
            HUD.labelText = @"Sorting";
            // Scroll to top (minus searchBar)
            if (statsTableView.contentOffset.y < 44.0) {
                [statsTableView setContentOffset:CGPointMake(0, (0 - (self.tableView.contentInset.top - 44.0))) animated:YES];
            } else {
                [statsTableView setContentOffset:CGPointMake(0, 44) animated:YES];
            }
        } else {
            HUD.labelText = @"Loading";
        }
        didSort = NO;
        HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    }
    showHUD = YES;
    
    NSString *urlProtocol = [settings stringForKey:@"savedProtocol"];
    NSString *baseURL = [settings stringForKey:@"savedBaseUrl"];
    NSString *signature = [settings stringForKey:@"savedSignature"];
    NSString *maxLinks = [settings stringForKey:@"savedMaxLinks"];
    NSString *sortBy = [settings stringForKey:@"sortOrdersBy"];
    NSString *filter;
    
    if([sortBy isEqualToString:@"recent"]){
        filter = @"last";
    } else if([sortBy isEqualToString:@"mostClicks"]) {
        filter = @"top";
    } else if([sortBy isEqualToString:@"fewestClicks"]) {
        filter = @"bottom";
    } else {
        filter = @"last";
    }
    
    // ---------------------------
    NSURL *updateTableURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/yourls-api.php", urlProtocol, baseURL]];
    NSMutableURLRequest *updateTableRequest = [NSMutableURLRequest requestWithURL:updateTableURL];
    NSString *postData = [NSString stringWithFormat:@"signature=%@&action=stats&filter=%@&limit=%@&format=json", signature, filter, maxLinks];
    [updateTableRequest setHTTPMethod:@"POST"];
    [updateTableRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:updateTableRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            API = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            // get the URL keyword, and errors if any
            NSString *statusMessage = API[@"message"];
            
            if([statusMessage isEqualToString:@"success"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    filterArray = [NSArray arrayWithObject:API];
                    yourlsStats = API[@"links"];
                    
                    NSString *totalLinks = API[@"stats"][@"total_links"];
                    NSString *totalClicks = API[@"stats"][@"total_clicks"];
                    [settings setObject:totalLinks forKey:@"savedTotalLinks"];
                    [settings setObject:totalClicks forKey:@"savedTotalClicks"];
                    [settings synchronize];
                    
                    // Scroll to top
                    [statsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                    
                    [self createSortActionSheet];
                    
                    searchButton.enabled = YES;
                    sortButton.enabled = YES;
                    tapToDismiss = YES;
                    
                    // Display number of results in title
                    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    [numberFormatter setGroupingSeparator:[[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
                    [numberFormatter setGroupingSize:3];
                    
                    [self setTitle:@"Statistics"];
                    //[self setTitle:[NSString stringWithFormat:@"Displaying %@ of %@", [numberFormatter stringFromNumber:[NSNumber numberWithInteger:[yourlsStats count]]], [numberFormatter stringFromNumber:[NSNumber numberWithInteger:[totalLinks integerValue]]]]];
                    
                    
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    [self.refreshControl endRefreshing];
                    // Update pull to refresh title
                    [self performSelector:@selector(resetRefreshTitle:) withObject:nil afterDelay:0.7];
                    
                    didUpdate = YES;
                    searchBar.hidden = NO;
                    if (preventAnimate) {
                        [self hideSearchBarAnimated:NO];
                        preventAnimate = NO;
                    } else {
                        [self hideSearchBarAnimated:YES];
                    }
                    
                    // Log iRate event, and once threshold is reached, show iRate on next launch
                    [[iRate sharedInstance] logEvent:YES];
                });
            } else if([statusMessage isEqualToString:@"Please log in"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self setTitle:@"Please verify Settings"];
                    tapToDismiss = NO;
                    
                    // Scroll to top
                    [statsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                    
                    [self.refreshControl endRefreshing];
                    // enable Verify button in settings
                    [settings setBool:YES forKey:@"needVerifySettings"];
                    [settings synchronize];
                    
                    if ([UIAlertController class]) {
                        NSLog(@"use UIAlertController");
                        UIAlertController *settingsError = [UIAlertController
                                                                   alertControllerWithTitle:@"Nuts..."
                                                                   message:@"Could not connect to your server. Please verify settings."
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
                                                       }];
                        
                        [settingsError addAction:cancelAction];
                        [settingsError addAction:settingsAction];
                        [self presentViewController:settingsError animated:YES completion:nil];
                        NSLog(@"1. Base URL or Signature Incorrect in Settings.");
                    } else {
                        NSLog(@"use UIAlertView");
                        
                        UIAlertView *settingsError = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                                message:@"Could not connect to your server. Please verify settings."
                                                                               delegate:self
                                                                      cancelButtonTitle:@"Dismiss"
                                                                      otherButtonTitles:@"Settings", nil];
                        NSLog(@"1. Base URL or Signature Incorrect in Settings.");
                        
                        [settingsError setTag:1];
                        [settingsError show];
                    }
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self setTitle:@"Network Error"];
                tapToDismiss = YES;
                
                // Scroll to top
                [statsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [self.refreshControl endRefreshing];
                
                if ([UIAlertController class]) {
                    NSLog(@"use UIAlertController");
                    UIAlertController *networkConnectionError = [UIAlertController
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
                                                       HUD.color = UIColorFromRGB(0x34495E, 1.0);
                                                       HUD.mode = MBProgressHUDModeCustomView;
                                                       HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
                                                       HUD.labelText = @"Connection Failed";
                                                       if (tapToDismiss) {
                                                           HUD.detailsLabelText = @"Tap to Dismiss";
                                                           HUD.userInteractionEnabled = YES;
                                                           [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissHUDOnTap)]];
                                                       } else {
                                                           HUD.detailsLabelText = @"Pull down to refresh";
                                                       }
                                                       HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0];
                                                       HUD.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
                                                       HUD.removeFromSuperViewOnHide = YES;
                                                   }];
                    
                    [networkConnectionError addAction:cancelAction];
                    [self presentViewController:networkConnectionError animated:YES completion:nil];
                    NSLog(@"2. Network Connection Error");
                } else {
                    NSLog(@"use UIAlertView");
                    
                    UIAlertView *networkConnectionError = [[UIAlertView alloc] initWithTitle:@"Nuts..."
                                                                                     message:@"Please enable WiFi or check your network connection."
                                                                                    delegate:self
                                                                           cancelButtonTitle:@"Dismiss"
                                                                           otherButtonTitles:nil];
                    NSLog(@"2. Network Connection Error");
                    
                    [networkConnectionError setTag:2];
                    [networkConnectionError show];
                }
                
            });
        }
        
    }] resume];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 1){
        // Settings button clicked
        [self performSegueWithIdentifier:@"viewSettingsModal" sender:self];
    }
    
    if((alertView.tag == 1 || alertView.tag == 2 || alertView.tag == 3) && buttonIndex != 1) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.userInteractionEnabled = NO;
        HUD.color = UIColorFromRGB(0x34495E, 1.0);
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
        HUD.labelText = @"Connection Failed";
        if (tapToDismiss) {
            if (alertView.tag == 3) {
                HUD.detailsLabelText = @"Pull down to refresh";
            } else {
                HUD.detailsLabelText = @"Tap to Dismiss";
                HUD.userInteractionEnabled = YES;
                [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissHUDOnTap)]];
            }
        } else {
            HUD.detailsLabelText = @"Pull down to refresh";
        }
        HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0];
        HUD.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
        HUD.removeFromSuperViewOnHide = YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    } else {
        return [yourlsStats count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STStatsCell *cell = [self.statsTableView dequeueReusableCellWithIdentifier:@"yourlsStatsCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[STStatsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"yourlsStatsCell"];
    }
    
    NSString *urlProtocol = [settings stringForKey:@"savedProtocol"];
    NSString *baseURL = [settings stringForKey:@"savedBaseUrl"];
    
    // For Attributed Text Line Spacing
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:3.5];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // Search Title
        NSMutableAttributedString *title;
        if ([[[searchResults objectAtIndex:indexPath.row] objectForKey:@"title"] isKindOfClass:[NSNull class]]){
            title = [[NSMutableAttributedString alloc] initWithString:@"[No title]"];
        } else {
            title = [[NSMutableAttributedString alloc] initWithString:[[searchResults objectAtIndex:indexPath.row] objectForKey:@"title"]];
        }
        
        [title addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [title length])];
        cell.yourlsLinkTitle.attributedText = title;
        
        // Search Short URL
        cell.yourlsShortUrl.text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"shorturl"];
        // Search Long URL
        cell.yourlsLongUrl.text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"url"];
        // Search Keyword
        cell.yourlsKeyword.text = [cell.yourlsShortUrl.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@%@/",urlProtocol,baseURL] withString:@""];
        // Search Clicks
        cell.yourlsClicks.text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"clicks"];
    } else {
        NSString *linkIndex = [NSString stringWithFormat:@"link_%li",(long)indexPath.row + 1];
        // Title
        NSMutableAttributedString *title;
        if ([API[@"links"][linkIndex][@"title"] isKindOfClass:[NSNull class]]){
            title = [[NSMutableAttributedString alloc] initWithString:@"[No title]"];
        } else {
            title = [[NSMutableAttributedString alloc] initWithString:API[@"links"][linkIndex][@"title"]];
        }
        [title addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [title length])];
        cell.yourlsLinkTitle.attributedText = title;
        
        // Short URL
        cell.yourlsShortUrl.text = API[@"links"][linkIndex][@"shorturl"];
        cell.yourlsKeyword.text = [cell.yourlsShortUrl.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@%@/",urlProtocol,baseURL] withString:@""];
        // Long URL
        cell.yourlsLongUrl.text = API[@"links"][linkIndex][@"url"];
        // Clicks
        cell.yourlsClicks.text = API[@"links"][linkIndex][@"clicks"];
    }
    
    // Add long press gesture recognizer
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [cell addGestureRecognizer:longPressGesture];
    
    // Determine cell background image
    int long colorIndex = [settings integerForKey:@"colorControlIndex"];

    switch (colorIndex) {
        case 0: // orange
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-background-orange"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-background-orange-selected"]];
            break;
        case 1: // blue
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-background-blue"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-background-blue-selected"]];
            break;
        case 2: // green
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-background-green"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-background-green-selected"]];
            break;
        case 3: // purple
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-background-purple"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-background-purple-selected"]];
            break;
        case 4: // red
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-background-red"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-background-red-selected"]];
            break;
    }
    
    cell.yourlsKeyword.textColor = accentColor;
    cell.yourlsKeyword.highlightedTextColor = accentColor;
    cell.yourlsClicks.textColor = accentColor;
    cell.yourlsClicks.highlightedTextColor = accentColor;
    
    return cell;
}
    
- (void)longPress:(UILongPressGestureRecognizer *)gesture {
    // only when gesture was recognized, not when ended
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        STStatsCell *cell = (STStatsCell *)[gesture view];
        
        NSURL *shareURL = [NSURL URLWithString:cell.yourlsShortUrl.text];
        
        NSArray *activityItems = @[cell.yourlsLinkTitle.text, shareURL];
        
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        
        [activityController setValue:cell.yourlsLinkTitle.text forKey:@"subject"];
        
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
                } else if([activityType isEqualToString:UIActivityTypeAddToReadingList]) {
                    completionLabel = @"Added to";
                    completionDetailsLabel = @"Reading List";
                } else if([activityType isEqualToString:UIActivityTypeCopyToPasteboard]) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    [pasteboard setURL:shareURL];
                    completionLabel = @"Copied";
                    completionDetailsLabel = @"";
                } else {
                    completionLabel = @"Success!";
                    completionDetailsLabel = @"";
                }
                
                // GA Events
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"statistics_view" // Event category (required)
                                                                      action:@"share_activityController" // Event action (required)
                                                                       label:activityType // Event label
                                                                       value:nil] build]]; // Event value
                
                // Log iRate event, and once threshold is reached, show iRate on next launch
                [[iRate sharedInstance] logEvent:YES];
                
                // Show HUD Message
                HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                HUD.userInteractionEnabled = NO;
                HUD.square = YES;
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
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STStatsCell *cell;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell = (STStatsCell *)[tableView cellForRowAtIndexPath:indexPath];
    } else {
        cell = (STStatsCell *)[statsTableView cellForRowAtIndexPath:indexPath];
    }
    tableURL = cell.yourlsShortUrl.text;
    tableLongURL = cell.yourlsLongUrl.text;
    titleString = cell.yourlsLinkTitle.text;
    
   [self performSegueWithIdentifier:@"statsTableToWeb" sender:self];
}

#pragma mark - UISearchDisplayController delegate methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    switch (self.searchBar.selectedScopeButtonIndex) {
        case 0: // Title
            self.searchBar.placeholder = @"Enter URL Title";
            self.searchBar.prompt = @"Search by Title";
            break;
        case 1: // PO #
            self.searchBar.placeholder = @"Enter Shortened URL Keyword";
            self.searchBar.prompt = @"Search by Keyword";
            break;
        default:
            self.searchBar.placeholder = @"";
            break;
    }
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
   switch (selectedScope) {
       case 0: // Title
           self.searchBar.placeholder = @"Enter URL Title";
           self.searchBar.prompt = @"Search by Title";
           break;
       case 1: // PO #
           self.searchBar.placeholder = @"Enter Shortened URL Keyword";
           self.searchBar.prompt = @"Search by Keyword";
           break;
       default:
           self.searchBar.placeholder = @"";
           break;
    }
    
    // Hack to update searchBar
    [self.searchBar resignFirstResponder];
    [self.searchBar becomeFirstResponder];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSArray *linksArray = [[filterArray[0] objectForKey:@"links"] allValues];
    NSPredicate *resultPredicate;
    
    if([scope isEqualToString:@"Keyword"]){
        // If searching by Keyword
        resultPredicate = [NSPredicate predicateWithFormat:@"shorturl contains[cd] %@", searchText];
    } else {
        // Search by title
        resultPredicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", searchText];
    }
    
    searchResults = [linksArray filteredArrayUsingPredicate:resultPredicate];
    
    if(searchText.length > 0) {
        // Number of results as prompt text
        NSInteger resultCount = [searchResults count];
        switch (resultCount) {
            case 1:
                searchBar.prompt = [NSString stringWithFormat:@"%lu Result",(unsigned long)[searchResults count]];
                break;
            default:
                searchBar.prompt = [NSString stringWithFormat:@"%lu Results",(unsigned long)[searchResults count]];
                break;
        }
    } else {
        // Reset prompt text
        if([scope isEqualToString:@"Title"]) {
            searchBar.prompt = @"Search by Title";
        } else if([scope isEqualToString:@"Keyword"]) {
            searchBar.prompt = @"Search by Keyword";
        }
    }
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSString *searchString = controller.searchBar.text;
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = statsTableView.rowHeight;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [super viewWillDisappear:animated];
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"statsTableToWeb"]) {
        [segue.destinationViewController setTableViewShortURL:tableURL];
        [segue.destinationViewController setTableViewLongURL:tableLongURL];
        [segue.destinationViewController setTableViewTitleString:titleString];
    }
}

#pragma mark - Sort Results

- (IBAction)showSortOptions:(id)sender //Define method to show action sheet
{
    if ([UIAlertController class]) {
        NSLog(@"use UIAlertController");
        [self presentViewController:actionSheetAlertController animated:YES completion:nil];
    } else {
        NSLog(@"use UIActionSheet");
        [actionSheet showInView:statsTableView];
    }
}

#pragma mark - UIActionSheet for Sort

- (void)createSortActionSheet {
    // CREATE ACTION SHEET
    NSString *actionSheetTitle = @"SORT"; //Action Sheet Title
    NSString *sortButton1 = @"Recent";
    NSString *sortButton2 = @"Most Clicks";
    NSString *sortButton3 = @"Fewest Clicks";
    NSString *cancelButton = @"Cancel";
    
    if ([UIAlertController class]) {
        NSLog(@"use UIAlertController");
        
        actionSheetAlertController = [UIAlertController
                                      alertControllerWithTitle:actionSheetTitle
                                      message:@"Choose how to sort your links"
                                      preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *recentAction = [UIAlertAction
                                      actionWithTitle:sortButton1
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action)
                                      {
                                          [settings setObject:@"recent" forKey:@"sortOrdersBy"];
                                          [settings setObject:sortButton1 forKey:@"activeSortButtonTitle"];
                                          [settings synchronize];
                                          didSort = YES;
                                          [self updateTable];
                                      }];
        [actionSheetAlertController addAction:recentAction];
        
        UIAlertAction *mostClicksAction = [UIAlertAction
                                       actionWithTitle:sortButton2
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [settings setObject:@"mostClicks" forKey:@"sortOrdersBy"];
                                           [settings setObject:sortButton2 forKey:@"activeSortButtonTitle"];
                                           [settings synchronize];
                                           didSort = YES;
                                           [self updateTable];
                                       }];
        [actionSheetAlertController addAction:mostClicksAction];
        
        UIAlertAction *fewestClicksAction = [UIAlertAction
                                           actionWithTitle:sortButton3
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               [settings setObject:@"fewestClicks" forKey:@"sortOrdersBy"];
                                               [settings setObject:sortButton3 forKey:@"activeSortButtonTitle"];
                                               [settings synchronize];
                                               didSort = YES;
                                               [self updateTable];
                                           }];
        [actionSheetAlertController addAction:fewestClicksAction];
        
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
        actionSheet.title = actionSheetTitle;
        [actionSheet addButtonWithTitle:sortButton1];
        [actionSheet addButtonWithTitle:sortButton2];
        [actionSheet addButtonWithTitle:sortButton3];
        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:cancelButton];
    }
    
    // GA Events
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"statistics_view" // Event category (required)
                                                          action:@"sort_button" // Event action (required)
                                                           label:[NSString stringWithFormat:@"sortedBy_%@", [settings stringForKey:@"sortOrdersBy"]] // Event label
                                                           value:nil] build]]; // Event value
    
    // Log iRate event, and once threshold is reached, show iRate on next launch
    [[iRate sharedInstance] logEvent:YES];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    // Change actionSheet button colors/attributes
    
    for (UIView *subview in self.actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            [button setTitleColor:UIColorFromRGB(0x34495e, 1.0) forState:UIControlStateNormal];
            [button setTitleColor:UIColorFromRGB(0x2c3e50, 1.0) forState:UIControlStateHighlighted];
            
            if([button.titleLabel.text isEqualToString:@"Cancel"]) {
                [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0]];
            } else {
                [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0]];
            }
            
            // Add checkmark to current button
            CGRect rect;
            rect.size = CGSizeMake(20, 20);
            rect.origin.x = 20;
            rect.origin.y = (button.frame.size.height-20)/2;
            UIImageView *checkmark = [[UIImageView alloc] initWithFrame:rect];
            checkmark.image = [UIImage imageNamed:@"check"];
            checkmark.hidden = YES;
            [button addSubview:checkmark];
            if([[settings stringForKey:@"activeSortButtonTitle"] isEqualToString:button.titleLabel.text]) {
                checkmark.hidden = NO;
            } else {
                checkmark.hidden = YES;
            }
            
        }
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Get the name of the current pressed button
    NSString *buttonTitle = [self.actionSheet buttonTitleAtIndex:buttonIndex];
    
    if([buttonTitle isEqualToString:@"Recent"]) {
        [settings setObject:@"recent" forKey:@"sortOrdersBy"];
        [settings setObject:buttonTitle forKey:@"activeSortButtonTitle"];
        [settings synchronize];
        didSort = YES;
        [self updateTable];
    } else if([buttonTitle isEqualToString:@"Most Clicks"]) {
        [settings setObject:@"mostClicks" forKey:@"sortOrdersBy"];
        [settings setObject:buttonTitle forKey:@"activeSortButtonTitle"];
        [settings synchronize];
        didSort = YES;
        [self updateTable];
    } else if([buttonTitle isEqualToString:@"Fewest Clicks"]) {
        [settings setObject:@"fewestClicks" forKey:@"sortOrdersBy"];
        [settings setObject:buttonTitle forKey:@"activeSortButtonTitle"];
        [settings synchronize];
        didSort = YES;
        [self updateTable];
    } else if ([buttonTitle isEqualToString:@"Cancel"]) {
        NSLog(@"Dismiss pressed --> Cancel ActionSheet");
    }
    
    // GA Events
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"statistics_view" // Event category (required)
                                                          action:@"sort_button" // Event action (required)
                                                           label:[NSString stringWithFormat:@"sortedBy_%@", [settings stringForKey:@"sortOrdersBy"]] // Event label
                                                           value:nil] build]]; // Event value
    
    // Log iRate event, and once threshold is reached, show iRate on next launch
    [[iRate sharedInstance] logEvent:YES];
    
}


@end
