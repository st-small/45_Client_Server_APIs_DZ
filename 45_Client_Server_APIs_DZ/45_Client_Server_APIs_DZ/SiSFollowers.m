//
//  SiSFollowers.m
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 10.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSFollowers.h"
#import "SiSServerManager.h"
#import "SiSFriend.h"
#import "UIImageView+AFNetworking.h"
#import "SiSDefaultFrinedCell.h"
#import "SiSFriendDetails.h"

@interface SiSFollowers () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (assign, nonatomic) BOOL loadingData;

@property (strong, nonatomic) NSMutableArray* followersArray;

@end

static NSInteger followersInRequest = 20;

@implementation SiSFollowers

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.followersArray = [NSMutableArray array];
    self.loadingData = YES;
    
    [self getFollowersFromServer];

}

#pragma mark - API

- (void) getFollowersFromServer {
    
    [[SiSServerManager sharedManager]
     getFollowersOrSubsriptionsWithMethod:@"users.getFollowers"
     ForUserID:self.friendID
     WithOffset:[self.followersArray count]
     count:followersInRequest
     onSuccess:^(NSArray *objects) {
         
         [self.followersArray addObjectsFromArray:objects];
         [self.tableView reloadData];
         self.loadingData = NO;
         
     } onFailure:^(NSError *error) {
         NSLog(@"error = %@", [error localizedDescription]);
         
     }];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (!self.loadingData)
        {
            self.loadingData = YES;
            [self getFollowersFromServer];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.followersArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"followerCell";
    
    SiSDefaultFrinedCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[SiSDefaultFrinedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    SiSFriend* follower = [self.followersArray objectAtIndex:indexPath.row];
    NSLog(@"%@", follower.friendID);
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", follower.firstName, follower.lastName];
    
    NSString* onlineStatusText;
    UIColor* onlineStatusColor;
    
    if (follower.isOnline) {
        onlineStatusText = @"Доступен";
        onlineStatusColor = [UIColor colorWithRed:10.0f/255.0f green:142.0f/255.0f blue:78.0/255.0f alpha:1.0];
    } else {
        onlineStatusText = @"Отсутствует";
        onlineStatusColor = [UIColor redColor];
    }
    
    cell.isOnline.text = onlineStatusText;
    cell.isOnline.textColor = onlineStatusColor;
    
    NSURLRequest* request = [NSURLRequest requestWithURL:follower.image100URL
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                         timeoutInterval:60];
    
    __weak SiSDefaultFrinedCell* weakCell = cell;
    
    cell.photoView.image = nil;
    
    [cell.photoView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest* request, NSHTTPURLResponse* response, UIImage* image) {
                                       
                                       [UIView transitionWithView:weakCell.photoView
                                                         duration:0.3f
                                                          options:UIViewAnimationOptionTransitionCrossDissolve
                                                       animations:^{
                                       
                                               weakCell.photoView.image = image;
                                               
                                               CALayer* imageLayer = weakCell.photoView.layer;
                                               [imageLayer setCornerRadius:imageLayer.frame.size.width/2];
                                               [imageLayer setMasksToBounds:YES];
                                                       
                                                       } completion:NULL];

                                       
                                   } failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error) {
                                       NSLog(@"Something bad...");
                                   }];
    
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 85;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

#pragma mark - Segues

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"FriendDetails"]) {
        NSIndexPath* selectedIndexPath = [self.tableView indexPathForCell:sender];
        SiSFriend* follower = [self.followersArray objectAtIndex:selectedIndexPath.row];
        
        SiSFriendDetails* vc = [segue destinationViewController];
        vc.friend = follower;
        vc.friendID = follower.uid;
        
        NSLog(@"%@", follower.uid);
        
    }
}

@end
