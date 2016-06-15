//
//  SiSPost.m
//  45_Client_Server_APIs_DZ
//
//  Created by Stanly Shiyanovskiy on 14.06.16.
//  Copyright © 2016 Stanly Shiyanovskiy. All rights reserved.
//

#import "SiSPost.h"

#define WIDTH_OF_IMAGEVIEW 520;

@implementation SiSPost

- (id) initWithServerResponse:(NSDictionary*) responseObject {
    
    self = [super init];
    
    if (self) {
        
        self.text = [responseObject objectForKey:@"text"];
        self.text = [self.text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
        
        self.comments = [[[responseObject objectForKey:@"comments"] objectForKey:@"count"] stringValue];
        self.likes = [[[responseObject objectForKey:@"likes"] objectForKey:@"count"] stringValue];
        
        NSDateFormatter *dateWithFormat = [[NSDateFormatter alloc] init];
        [dateWithFormat setDateFormat:@"dd MMM yyyy"];
        
        NSTimeInterval Date = [[responseObject objectForKey:@"date"] intValue];
        NSDate *dateValue = [NSDate dateWithTimeIntervalSince1970:Date];
        self.date = [dateWithFormat stringFromDate:dateValue];
        
        NSDictionary* attachments = [[responseObject objectForKey:@"attachment"] objectForKey:@"photo"];
        
        self.postImageURL = [NSURL URLWithString:[attachments objectForKey:@"src_big"]];
        
        
        
        NSInteger originalHeight = [[attachments objectForKey:@"height"] integerValue];
        NSInteger originalWidth = [[attachments objectForKey:@"width"] integerValue];
        
        float ratio = originalHeight / (float)originalWidth;
        
        
        if (originalWidth != 0) {
            self.heightImage = ratio * WIDTH_OF_IMAGEVIEW;
            self.widthImage = 520;
            
        }
        
        
        
        
    }
    return self;
    
    
}

@end
