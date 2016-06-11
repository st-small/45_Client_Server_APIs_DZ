//
//  SiSFollowers.h
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 10.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SiSFollowers : UIViewController


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString* friendID;

@end
