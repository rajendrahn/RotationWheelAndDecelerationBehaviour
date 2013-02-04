//
//  RotatingWheel.m
//  Deceleration
//
//  Created by Rajendra HN on 04/02/13.
//  Copyright (c) 2013 Robosoft. All rights reserved.
//

#import "RotatingWheel.h"

@implementation RotatingWheel

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    
}

@end
