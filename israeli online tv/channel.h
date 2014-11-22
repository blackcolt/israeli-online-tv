//
//  channel.h
//  israeli online tv
//
//  Created by idan magled on 8/29/14.
//  Copyright (c) 2014 idan magled. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface channel : NSObject
@property (nonatomic,retain) NSString *channel_name;
@property (nonatomic,retain) NSURL *channel_url;


-(id)initWithChannel_Name:(NSString *) channel_name Channel_Url: (NSURL*) channel_url;

@end
