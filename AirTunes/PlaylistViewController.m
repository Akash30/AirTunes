//
//  MusicPlayerViewController.m
//  AirTunes
//
//  Created by Akash Subramanian on 1/23/16.
//  Copyright © 2016 Akash Subramanian. All rights reserved.
//

#import "PlaylistViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import <Spotify/Spotify.h>
#import <QuartzCore/QuartzCore.h>

#define searchAPIURL "https://api.spotify.com/v1/search?"

@interface PlaylistViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *nowPlayingLabel;
@property (weak, nonatomic) IBOutlet UITableView *playlistTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchSongTextField;

@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) NSString *songId;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *songTitle;
@property (nonatomic, strong) NSMutableDictionary *details;
@property (nonatomic) BOOL isPaused;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSString *currentSongURI;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (strong, nonatomic) UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIButton *playerButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *leaveGroupButton;
@end

@implementation PlaylistViewController
int count = 0;

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationItem.hidesBackButton = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _playlistTableView.delegate = self;
    _playlistTableView.dataSource = self;
    _details = [[NSMutableDictionary alloc] init];
    _queueOfSongs = [[NSMutableArray alloc] init];
    _isPaused = NO;
    _timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updatePlaylist) userInfo:nil repeats:YES];
    
    _leaveGroupButton.layer.cornerRadius = 15;
    _leaveGroupButton.layer.borderWidth = 1;
    _leaveGroupButton.layer.borderColor = [UIColor redColor].CGColor;
    
}
- (IBAction)nextSong:(UIButton *)sender {
    [self playNewSong];
}
- (IBAction)resignKeyboardOnTap:(UITapGestureRecognizer *)sender {
    [_searchSongTextField resignFirstResponder];
}

- (void) updatePlaylist {
    if (![_player isPlaying] && !_queueOfSongs.count == 0 && !_isPaused && count != 0) {
        NSLog(@"%@", @"Going to play next song");
        [self playNewSong];
    } else if (_queueOfSongs.count == 0 && ![_player isPlaying]) {
        [_playerButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PFQuery *query = [[[PFQuery queryWithClassName:@"Songs"] whereKey:@"groupId" equalTo:_groupId] orderByAscending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error == NULL) {
                _queueOfSongs = [[NSMutableArray alloc] init];
                for (PFObject *obj in objects) {
                    NSString *uri = [obj objectForKey:@"spotifyuri"];
                    NSString *title = [obj objectForKey:@"songTitle"];
                    NSString *artist = [obj objectForKey:@"artist"];
                    NSString *imageURL = [obj objectForKey:@"imageurl"];
                    NSMutableDictionary *song = [[NSMutableDictionary alloc] init];
                    [song setObject:uri forKey:@"uri"];
                    [song setObject:title forKey:@"title"];
                    [song setObject:artist forKey:@"artist"];
                    [song setObject:imageURL forKey:@"photo"];
                    [_queueOfSongs addObject:song];
                    
                    
                }
                
            } else {
                NSLog(@"%@", error);
            }
            
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"HERE!");
             [_playlistTableView reloadData];
        });

    });
    
    
}

- (void) playNewSong {
    _currentSongURI = [[_queueOfSongs firstObject] objectForKey:@"uri"];
    NSString *title = [[_queueOfSongs firstObject] objectForKey:@"title"];
    NSString *artist = [[_queueOfSongs firstObject] objectForKey:@"artist"];
    NSLog(@"Now playing %@", title);
    NSString *imageURL = [[_queueOfSongs firstObject] objectForKey:@"photo"];
    AppDelegate *appdelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self playUsingSession: appdelegate.session];
    });
    [self playUsingSession: appdelegate.session];
    if (title == NULL || title.length == 0) {
        _nowPlayingLabel.text = @"Song Name";
    } else {
         _nowPlayingLabel.text = [NSString stringWithFormat:@"%@", title];
    }
    if (artist == NULL || artist.length == 0) {
        _artistLabel.text = @"Artist";
    } else {
        _artistLabel.text = [NSString stringWithFormat:@"%@", artist];

    }
    
   
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        // Switch to Main Queue as we will be updating the UI.
        dispatch_async(dispatch_get_main_queue(), ^{
             _albumImageView.frame = CGRectIntegral(_albumImageView.frame);
            _albumImageView.image = [UIImage imageWithData:imageData];
        });
    });
}

- (IBAction)toggleMusicPlayer:(UIButton *)sender {
    if (count == 0) {
         [_playerButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [self playNewSong];
        count ++;
    } else if ([_player isPlaying] && !_isPaused){
        _isPaused = YES;
        [_playerButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_player setIsPlaying:NO callback:^(NSError *error) {
            NSLog(@"error %@", error);
        }];
    } else if (![_player isPlaying] && _isPaused) {
        _isPaused = NO;
         [_playerButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [_player setIsPlaying:YES callback:^(NSError *error) {
            NSLog(@"error %@", error);
        }];
    }
    
}

- (IBAction)leaveGroup:(UIButton *)sender {
    PFQuery *query = [[PFQuery queryWithClassName:@"Group"] whereKey:@"groupId" equalTo:_groupId];
    PFObject *group = [query getFirstObject];
    int size = [[group objectForKey:@"size"] integerValue];
    size --;
    [group setObject:[NSNumber numberWithInt:size] forKey:@"size"];
    [group saveInBackground];
    [self performSegueWithIdentifier:@"leave" sender:self];
    
}
- (IBAction)addSongToPlaylist:(UIButton *)sender {
    _details = [[NSMutableDictionary alloc] init];
    if (_searchSongTextField.text == NULL || _searchSongTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"No query entered"
                              message:@"Seems like you did not search for anything."
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
        dispatch_async(dispatch_get_main_queue(), ^{[alert show];});
        
    } else {
        
        NSString *url = [NSString stringWithFormat:@"%sq=%@&limit=1&market=US&type=track", searchAPIURL, _searchSongTextField.text];
        url = [url stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSURL *searchURL = [NSURL URLWithString:url];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:searchURL];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                         completionHandler:
          ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
              // See blocks in the lecture slides.
              NSMutableDictionary *dictionary =
              [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
              _songId = [[[[[dictionary objectForKey:@"tracks"] objectForKey:@"items"] firstObject] objectForKey:@"uri"] mutableCopy];
              _songTitle = [[[[[dictionary objectForKey:@"tracks"] objectForKey:@"items"] firstObject] objectForKey:@"name"]mutableCopy];
              _artist = [[[[[[[dictionary objectForKey:@"tracks"] objectForKey:@"items"] firstObject] objectForKey:@"artists"] firstObject] objectForKey:@"name"] mutableCopy];
              
              NSString *imageURL = [[[[[[[dictionary objectForKey:@"tracks"] objectForKey:@"items"] firstObject] objectForKey:@"album"] objectForKey:@"images"] firstObject] objectForKey:@"url"];
              NSLog(@"IMAGE URL IS %@", imageURL);
              
              if (_songId == nil || _songId.length == 0) {
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      UIAlertView *alert = [[UIAlertView alloc]
                                            initWithTitle:@"Cannot find track"
                                            message:@"We cannot find the track you requested."
                                            delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
                      
                      [alert show];
                  });
              } else {
                  //_details = [[NSMutableDictionary alloc] init];
                  [_details setObject:_songId forKey:@"uri"];
                  NSLog(@"URI = %@", _songId);
                  
                  if (_artist == nil || _artist.length == 0) {
                      [_details setObject:@" " forKey:@"artist"];
                  } else {
                      [_details setObject:_artist forKey:@"artist"];
                      NSLog(@"artist = %@", _artist);
                  }
                  if (_songTitle == nil || _songTitle.length == 0) {
                      [_details setObject:@" " forKey:@"title"];
                  } else {
                      [_details setObject:_songTitle forKey:@"title"];
                      NSLog(@"title = %@", _songTitle);
                  }
                  if (imageURL == nil || imageURL.length == 0) {
                      [_details setObject:@" " forKey:@"photo"];
                  } else {
                      [_details setObject:imageURL forKey:@"photo"];
                  }
                  
                  
                  PFObject *request = [PFObject objectWithClassName:@"Songs"];
                  [request setObject:_groupId forKey:@"groupId"];
                  [request setObject:_songId forKey:@"spotifyuri"];
                  [request setObject:_songTitle forKey:@"songTitle"];
                  [request setObject:_artist forKey:@"artist"];
                  [request setObject:imageURL forKey:@"imageurl"];
                  [request saveInBackground];
                  
              }
              
          }] resume];
    }

}

- (IBAction)doneSearchingSong:(UITextField *)sender {
    _searchSongTextField.text = @"";
    // add song to playlist
    _details = [[NSMutableDictionary alloc] init];
    if (_searchSongTextField.text == NULL || _searchSongTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"No query entered"
                                    message:@"Seems like you did not search for anything."
                                    delegate:self
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil, nil];
         dispatch_async(dispatch_get_main_queue(), ^{[alert show];});
        
    } else {
        
        NSString *url = [NSString stringWithFormat:@"%sq=%@&limit=1&market=US&type=track", searchAPIURL, _searchSongTextField.text];
        url = [url stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSURL *searchURL = [NSURL URLWithString:url];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:searchURL];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                         completionHandler:
          ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
              // See blocks in the lecture slides.
              NSMutableDictionary *dictionary =
              [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
              _songId = [[[[[dictionary objectForKey:@"tracks"] objectForKey:@"items"] firstObject] objectForKey:@"uri"] mutableCopy];
              _songTitle = [[[[[dictionary objectForKey:@"tracks"] objectForKey:@"items"] firstObject] objectForKey:@"name"]mutableCopy];
              _artist = [[[[[[[dictionary objectForKey:@"tracks"] objectForKey:@"items"] firstObject] objectForKey:@"artists"] firstObject] objectForKey:@"name"] mutableCopy];
              
              NSString *imageURL = [[[[[[[dictionary objectForKey:@"tracks"] objectForKey:@"items"] firstObject] objectForKey:@"album"] objectForKey:@"images"] firstObject] objectForKey:@"url"];
              NSLog(@"IMAGE URL IS %@", imageURL);
              
              if (_songId == nil || _songId.length == 0) {
                 
                   dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc]
                                              initWithTitle:@"Cannot find track"
                                                    message:@"We cannot find the track you requested."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];

                       [alert show];
                   });
              } else {
                  //_details = [[NSMutableDictionary alloc] init];
                  [_details setObject:_songId forKey:@"uri"];
                  NSLog(@"URI = %@", _songId);
                  
                  if (_artist == nil || _artist.length == 0) {
                      [_details setObject:@" " forKey:@"artist"];
                  } else {
                      [_details setObject:_artist forKey:@"artist"];
                       NSLog(@"artist = %@", _artist);
                  }
                  if (_songTitle == nil || _songTitle.length == 0) {
                      [_details setObject:@" " forKey:@"title"];
                  } else {
                      [_details setObject:_songTitle forKey:@"title"];
                       NSLog(@"title = %@", _songTitle);
                  }
                  if (imageURL == nil || imageURL.length == 0) {
                      [_details setObject:@" " forKey:@"photo"];
                  } else {
                      [_details setObject:imageURL forKey:@"photo"];
                  }
                 
                  
                  PFObject *request = [PFObject objectWithClassName:@"Songs"];
                  [request setObject:_groupId forKey:@"groupId"];
                  [request setObject:_songId forKey:@"spotifyuri"];
                  [request setObject:_songTitle forKey:@"songTitle"];
                  [request setObject:_artist forKey:@"artist"];
                  [request setObject:imageURL forKey:@"imageurl"];
                  [request saveInBackground];
                 
              }
              
              //AppDelegate *appdelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
              //[self playUsingSession: appdelegate.session];
              
//              [_queueOfSongs addObject:_details];
//              NSLog(@"Size = %lu", _queueOfSongs.count);
//              dispatch_async(dispatch_get_main_queue(), ^{[self.playlistTableView reloadData];});
              
              
              
          }] resume];
   
        

    }
}


-(void)playUsingSession:(SPTSession *)session {
    NSLog(@"%@", _currentSongURI);
    // Create a new player if needed
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
        NSLog(@"%@", @"KASDJHKAJSHDKAJSHDKJASHDKJASHDKAJSDHKAJSHD");
    }
    if ([_player loggedIn]) {
        NSLog(@"%@", _currentSongURI);
        NSURL *trackURI = [NSURL URLWithString: [NSString stringWithFormat:@"%@", _currentSongURI]];
        NSLog(@"Please dont be null!! %@", trackURI);
        [self.player playURIs:@[ trackURI ] fromIndex:0 callback:^(NSError *error) {
            if (error != nil) {
                NSLog(@"*** Starting playback got error: %@", error);
                return;
            }
            PFQuery *query = [[[[PFQuery queryWithClassName:@"Songs"] whereKey:@"groupId" equalTo:_groupId] whereKey:@"spotifyuri" equalTo:_currentSongURI] orderByAscending:@"createdAt"];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                if (error == NULL) {
                    if (object != NULL) {
                        [object delete];
                    }
                } else {
                    NSLog(@"%@", error);
                }
            }];
            
        }];
    } else {
        [self.player loginWithSession:session callback:^(NSError *error) {
            if (error != nil) {
                NSLog(@"*** Logging in got error: %@", error);
                NSLog(@"%@", @"oh shiiiiit!");
                return;
            }
            // NSLog(@"song id = %@", _songId);
            NSLog(@"%@", _currentSongURI);
            NSURL *trackURI = [NSURL URLWithString: [NSString stringWithFormat:@"%@", _currentSongURI]];
            NSLog(@"Please dont be null!! %@", trackURI);
            [self.player playURIs:@[ trackURI ] fromIndex:0 callback:^(NSError *error) {
                if (error != nil) {
                    NSLog(@"*** Starting playback got error: %@", error);
                    return;
                }
                PFQuery *query = [[[[PFQuery queryWithClassName:@"Songs"] whereKey:@"groupId" equalTo:_groupId] whereKey:@"spotifyuri" equalTo:_currentSongURI] orderByAscending:@"createdAt"];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    if (error == NULL) {
                        if (object != NULL) {
                            [object delete];
                        }
                    } else {
                        NSLog(@"%@", error);
                    }
                }];
                
            }];
        }];
    }
    
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //[_queueOfSongs addObject:[NSString stringWithString:@"akjsdkjasd"]];
    NSLog(@"%lu", _queueOfSongs.count);
    return [_queueOfSongs count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"infoCell"];
//    if (cell == NULL) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
//    }
    cell.textLabel.text = [[_queueOfSongs objectAtIndex:indexPath.row] objectForKey:@"title"];
    //NSLog(@"%@", [[_queueOfSongs objectAtIndex:indexPath.row] objectForKey:@"title"]);
    cell.detailTextLabel.text = [[_queueOfSongs objectAtIndex:indexPath.row] objectForKey:@"artist"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}




@end
