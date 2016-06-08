//
//  SiSFriendsTableViewController.m
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 06.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSFriendsTableViewController.h"
#import "SiSServerManager.h"
#import "SiSFriend.h"
#import "UIImageView+AFNetworking.h"
#import "SiSFriendDetails.h"

@interface SiSFriendsTableViewController ()

@property (strong, nonatomic) NSMutableArray* friendsArray;
@property (assign, nonatomic) BOOL loadingData;

@end

@implementation SiSFriendsTableViewController

static NSInteger friendsInRequest = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Мои друзья:";
    
    self.friendsArray = [NSMutableArray array];
    
    self.loadingData = YES;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor grayColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"Avenir Next" size:23.0], NSFontAttributeName, nil]];
    
    [self getFriendsFromServer];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - API

- (void) getFriendsFromServer {
    
    [[SiSServerManager sharedManager]
     getFriendsWithOffset:[self.friendsArray count]
     andCount:friendsInRequest
     onSuccess:^(NSArray *friends) {
         
         [self.friendsArray addObjectsFromArray:friends];
         
         NSMutableArray* newPaths = [NSMutableArray array];
         for (NSUInteger i = [self.friendsArray count] - [friends count]; i < [self.friendsArray count]; i++) {
             
             [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
         }
         
         [self.tableView beginUpdates];
         [self.tableView insertRowsAtIndexPaths:newPaths
                               withRowAnimation:UITableViewRowAnimationTop];
         [self.tableView endUpdates];
         
         self.loadingData = NO;
         
     } onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@ code = %d", [error localizedDescription], statusCode);
     }];
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.friendsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    
    // Заполняем ячейки друзьями из словаря
    
    SiSFriend* friend = [self.friendsArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", friend.firstName, friend.lastName];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Добавим картинку к каждой строке
    
    NSURLRequest* request = [NSURLRequest requestWithURL:friend.imageURL];
    
    __weak UITableViewCell* weakCell = cell;
    
    cell.imageView.image = nil;
    
    [cell.imageView setImageWithURLRequest:request
                          placeholderImage:[UIImage imageNamed:@"preview_50.png"]
                                   success:^(NSURLRequest* request, NSHTTPURLResponse* response, UIImage* image) {
                                       weakCell.imageView.image = image;
                                       [weakCell layoutSubviews];
                                   } failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error) {
                                       NSLog(@"Something bad...");
                                   }];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (!self.loadingData)
        {
            self.loadingData = YES;
            [self getFriendsFromServer];
        }
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    SiSFriend* friend = [self.friendsArray objectAtIndex:indexPath.row];
//    SiSFriendDetails* vc = [[SiSFriendDetails alloc] init];
//    [vc setFriendID:friend.friendID];
//    [self.navigationController pushViewController:vc animated:YES];
//    
//}

#pragma mark - Segues

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"FriendDetails"]) {
        NSIndexPath* selectedIndexPath = [self.tableView indexPathForCell:sender];
        SiSFriend* friend = [self.friendsArray objectAtIndex:selectedIndexPath.row];
        
        SiSFriendDetails* vc = [segue destinationViewController];
        vc.friend = friend;
        
    }
}


@end
