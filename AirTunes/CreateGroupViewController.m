//
//  CreateGroupViewController.m
//  AirTunes
//
//  Created by Akash Subramanian on 1/23/16.
//  Copyright © 2016 Akash Subramanian. All rights reserved.
//

#import "CreateGroupViewController.h"
#import <Parse/Parse.h>
#import "PlaylistViewController.h"

@interface CreateGroupViewController () <UITextFieldDelegate>

@end

@implementation CreateGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _groupNameTextField.delegate = self;
}
- (IBAction)createGroup:(UIButton *)sender {
    if (_groupNameTextField.text != NULL || _groupNameTextField.text.length > 0) {
        PFQuery *query = [[PFQuery queryWithClassName:@"Group"] whereKey:@"groupId" equalTo:_groupNameTextField.text];
        
        if ([query countObjects] == 0) {
            PFObject *newGroup = [PFObject objectWithClassName:@"Group"];
            [newGroup setObject:_groupNameTextField.text forKey:@"groupId"];
            [newGroup setObject: [NSNumber numberWithInt:1]     forKey:@"size"];
            [newGroup saveInBackground];
            [self performSegueWithIdentifier:@"play" sender:self];
        } else {
            // action to inform user that group id is taken.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The group name that you chose already exists!"
                                                            message:@"Try another name." delegate:NULL
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

- (IBAction)joinGroup:(UIButton *)sender {
    if (_groupNameTextField.text != NULL || _groupNameTextField.text.length > 0) {
        PFQuery *query = [[PFQuery queryWithClassName:@"Group"] whereKey:@"groupId" equalTo:_groupNameTextField.text];
        if ([query countObjects] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No group with that name exists!"
                                                            message:@"Are you sure you spelt it right?" delegate:NULL
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];

        } else {
            PFQuery *query = [[PFQuery queryWithClassName:@"Group"] whereKey:@"groupId" equalTo:_groupNameTextField.text];
            PFObject *group = [query getFirstObject];
            int size = [[group objectForKey:@"size"] integerValue];
            size ++;
            [group setObject:[NSNumber numberWithInt:size] forKey:@"size"];
            [group saveInBackground];
            [self performSegueWithIdentifier:@"play" sender:self];
            

        }

    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self.view endEditing:YES];
    return YES;
}


- (void)keyboardDidShow:(NSNotification *)notification
{
    // Assign new frame to your view
    [self.view setFrame:CGRectMake(0,-80,320,460)]; //here taken -20 for example i.e. your view will be scrolled to -20. change its value according to your requirement.
    
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [self.view setFrame:CGRectMake(0,0,320,460)];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"play"]) {
        PlaylistViewController *mvc = (PlaylistViewController *)segue.destinationViewController;
        mvc.groupId = _groupNameTextField.text;
    }
}

@end