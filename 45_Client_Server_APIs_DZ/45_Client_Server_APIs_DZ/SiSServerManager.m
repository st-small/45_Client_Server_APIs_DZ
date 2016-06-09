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
        
        NSURL* url = [NSURL URLWithString:@"https://api.vk.com/method/"];
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
                            @"ru",          @"lang",
                            @"name",        @"order",
                            @(count),       @"count",
                            @(offset),      @"offset",
                            @"photo_50,"
                            "photo_100,"
                            "photo_200",    @"fields",
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
    
    __block SiSFriend* friend = nil;
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    
    NSString* requiredFields =
    @"photo_50,"
    "photo_100,"
    "photo_200,"
    "city,"
    "country,"
    "bdate,"
    "followers_count,"
    "online,"
    "home_town";
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            friendID,                   @"user_ids",
                            requiredFields,             @"fields",
                            @"ru",                      @"lang",
                            @"nom",                     @"name_case", nil];
    
    [self.sessionManager
     GET:@"users.get"
     parameters:params
     progress:nil
     success:^(NSURLSessionDataTask* _Nonnull task, id  _Nullable responseObject) {
         
                         NSLog(@"USER INFO: %@", responseObject);
         
                         NSArray* dictsArray = [responseObject objectForKey:@"response"];
                         
                         NSDictionary* dict = [dictsArray firstObject];
                         
                         friend = [[SiSFriend alloc] initWithServerResponse:dict];
                         
                         NSString* cityID = [dict objectForKey:@"city"];
                         NSString* countryID = [dict objectForKey:@"country"];
                         
                         [[SiSServerManager sharedManager] getCityWithIds:cityID
                                                                onSuccess:^(NSString* city) {
                                                                   
                                                                   friend.city = city;
                                                                   
                                                                   [[SiSServerManager sharedManager] getCountryWithIds:countryID
                                                                                                            onSuccess:^(NSString *country) {
                                                                                                                friend.country = country;
                                                                                                                dispatch_group_leave(group);
                                                                                                                                                                                                                            } onFailure:^(NSError* error) {
                                                                                                                NSLog(@"!!error in country recognition!!");
                                                                                                                                                                                                                            }];
                                                                    
                                                                    
                                                                } onFailure:^(NSError *error) {
                                                                    
                                                                    NSLog(@"!!error in city recognition!!");
                                                                }];
         
         dispatch_group_notify(group, dispatch_get_main_queue(), ^{
             success(friend);
         });
     
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         NSLog(@"Error: %@", error);
                         
                         if (failure) {
                             failure(error);
                         }
                     }];
}


- (void)getCityWithIds:(NSString *)cityID
             onSuccess:(void (^) (NSString* city)) success
            onFailure:(void (^) (NSError* error)) failure {
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:cityID, @"city_ids", @"ru", @"lang", nil];
    
    [self.sessionManager GET:@"database.getCitiesById"
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask* operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSArray *objects = [responseObject objectForKey:@"response"];
        NSString* city = [[objects firstObject] objectForKey:@"name"];
        
        success(city);
        
    } failure:^(NSURLSessionDataTask* operation, NSError* error) {
        //NSLog(@"Error: %@", error);
        failure(error);
    }];
    
}

- (void)getCountryWithIds:(NSString *)countryID
                onSuccess:(void (^) (NSString *country)) success
                onFailure:(void (^) (NSError *error)) failure {
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:countryID,@"country_ids", @"ru", @"lang", nil];
    
    [self.sessionManager GET:@"database.getCountriesById"
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask* operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSArray *objects = [responseObject objectForKey:@"response"];
        NSString* country = [[objects firstObject] objectForKey:@"name"];
        
                         success(country);
        
    } failure:^(NSURLSessionDataTask* operation, NSError* error) {
        NSLog(@"Error: %@", error);
        failure(error);
    }];
    
}
     

@end
