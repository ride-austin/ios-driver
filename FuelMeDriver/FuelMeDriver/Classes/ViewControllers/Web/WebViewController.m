//
//  WebViewController.m
//  FuelMe
//
//  Created by Tyson Bunch on 1/11/14.
//  Copyright (c) 2014 FuelMe, Inc. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

- (id)initWithUrl:(NSURL*)url urlTitle:(NSString*)urlTitle {
    self = [super init];
    if (self) {
        self.url = url;
        self.urlTitle = urlTitle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.urlTitle;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webview loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

@end
