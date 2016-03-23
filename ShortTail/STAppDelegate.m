/* ==========================================================
 * STAppDelegate.m
 * ShortTail for YOURLS v1.6.5
 * https://github.com/adamdehaven/ShortTail
 *
 * Author: Adam DeHaven ( Twitter, GitHub: @adamdehaven )
 * http://adamdehaven.com/
 *
 *
 * Copyright (c) 2016 Adam Dehaven. All rights reserved.
 * ========================================================== */

#import "STAppDelegate.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "iRate.h"

#define UIColorFromRGB(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

@implementation STAppDelegate {
    NSUserDefaults *settings;
    // UIImageView *coverSplash;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    settings = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.adamdehaven.ShortTail"];
    [settings synchronize];
    
    // Dark keyboard for app
    [[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDark];
    
    // Set Navigation Controller Font
    NSMutableDictionary *navigationControllerTitleFont = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [navigationControllerTitleFont setValue:[UIFont fontWithName:@"HelveticaNeue-Light" size:20] forKey:NSFontAttributeName];
    [[UINavigationBar appearance] setTitleTextAttributes:navigationControllerTitleFont];
    
    // Set Back Button Font
    NSMutableDictionary *backButtonFont = [NSMutableDictionary dictionaryWithDictionary: [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal]];
    [backButtonFont setValue:[UIFont fontWithName:@"HelveticaNeue-Light" size:18] forKey:NSFontAttributeName];
    [[UIBarButtonItem appearance] setTitleTextAttributes:backButtonFont forState:UIControlStateNormal];
    
    [self setDefaults];
    
    /*
     * Google Analytics iOS SDK v3
     */
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 10;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelWarning];
    
    // Initialize tracker.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-48305125-1"];
    
    [tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"App"
                                                           action:@"launched"
                                                            label:nil
                                                            value:nil] set:@"start" forKey:kGAISessionControl] build]];
    
    return YES;
}

- (void) setDefaults {
    // this function detects what is the CFBundle version of this application and set it in the settings bundle
    // transfer the current version number into the defaults so that this correct value will be displayed when the user visit settings page later
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [settings setObject:version forKey:@"version"];
    NSLog(@"ShortTail for YOURLS v%@",[settings objectForKey:@"version"]);
    
    // Set accentColor
    if(![settings objectForKey:@"accentColor"]){
        UIColor *accentColor = UIColorFromRGB(0xe67e22, 1.0);
        NSData *accentColorData = [NSKeyedArchiver archivedDataWithRootObject:accentColor];
        [settings setObject:accentColorData forKey:@"accentColor"];
    }
    // Set errorColor
    if(![settings objectForKey:@"errorColor"]){
        UIColor *errorColor = UIColorFromRGB(0xe67e22, 0.2);
        NSData *errorColorData = [NSKeyedArchiver archivedDataWithRootObject:errorColor];
        [settings setObject:errorColorData forKey:@"errorColor"];
    }
    // Set colorControl Segmented Control Index
    if(![settings integerForKey:@"colorControlIndex"]){
        [settings setInteger:0 forKey:@"colorControlIndex"];
    }
    [settings synchronize];
}

// Handle custom URL Scheme
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *passedURLToApp = [url absoluteString];
    NSLog(@"passedURLToApp: %@",passedURLToApp);
    
    if([passedURLToApp hasPrefix:@"shorttail://"] || [passedURLToApp hasPrefix:@"ShortTail://"]) {
        NSString *passedURL = [passedURLToApp stringByReplacingOccurrencesOfString:@"shorttail://" withString:@""];
        passedURL = [passedURL stringByReplacingOccurrencesOfString:@"ShortTail://" withString:@""];
        passedURL = [passedURL stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        passedURL = [passedURL stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        passedURL = [passedURL stringByReplacingOccurrencesOfString:@"http//" withString:@""];
        passedURL = [passedURL stringByReplacingOccurrencesOfString:@"https//" withString:@""];
    
        [settings setObject:passedURL forKey:@"savedPassedURL"];
        [settings synchronize];
    
        NSLog(@"passedURL: %@",[settings objectForKey:@"savedPassedURL"]);
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // Hide all keyboards
    [self.window endEditing:YES];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    /*coverSplash = [[UIImageView alloc]initWithFrame:[self.window frame]];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if(screenBounds.size.height < 568){
        [coverSplash setImage:[UIImage imageNamed:@"cover-splash"]];
    } else {
        [coverSplash setImage:[UIImage imageNamed:@"cover-splash-568h"]];
    }
    [self.window addSubview:coverSplash];*/
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [settings synchronize];
    
    /*if(coverSplash != nil) {
        [coverSplash removeFromSuperview];
        coverSplash = nil;
    }*/
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - iRate delegate methods

+ (void)initialize
{
	[iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    
    //set events count before prompt
    [iRate sharedInstance].eventsUntilPrompt = 50;
    
    //disable minimum day limit and reminder periods
    [iRate sharedInstance].daysUntilPrompt = 2;
    [iRate sharedInstance].remindPeriod = 8; // remind in 3 days
    
    [iRate sharedInstance].rateButtonLabel = @"Rate ShortTail";
    [iRate sharedInstance].remindButtonLabel = @"Maybe Next Week";
    [iRate sharedInstance].cancelButtonLabel = @"No Thanks";
    [iRate sharedInstance].promptForNewVersionIfUserRated = YES;
    [iRate sharedInstance].verboseLogging = NO;
    
    // [iRate sharedInstance].previewMode = NO;
}

- (void)iRateDidDetectAppUpdate {
    [[iRate sharedInstance] setDeclinedThisVersion:NO]; // Reset Declined if detected new version
}

- (void)iRateUserDidRequestReminderToRateApp
{
    NSLog(@"iRateUserDidRequestReminderToRateApp");
    
    //reset event count
    [iRate sharedInstance].eventCount = 0;
    
    NSString *user;
    if([settings stringForKey:@"savedBaseUrl"]){
        user = [NSString stringWithFormat:@"%@_iRateUserDidRequestReminderToRateApp", [settings stringForKey:@"savedBaseUrl"]];
    } else {
        user = @"User";
    }
    
    // GA Events
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"iRate" // Event category (required)
                                                          action:@"iRateUserDidRequestReminderToRateApp" // Event action (required)
                                                           label:user // Event label
                                                           value:nil] build]]; // Event value
}

#pragma mark - iRate Event Tracking

- (void)iRateDidPromptForRating {
    NSLog(@"iRateDidPromptForRating");
    
    NSString *user;
    if([settings stringForKey:@"savedBaseUrl"]){
        user = [NSString stringWithFormat:@"%@_iRateDidPromptUserForRating", [settings stringForKey:@"savedBaseUrl"]];
    } else {
        user = nil;
    }
    
    // GA Events
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"iRate" // Event category (required)
                                                          action:@"iRateDidPromptForRating" // Event action (required)
                                                           label:user // Event label
                                                           value:nil] build]]; // Event value
}

- (void)iRateUserDidAttemptToRateApp {
    NSLog(@"iRateUserDidAttemptToRateApp");
    
    NSString *user;
    if([settings stringForKey:@"savedBaseUrl"]){
        user = [NSString stringWithFormat:@"%@_iRateUserDidAttemptToRateApp", [settings stringForKey:@"savedBaseUrl"]];
    } else {
        user = nil;
    }
    
    // GA Events
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"iRate" // Event category (required)
                                                          action:@"iRateUserDidAttemptToRateApp" // Event action (required)
                                                           label:user // Event label
                                                           value:nil] build]]; // Event value
}

- (void)iRateUserDidDeclineToRateApp {
    NSLog(@"iRateUserDidDeclineToRateApp");
    
    NSString *user;
    if([settings stringForKey:@"savedBaseUrl"]){
        user = [NSString stringWithFormat:@"%@_iRateUserDidDeclineToRateApp", [settings stringForKey:@"savedBaseUrl"]];
    } else {
        user = nil;
    }
    
    // GA Events
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"iRate" // Event category (required)
                                                          action:@"iRateUserDidDeclineToRateApp" // Event action (required)
                                                           label:user // Event label
                                                           value:nil] build]]; // Event value
}


@end
