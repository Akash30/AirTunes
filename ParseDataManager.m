//
//  ParseDataManager.m
//  Chatter
//
//  Created by Josh Pearlstein on 11/3/15.
//  Copyright © 2015 SEAS. All rights reserved.
//

#import "ParseDataManager.h"

#import <Parse/Parse.h>


@implementation ParseDataManager

+ (ParseDataManager *)sharedManager {
  static ParseDataManager *obj;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    obj = [[ParseDataManager alloc] init];
    /// TODO: Any other setup you'd like to do.
  });
  return obj;
}

- (BOOL)isUserLoggedIn {
  return [[PFUser currentUser] isAuthenticated];
}

-(BOOL)signUpUser:(NSString *)name Password:(NSString *)password email:(NSString *)email {
    PFUser *newUser = [[PFUser user] init];
    newUser.username = name;
    newUser.password = password;
    newUser.email = email;
//    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//        if (succeeded) {
////            [[[SignupViewController alloc] init] performSegueWithIdentifier:@"authenticated" sender:nil];
//        } else {
////            NSString *errorMessage = [[error userInfo] objectForKey:@"error"];
////            UIAlertController *alert =
////                [UIAlertController alertControllerWithTitle:@"Sign Up Failed"
////                                                    message:errorMessage
////                                             preferredStyle:UIAlertControllerStyleAlert];
////            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
////            [alert addAction:ok];
////            [[[SignupViewController alloc] init] presentViewController:alert animated:YES completion:nil];
    
        //}
   // }];
    return [newUser signUp];
}

- (void)loadMostRecentMessagesWithCallback:(void (^)(NSMutableArray *))callback {
// TODO: Load data here.
    PFQuery *query = [PFQuery queryWithClassName:@"Chats"];
    query.limit = 400;
    [query orderByAscending:@"createdAt"];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
      callback([objects mutableCopy]);
    }
  }];
}


@end
