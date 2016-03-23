/* ==========================================================
 * ShareViewController.m
 * ShortTail for YOURLS v1.6.5
 * https://github.com/adamdehaven/ShortTail
 *
 * Author: Adam DeHaven ( Twitter, GitHub: @adamdehaven )
 * http://adamdehaven.com/
 *
 *
 * Copyright (c) 2016 Adam Dehaven. All rights reserved.
 * ========================================================== */

#import "ShareViewController.h"

#define UIColorFromRGB(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

@interface ShareViewController ()

@end

@implementation ShareViewController {
    NSUserDefaults *settings;
    NSString *urlProtocol;
    NSString *baseURL;
    NSString *signature;
    NSString *urlString;
    NSString *returnedKeyword;
    UILabel *shortenLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    settings = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.adamdehaven.ShortTail"];
    
    [self constructSheet];
}

- (BOOL)isContentValid
{
    NSInteger textLength = [[self.contentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
    NSInteger charactersRemaining = 25 - textLength;
    self.charactersRemaining = @(charactersRemaining);
    
    if ([self userIsLoggedIn] && charactersRemaining >= 0) {
        return YES;
    } else {
        if (![self userIsLoggedIn]) {
            self.charactersRemaining = @(0);
        }
        return NO;
    }
    
    return NO;
}

- (BOOL)userIsLoggedIn
{
    urlProtocol = [settings stringForKey:@"savedProtocol"];
    baseURL = [settings stringForKey:@"savedBaseUrl"];
    signature = [settings stringForKey:@"savedSignature"];
    
    if (urlProtocol == nil || baseURL == nil || signature == nil) {
        return NO;
    } else {
        return YES;
    }
}

- (void)constructSheet {
    
    [self.navigationController.navigationItem.rightBarButtonItem setAccessibilityLabel:nil];
    [self.navigationController.navigationItem.rightBarButtonItem setAccessibilityHint:nil];
    [self.navigationController.navigationItem.rightBarButtonItem setTitle:nil];
    
    // Shorten Label
    shortenLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.navigationController.navigationBar.bounds.size.width - (self.navigationController.navigationBar.bounds.size.width / 4), (self.navigationController.navigationBar.bounds.size.height - 22) / 2, 68, 22)];
    [shortenLabel setText:@"Shorten"];
    [shortenLabel setTextColor:UIColorFromRGB(0xe67e22, 1.0)];
    [shortenLabel setBackgroundColor:UIColorFromRGB(0x34495e, 1.0)];
    [shortenLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [shortenLabel setUserInteractionEnabled:NO];
    [shortenLabel setAccessibilityLabel:@"Shorten"];
    [shortenLabel setAccessibilityHint:@"Shortens the URL"];
    [self.navigationController.navigationBar addSubview:shortenLabel];
    
    // shortenLabel constraints --------------
    [shortenLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Right X
    NSLayoutConstraint *postButtonXConstraint =
    [NSLayoutConstraint constraintWithItem:shortenLabel
                                 attribute:NSLayoutAttributeRightMargin
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.navigationController.navigationBar
                                 attribute:NSLayoutAttributeRightMargin
                                multiplier:1.0
                                  constant:-10.0];
    [self.view addConstraint:postButtonXConstraint];
    
    // Center Vertically
    NSLayoutConstraint *postButtonCenterYConstraint =
    [NSLayoutConstraint constraintWithItem:shortenLabel
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.navigationController.navigationBar
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.0
                                  constant:0.0];
    [self.view addConstraint:postButtonCenterYConstraint];
    
    NSLayoutConstraint *postButtonWidthConstraint =
    [NSLayoutConstraint constraintWithItem:shortenLabel
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:68.0];
    [shortenLabel addConstraint:postButtonWidthConstraint];
    
    NSLayoutConstraint *postButtonHeightConstraint =
    [NSLayoutConstraint constraintWithItem:shortenLabel
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:22.0];
    [shortenLabel addConstraint:postButtonHeightConstraint];
    
    
    // logo image
    UIImageView *navImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.navigationController.navigationBar.bounds.size.width / 2) - 25, (self.navigationController.navigationBar.bounds.size.height - 25) / 2, 25, 25)];
    [navImageView setImage:[[UIImage imageNamed:@"share-squirrel"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    //[navImageView setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar addSubview:navImageView];
    
    // navImageView constraints --------------
    [navImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Center Horizontally
    NSLayoutConstraint *centerXConstraint =
    [NSLayoutConstraint constraintWithItem:navImageView
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.navigationController.navigationBar
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0
                                  constant:0.0];
    [self.view addConstraint:centerXConstraint];
    
    // Center Vertically
    NSLayoutConstraint *centerYConstraint =
    [NSLayoutConstraint constraintWithItem:navImageView
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.navigationController.navigationBar
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.0
                                  constant:0.0];
    [self.view addConstraint:centerYConstraint];
    
    NSLayoutConstraint *widthConstraint =
    [NSLayoutConstraint constraintWithItem:navImageView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:25.0];
    [navImageView addConstraint:widthConstraint];
    
    NSLayoutConstraint *heightConstraint =
    [NSLayoutConstraint constraintWithItem:navImageView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:25.0];
    [navImageView addConstraint:heightConstraint];
    
    if ([self userIsLoggedIn]) {
        [shortenLabel setUserInteractionEnabled:NO]; // Don't allow touch so that touch will actually be sent to hidden post button below
        [shortenLabel setTextColor:UIColorFromRGB(0xe67e22, 1.0)];
        [self.textView setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]];
        [self.textView setText:nil];
        self.charactersRemaining = @(25);
        [self.textView setTextColor:UIColorFromRGB(0x34495e, 1.0)];
        [self.textView setTintColor:UIColorFromRGB(0x34495e, 1.0)];
        [self.textView setUserInteractionEnabled:YES];
        [self.textView setAccessibilityLabel:@"Keyword"];
        [self.textView setAccessibilityHint:@"Enter keyword for URL to shorten."];
    } else {
        [shortenLabel setUserInteractionEnabled:YES]; // Allow touch so that touch will not be sent to hidden post button below
        [shortenLabel setTextColor:UIColorFromRGB(0x546270, 1.0)];
        [self.textView setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14]];
        [self.textView setText:@"Please open the ShortTail app to configure your settings."];
        [self.textView setTextColor:UIColorFromRGB(0xe74c3c, 1.0)];
        [self.textView setTintColor:[UIColor clearColor]];
        [self.textView setUserInteractionEnabled:NO];
        [self.textView setAccessibilityLabel:@"Please open the ShortTail app to configure your settings."];
        [self.textView setAccessibilityHint:nil];
        self.charactersRemaining = @(0);
        [settings setBool:YES forKey:@"extensionNeedsLogin"];
        [settings synchronize];
    }
    
    [self setupUI];
}

- (void)setupUI {
    [self.navigationController.navigationBar setBackgroundColor:UIColorFromRGB(0x34495e, 1.0)];
    [self.navigationController.navigationBar setTintColor:UIColorFromRGB(0xe67e22, 1.0)];
    // textView
    [self setPlaceholder:@"Enter Keyword for URL\n(optional)"];
    [self.textView setKeyboardAppearance:UIKeyboardAppearanceLight];
    [self.textView setReturnKeyType:UIReturnKeyDone];
    [self.textView setKeyboardType:UIKeyboardTypeNamePhonePad];
    [self.textView setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.textView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.textView.superview.superview setBackgroundColor:[UIColor whiteColor]];
    [self.textView.superview.superview.superview setUserInteractionEnabled:NO];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    // limit maxLinksField to 25 characters
    if(textView == self.textView){
        if([text isEqualToString:@"\n"]) {
            return NO;
        }
        NSUInteger newLength = [textView.text length] + [text length] - range.length;
        return (newLength > 25) ? NO : YES;
    } else {
        return YES;
    }
}

- (void)didSelectPost {
    
    // Change shortenLabel color
    [shortenLabel setTextColor:UIColorFromRGB(0x575351, 1.0)];

    NSExtensionItem *item = self.extensionContext.inputItems.firstObject;
    NSItemProvider *itemProvider = item.attachments.firstObject;
    
    // NSString *providedTitle = [item.attributedContentText string]; // Default title
    NSString *providedKeyword = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // Text entered into share sheet
    
    //NSLog(@"items: %@",[itemProvider registeredTypeIdentifiers]);
    
    if ([itemProvider hasItemConformingToTypeIdentifier:@"public.url"]) {
        
        NSLog(@"URL");
        
        [itemProvider loadItemForTypeIdentifier:@"public.url" options:nil completionHandler:^(NSURL *urlItem, NSError *error) {
            urlString = urlItem.absoluteString; // URL to share
            
            NSLog(@"urlString: %@",urlString);
            
            if (![urlString hasPrefix:[NSString stringWithFormat:@"%@%@", urlProtocol, baseURL]]) {
                NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/yourls-api.php", urlProtocol, baseURL]];
                NSMutableURLRequest *apiRequest = [NSMutableURLRequest requestWithURL:apiURL];
                NSString *postData = [NSString stringWithFormat:@"signature=%@&action=shorturl&format=json&url=%@&keyword=%@", signature, urlString, providedKeyword];
                [apiRequest setHTTPMethod:@"POST"];
                [apiRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
                
                
                //NSURLSession *session = [self configureMySession];
                //[[session dataTaskWithRequest:apiRequest] resume];
                
                NSURLSession *session = [NSURLSession sharedSession];
                [[session dataTaskWithRequest:apiRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    
                    if (!error) {
                        NSDictionary *API = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        // get the URL keyword, and errors if any
                        NSString *statusMsg = API[@"status"];
                        returnedKeyword = API[@"url"][@"keyword"];
                        
                        if([statusMsg isEqualToString:@"success"] && returnedKeyword) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                NSString *shortenedURL = [NSString stringWithFormat:@"%@%@/%@", urlProtocol, baseURL, returnedKeyword];
                                NSLog(@"success - shortenedURL: %@", shortenedURL);
                                [pasteboard setURL:[NSURL URLWithString:shortenedURL]];
                                
                                [self.extensionContext completeRequestReturningItems:nil completionHandler:^(BOOL expired) {
                                    // On completion, copy URL to pasteboard
                                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                    NSString *shortenedURL = [NSString stringWithFormat:@"%@%@/%@", urlProtocol, baseURL, returnedKeyword];
                                    [pasteboard setURL:[NSURL URLWithString:shortenedURL]];
                                }];
                            });
                        }
                    }
                }] resume];
            }
        }];

    } else {
        [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
    }
    
}

/*
- (NSURLSession *) configureMySession {
    NSURLSession *mySession = [NSURLSession sharedSession];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.adamdehaven.ShortTail.backgroundsession"];
    // To access the shared container you set up, use the sharedContainerIdentifier property on your configuration object.
    config.sharedContainerIdentifier = @"group.com.adamdehaven.ShortTail";
    mySession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    return mySession;
}
*/

@end
