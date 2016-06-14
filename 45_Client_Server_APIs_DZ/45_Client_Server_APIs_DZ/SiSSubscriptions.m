//
//  SiSSubscriptions.m
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 10.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSSubscriptions.h"
#import "SiSServerManager.h"
#import "SiSFriend.h"
#import "SiSGroup.h"
#import "UIImageView+AFNetworking.h"
#import "SiSDefaultFrinedCell.h"
#import "SiSFriendDetails.h"

@interface SiSSubscriptions () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (assign, nonatomic) BOOL loadingData;

@property (strong, nonatomic) NSMutableArray* subscriptionsArray;

@end

static NSInteger subscriptionsInRequest = 20;

@implementation SiSSubscriptions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.subscriptionsArray = [NSMutableArray array];
    self.loadingData = YES;
    
    [self getSubscriptionsFromServer];
    
}

#pragma mark - API

- (void) getSubscriptionsFromServer {
    
    [[SiSServerManager sharedManager]
     getFollowersOrSubsriptionsWithMethod:@"users.getSubscriptions"
     ForUserID:self.friendID
     WithOffset:[self.subscriptionsArray count]
     count:subscriptionsInRequest
     onSuccess:^(NSArray *objects) {
         
         [self.subscriptionsArray addObjectsFromArray:objects];
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
            [self getSubscriptionsFromServer];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.subscriptionsArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* pageIdentifier = @"subscriptionPageCell";
    static NSString* personIdentifier = @"subscriptionPersonCell";
    
    id subscription = [self.subscriptionsArray objectAtIndex:indexPath.row];
    
    SiSDefaultFrinedCell* cell;
    NSURLRequest* request;
    
    if ([subscription isKindOfClass:[SiSFriend class]]) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:personIdentifier];
        
        if (!cell) {
            cell = [[SiSDefaultFrinedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:personIdentifier];
        }
        
        SiSFriend* personSubscr = (SiSFriend*) subscription;
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", personSubscr.firstName, personSubscr.lastName];
        
        NSString* onlineStatusText;
        UIColor* onlineStatusColor;
        
        if (personSubscr.isOnline) {
            onlineStatusText = @"Доступен";
            onlineStatusColor = [UIColor colorWithRed:10.0f/255.0f green:142.0f/255.0f blue:78.0/255.0f alpha:1.0];
        } else {
            onlineStatusText = @"Отсутствует";
            onlineStatusColor = [UIColor redColor];
        }
        
        cell.isOnline.text = onlineStatusText;
        cell.isOnline.textColor = onlineStatusColor;
        
        request = [NSURLRequest requestWithURL:personSubscr.image100URL
                                   cachePolicy:NSURLRequestReturnCacheDataElseLoad
                               timeoutInterval:60];
    
    } else if ([subscription isKindOfClass:[SiSGroup class]]) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:pageIdentifier];
        
        
        if (!cell) {
            cell = [[SiSDefaultFrinedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pageIdentifier];
        }
        
        
        SiSGroup* pageSubscription = (SiSGroup*) subscription;
        
        cell.nameLabel.text = pageSubscription.groupName;
        
        request = [NSURLRequest requestWithURL:pageSubscription.imageURL];

    }
    
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
        SiSFriend* personSubscr = [self.subscriptionsArray objectAtIndex:selectedIndexPath.row];
        
        SiSFriendDetails* vc = [segue destinationViewController];
        vc.friend = personSubscr;
        vc.friendID = personSubscr.uid;
        
    } else if ([[segue identifier] isEqualToString:@"wrongSegue"]) {
                             
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             
             [self dismissViewControllerAnimated:YES completion:nil];
         });
        
    }
}

@end
