//
//  channel.m
//  israeli online tv
//
//  Created by idan magled on 8/29/14.
//  Copyright (c) 2014 idan magled. All rights reserved.
//

#import "channel.h"

@implementation channel
@synthesize channel_name;
@synthesize channel_url;

-(id)initWithChannel_Name:(NSString *) new_channel_name Channel_Url: (NSURL*) new_channel_url{
    self.channel_name = new_channel_name;
    self.channel_url = new_channel_url;
    return  self;
}


@end