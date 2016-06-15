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
#import "SiSButtonTableViewCell.h"
#import "SiSFollowers.h"
#import "SiSSubscriptions.h"
#import "SiSPostCell.h"
#import "SiSPost.h"

@interface SiSFriendDetails () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (assign, nonatomic) BOOL loadingData;

@property (strong, nonatomic) NSMutableArray* postsArray;

@end

static NSInteger postsInRequest = 20;

@implementation SiSFriendDetails

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.postsArray = [NSMutableArray array];
    
    NSLog(@"%@", self.friend.firstName);
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", self.friend.firstName, self.friend.lastName];
    
    self.loadingData = YES;
    
    [self getFriendInfoWithFriendID:self.friendID];
    [self getPostsFromServer];
    
}

#pragma mark - Helper Methods

- (void) printOutPost:(SiSPost*) post {
    NSLog(@"date = %@", post.date);
    NSLog(@"postImageURL = %@", post.postImageURL);
    NSLog(@"heightImage = %d", post.heightImage);
    NSLog(@"text = %@", post.text);
    NSLog(@"comments = %@", post.comments);
    NSLog(@"likes = %@", post.likes);
    
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

- (void) getPostsFromServer {
    
    [[SiSServerManager sharedManager] getWallPostsForUser:self.friendID
                                              withOffset:[self.postsArray count]
                                                   count:postsInRequest
                                               onSuccess:^(NSArray *posts) {
                                                   
                                                   [self.postsArray addObjectsFromArray:posts];
                                                   
                                                   [self.tableView reloadData];
                                                   
                                                   self.loadingData = NO;
                                                   
                                               }
                                               onFailure:^(NSError *error, NSInteger statusCode) {
                                                   NSLog(@"!!getWallPostsForUser error!!");
                                               }];
}
    


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    } else {
        return [self.postsArray count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* infoIdentifier = @"infoCell";
    static NSString* buttonIdentifier = @"buttonsCell";
    static NSString *postIdentifier = @"postCell";
    
    if (indexPath.section == 0) {
        
        SiSInfoCellTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:infoIdentifier];
        
        if (!cell) {
            cell = [[SiSInfoCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infoIdentifier];
        }
        
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.friend.firstName, self.friend.lastName];
        
        NSString* onlineStatusText;
        UIColor* onlineStatusColor;
        
        if (self.friend.isOnline) {
            onlineStatusText = @"Доступен";
            onlineStatusColor = [UIColor colorWithRed:10.0f/255.0f green:142.0f/255.0f blue:78.0/255.0f alpha:1.0];
        } else {
            onlineStatusText = @"Отсутствует";
            onlineStatusColor = [UIColor redColor];
        }
        
        cell.isOnline.text = onlineStatusText;
        cell.isOnline.textColor = onlineStatusColor;
        
        cell.cityCountry.text = [NSString stringWithFormat:@"%@, %@", self.friend.city ? self.friend.city : @"информации нет", self.friend.country ? self.friend.country : @"информации нет"];
        
        cell.dateOfBirth.text = self.friend.dateOfBirth;
        
        NSLog(@"%@", self.friend.lastName);
        
        [cell.photoView setImageWithURL:self.friend.image100URL
                       placeholderImage:[UIImage imageNamed:@"preview.gif"]];
        cell.photoView.layer.cornerRadius = cell.photoView.frame.size.width / 2;
        cell.photoView.layer.masksToBounds = YES;
        
        return cell;

    } else if (indexPath.section == 1) {
        
        SiSButtonTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:buttonIdentifier];
        
        if (!cell) {
            cell = [[SiSButtonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttonIdentifier];
        }
        
        return cell;

    } else if (indexPath.section == 2) {
        
        SiSPostCell* postCell = [tableView dequeueReusableCellWithIdentifier:postIdentifier];
        
        if (!postCell) {
            postCell = [[SiSPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postIdentifier];
        }
        
        SiSPost* post = [self.postsArray objectAtIndex:indexPath.row];
        
        postCell.nameLabel.text = [NSString stringWithFormat:@"%@ %@",self.friend.firstName, self.friend.lastName];
        
        postCell.postTextLabel.text = [NSString stringWithFormat:@"%@", post.text];
        postCell.dateLabel.text = post.date;
        
        postCell.commentsCountLabel.text = post.comments;
        postCell.likesCountLabel.text = post.likes;
        
        [postCell.postAuthorImage setImageWithURL:self.friend.image50URL];
        
        postCell.postImage.image = nil;
        
        NSURLRequest* request = [NSURLRequest requestWithURL:post.postImageURL];
        
        __weak SiSPostCell* weakPostCell = postCell;
        
        [postCell.postImage
         setImageWithURLRequest:request
         placeholderImage:nil
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
             
             weakPostCell.postImage.image = image;
             
         }
         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
             
         }];
        
        
        return postCell;
    }
            
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 110;
        
    } else if (indexPath.section == 1) {
        return 53;
        
    } else if (indexPath.section == 2) {
        
        return UITableViewAutomaticDimension;
        
        
    } else {
        return 100;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Segues

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"followersSegue"]) {
        
        SiSFollowers* vc = [segue destinationViewController];
        vc.friendID = self.friendID;
        
        
    } else if ([[segue identifier] isEqualToString:@"subscriptionsSegue"]) {
        
        SiSSubscriptions* vc = [segue destinationViewController];
        vc.friendID = self.friendID;
        
    }
}


@end
