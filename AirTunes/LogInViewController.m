//
//  LogInViewController.m
//  AirTunes
//
//  Created by Akash Subramanian on 1/22/16.
//  Copyright © 2016 Akash Subramanian. All rights reserved.
//

#import "LogInViewController.h"
#import <Spotify/Spotify.h>
#import "AppDelegate.h"

@interface LogInViewController ()
@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
//    UIImage *back = [UIImage imageNamed:@"login"];
//    UIImageView *background = [[UIImageView alloc] initWithImage:back];
//    background.frame = self.view.bounds;
//    [self.view addSubview:background];
//    
//    UIView *topView = [[UIView alloc] init];
//    [topView addSubview:_loginButton];
//    [background addSubview:topView];
//  
//    [background bringSubviewToFront:topView];  [background setUserInteractionEnabled:YES];
//    
//    [topView setUserInteractionEnabled:YES];
//    [_loginButton setUserInteractionEnabled:YES];

    
}


- (IBAction)login:(UIButton *)sender {
//    AppDelegate *appdelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
//    [appdelegate performSelector:@selector(openURL:) withObject:loginURL afterDelay:0.1];
    
    [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:loginURL];
    
    [self performSegueWithIdentifier:@"loggedin" sender:self];
   
}

@end
