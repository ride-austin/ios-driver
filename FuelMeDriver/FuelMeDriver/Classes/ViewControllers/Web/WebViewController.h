//
//  WebViewController.h
//  FuelMe
//
//  Created by Tyson Bunch on 1/11/14.
//  Copyright (c) 2014 FuelMe, Inc. All rights reserved.
//

#import "BaseViewController.h"

@interface WebViewController : BaseViewController

@property(nonatomic, strong) IBOutlet UIWebView *webview;
@property(nonatomic, strong) NSURL *url;
@property(nonatomic, strong) NSString *urlTitle;

- (id)initWithUrl:(NSURL*)url urlTitle:(NSString*)urlTitle;

@end
