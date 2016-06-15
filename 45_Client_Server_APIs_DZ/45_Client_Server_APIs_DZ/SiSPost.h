//
//  SiSPost.h
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 14.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SiSPost : NSObject

@property (strong, nonatomic) NSString* text;

@property (strong, nonatomic) NSURL* imageURL_50;

@property (strong, nonatomic) NSString* date;
@property (strong, nonatomic) NSURL* postImageURL;
@property (strong, nonatomic) UIImage* postImage;
@property (assign, nonatomic) NSInteger heightImage;
@property (assign, nonatomic) NSInteger widthImage;

@property (assign, nonatomic) NSInteger sizeText;

@property (strong, nonatomic) NSString* comments;
@property (strong, nonatomic) NSString* likes;

- (id) initWithServerResponse:(NSDictionary*) responseObject;

@end
