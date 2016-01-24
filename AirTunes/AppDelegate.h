//
//  AppDelegate.h
//  AirTunes
//
//  Created by Akash Subramanian on 1/22/16.
//  Copyright © 2016 Akash Subramanian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) SPTSession *session;


@end

