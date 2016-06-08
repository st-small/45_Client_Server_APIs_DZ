//
//  SiSFriendDetails.m
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 06.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSFriendDetails.h"
#import "SiSServerManager.h"
#import "UIImageView+AFNetworking.h"
#import "SiSFriendsTableViewController.h"
#import "SiSInfoCellTableViewCell.h"

@interface SiSFriendDetails () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (assign, nonatomic) BOOL loadingData;

@end

@implementation SiSFriendDetails

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", self.friend.firstName);
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", self.friend.firstName, self.friend.lastName];
    
    self.loadingData = YES;
    
    [self getFriendInfoWithFriendID:self.friend.friendID];
    
}

#pragma mark - API

- (void) getFriendInfoWithFriendID:(NSString*)friendID {
    
    [[SiSServerManager sharedManager]
     getFriendInfoWithId:friendID
     onSuccess:^(SiSFriend* friend) {
         
         self.friend = friend;
        
        [self.tableView reloadData];
     
     } onFailure:^(NSError *error) {
         
        NSLog(@"error = %@", [error localizedDescription]);
         
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* infoIdentifier = @"infocell";
            
    SiSInfoCellTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:infoIdentifier];
    
    if (!cell) {
        cell = [[SiSInfoCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infoIdentifier];
    }
    
    cell.nameLabel.text = self.friend.lastName;
    
    NSLog(@"%@", self.friend.lastName);
    
    [cell.photoView setImageWithURL:self.friend.image200URL placeholderImage:[UIImage imageNamed:@"preview.gif"]];
    cell.photoView.layer.cornerRadius = cell.photoView.frame.size.width / 2;
    cell.photoView.layer.masksToBounds = YES;
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


@end
