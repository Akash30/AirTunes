//
//  RequestSongsViewController.m
//  AirTunes
//
//  Created by Akash Subramanian on 1/23/16.
//  Copyright © 2016 Akash Subramanian. All rights reserved.
//

#import "RequestSongsViewController.h"
#import "AppDelegate.h"
#import <Spotify/Spotify.h>
#define searchAPIURL "https://api.spotify.com/v1/search?"

@interface RequestSongsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) NSString *songId;
@end

@implementation RequestSongsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _searchResultsTableView.delegate = self;
    _searchResultsTableView.dataSource = self;
}

- (IBAction)searchSongs:(UITextField *)sender {
    NSString *url = [NSString stringWithFormat:@"%sq=%@&limit=1&market=US&type=track", searchAPIURL, _requestSongTextField.text];
    url = [url stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSLog(@"%@", url);
    NSURL *searchURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:searchURL];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:
      ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
          // See blocks in the lecture slides.
          NSMutableDictionary *dictionary =
          [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
          //NSLog(@"%@", dictionary);
//          _songId = [[[[dictionary objectForKey:@"tracks"] objectForKey:@"items"] firstObject] objectForKey:@"id"] ;
//          for (NSDictionary *obj in [[dictionary objectForKey:@"tracks"] objectForKey:@"items"]) {
//              if ([obj objectForKey:@"type"])
//          }
          _songId = [[[[dictionary objectForKey:@"tracks"] objectForKey:@"items"] firstObject] objectForKey:@"uri"];
          
          AppDelegate *appdelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
          [self playUsingSession: appdelegate.session];
          
          //          dispatch_async(dispatch_get_main_queue(), ^{[self.tableView reloadData];});
          
      }] resume];

}

-(void)playUsingSession:(SPTSession *)session {
    
    // Create a new player if needed
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
    }
    
    [self.player loginWithSession:session callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** Logging in got error: %@", error);
            return;
        }
        NSLog(@"song id = %@", _songId);
        NSURL *trackURI = [NSURL URLWithString: [NSString stringWithFormat:@"%@", _songId]];
        [self.player playURIs:@[ trackURI ] fromIndex:0 callback:^(NSError *error) {
            if (error != nil) {
                NSLog(@"*** Starting playback got error: %@", error);
                return;
            }
        }];
    }];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_list count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == NULL) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
