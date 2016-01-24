//
//  RequestSongsViewController.h
//  AirTunes
//
//  Created by Akash Subramanian on 1/23/16.
//  Copyright © 2016 Akash Subramanian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestSongsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *requestSongTextField;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;

@end
