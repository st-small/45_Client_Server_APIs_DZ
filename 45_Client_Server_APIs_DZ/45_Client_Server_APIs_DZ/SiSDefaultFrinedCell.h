//
//  SiSDefaultFrinedCell.h
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 10.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SiSDefaultFrinedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *isOnline;

@end
