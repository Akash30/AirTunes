//
//  MusicPlayerViewController.h
//  AirTunes
//
//  Created by Akash Subramanian on 1/23/16.
//  Copyright © 2016 Akash Subramanian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistViewController : UIViewController
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSMutableArray *queueOfSongs;
@end
