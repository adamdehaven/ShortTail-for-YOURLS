/* ==========================================================
 * STStatsTableViewController.h
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
#import "MBProgressHUD.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface STStatsTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate, UIActionSheetDelegate> {
    MBProgressHUD *HUD;
}

@property (retain, nonatomic) IBOutlet UITableView *statsTableView;
@property (retain, nonatomic) IBOutlet NSDictionary *API;
@property (strong, nonatomic) IBOutlet NSString *tableURL;
@property (strong, nonatomic) IBOutlet NSString *tableLongURL;
@property (strong, nonatomic) IBOutlet NSString *titleString;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property(nonatomic,getter=isToolbarHidden) BOOL toolbarHidden;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sortButton;
@property (strong, nonatomic) IBOutlet UIActionSheet *actionSheet;
@property (strong, nonatomic) IBOutlet UIAlertController *actionSheetAlertController;

@end
