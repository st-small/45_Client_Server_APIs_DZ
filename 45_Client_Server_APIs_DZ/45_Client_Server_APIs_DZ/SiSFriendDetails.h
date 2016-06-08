//
//  SiSFriendDetails.h
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 06.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SiSFriend.h"

@interface SiSFriendDetails : UIViewController

@property (strong, nonatomic) SiSFriend* friend;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
