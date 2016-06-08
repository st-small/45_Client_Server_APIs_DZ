//
//  SiSFriend.m
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 06.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSFriend.h"

@implementation SiSFriend

- (id) initWithServerResponse:(NSDictionary*) responseObject {
    
    self = [super init];
    if (self) {
        
        self.firstName = [responseObject objectForKey:@"first_name"];
        self.lastName = [responseObject objectForKey:@"last_name"];
        self.friendID = [responseObject objectForKey:@"user_id"];
        
        NSString* urlString50 = [responseObject objectForKey:@"photo_50"];
        
        if (urlString50) {
            
            self.image50URL = [NSURL URLWithString:urlString50];
        }
        
        NSString* urlString200 = [responseObject objectForKey:@"photo_200"];
        
        if (urlString200) {
            
            self.image200URL = [NSURL URLWithString:urlString200];
        }
        
    }
    return self;
}

@end
