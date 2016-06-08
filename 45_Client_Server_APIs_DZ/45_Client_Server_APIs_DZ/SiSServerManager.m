//
//  SiSServerManager.m
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 06.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSServerManager.h"
#import "AFNetworking.h"
#import "SiSFriend.h"

@interface SiSServerManager ()

@property (strong, nonatomic) AFHTTPSessionManager* sessionManager;

@end

@implementation SiSServerManager

+ (SiSServerManager*) sharedManager {
    
    static SiSServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        manager = [[SiSServerManager alloc] init];
        
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSURL* url = [NSURL URLWithString:@"https://api.vk.com/method"];
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    }
    return self;
}

- (void) getFriendsWithOffset:(NSInteger) offset
                     andCount:(NSInteger) count
                    onSuccess:(void(^)(NSArray* friends)) success
                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"4418798",     @"user_id",
                            @"name",        @"order",
                            @(count),       @"count",
                            @(offset),      @"offset",
                            @"photo_50",    @"fields",
                            @"nom",         @"name_case", nil];
    
    [self.sessionManager GET:@"friends.get"
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask* task, NSDictionary* responseObject) {
                         //NSLog(@"JSON: %@", responseObject);
                         
                         NSArray* friendsArray = [responseObject objectForKey:@"response"];
                         
                         NSMutableArray* objectsArray = [NSMutableArray array];
                         
                         for (NSDictionary* dict in friendsArray) {
                             
                             SiSFriend* friend = [[SiSFriend alloc] initWithServerResponse:dict];
                             
                             [objectsArray addObject:friend];
                         }
                         
                         if (success) {
                             success(objectsArray);
                         }
                         
                     } failure:^(NSURLSessionTask* task, NSError* error) {
                         NSLog(@"Error: %@", error);
                         
                         if (failure) {
                             failure(error, task.error.code);
                         }
                     }];
    
}

- (void) getFriendInfoWithId:(NSString*)friendID
                   onSuccess:(void(^)(SiSFriend* friend))success
                   onFailure:(void(^)(NSError *error))failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            friendID,                   @"user_ids",
                            @"photo_200, online, city", @"fields",
                            @"nom",                     @"name_case", nil];
    
    [self.sessionManager GET:@"users.get"
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         
                         NSLog(@"USER INFO: %@", responseObject);
         
                         NSArray* dictsArray = [responseObject objectForKey:@"response"];
                         
                         SiSFriend* friend = nil;
                         
                         for (NSDictionary* dict in dictsArray) {
                             
                             friend = [[SiSFriend alloc] initWithServerResponse:dict];
                         }
                         
                         
                         
                         if (success) {
                             
                             success(friend);
                         }
                         
                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         NSLog(@"Error: %@", error);
                         
                         if (failure) {
                             failure(error);
                         }
                     }];
}

@end
