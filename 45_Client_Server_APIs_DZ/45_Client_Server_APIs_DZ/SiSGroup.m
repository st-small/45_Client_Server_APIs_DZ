//
//  SiSGroup.m
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 13.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSGroup.h"

@implementation SiSGroup

- (id) initWithServerResponse:(NSDictionary*) responseObject
{
    self = [super init];
    if (self) {
        
        self.groupID = [responseObject objectForKey:@"gid"];
        
        self.groupName = [responseObject objectForKey:@"name"];
        self.groupScreenName = [responseObject objectForKey:@"screen_name"];
        
        NSString* urlString = [responseObject objectForKey:@"photo_100"];
        
        if (urlString) {
            self.imageURL = [NSURL URLWithString:urlString];
        }
    }
    return self;
}

@end
