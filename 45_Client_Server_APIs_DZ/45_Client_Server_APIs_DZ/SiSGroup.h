//
//  SiSGroup.h
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 13.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SiSGroup : NSObject

@property (strong, nonatomic) NSString* groupID;

@property (strong, nonatomic) NSURL* imageURL;

@property (strong, nonatomic) NSString* groupName;

@property (strong, nonatomic) NSString* groupScreenName;

- (id) initWithServerResponse:(NSDictionary*) responseObject;

@end
