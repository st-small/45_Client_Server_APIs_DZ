//
//  SiSPostCell.h
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 14.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SiSPostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* postTextLabel;
@property (weak, nonatomic) IBOutlet UILabel* dateLabel;

@property (weak, nonatomic) IBOutlet UILabel* nameLabel;


@property (weak, nonatomic) IBOutlet UILabel* commentsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel* likesCountLabel;

@property (weak, nonatomic) IBOutlet UIImageView* postAuthorImage;
@property (weak, nonatomic) IBOutlet UIImageView* postImage;

@end
