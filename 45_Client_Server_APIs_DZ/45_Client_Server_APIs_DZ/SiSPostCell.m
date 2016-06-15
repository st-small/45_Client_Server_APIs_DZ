//
//  SiSPostCell.m
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 14.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSPostCell.h"

@implementation SiSPostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.postAuthorImage.layer.cornerRadius = self.postAuthorImage.frame.size.height/2;
    self.postAuthorImage.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
