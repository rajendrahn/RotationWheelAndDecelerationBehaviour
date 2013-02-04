//
//  DecelerationBehaviour.m
//  Deceleration
//
//  Created by Rajendra HN on 04/02/13.
//  Copyright (c) 2013 Robosoft. All rights reserved.
//

#import "DecelerationBehaviour.h"
#import <objc/message.h>

const CGFloat kTimerInterval = 0.05;

@interface DecelerationBehaviour ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation DecelerationBehaviour

- (id)initWithTarget:(id <DecelerationBehaviourTarget>)target
{
    if (!(self = [super init])) return nil;
    if (!target) return nil;
    _target = target;
    return self;
}

+ (id)instanceWithTarget:(id<DecelerationBehaviourTarget>)target
{
    return [[self alloc] initWithTarget:target];
}

- (BOOL)decelerating
{
    return _timer.isValid;
}

- (void)decelerateWithVelocity:(CGPoint)velocity withCompletionBlock:(DecelerationCompletionBlock)completionBlock
{
    NSMutableDictionary *userInfo = [@{@"velocity" : [NSValue valueWithCGPoint:velocity]} mutableCopy];
    if (completionBlock)
    {
        userInfo[@"completionBlock"] = completionBlock;
    }
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(step:) userInfo:userInfo repeats:YES];
}

- (void)cancelDeceleration
{
    [_timer invalidate];
}

- (void)step:(NSTimer *)timer
{
    CGPoint velocity = [timer.userInfo[@"velocity"] CGPointValue];
    velocity.x *= 0.98;
    velocity.y *= 0.98;
    timer.userInfo[@"velocity"] = [NSValue valueWithCGPoint:velocity];
    
    CGPoint distance;
    distance.x = velocity.x * 0.1;
    distance.y = velocity.y * 0.1;
    
    if((ABS(velocity.x) <= 10 && ABS(velocity.y) <= 10) || ![_target addTranslation:distance])
    {
        if (timer.userInfo[@"completionBlock"])
        {
            DecelerationCompletionBlock completionBlock = timer.userInfo[@"completionBlock"];
            completionBlock();
        }
        [timer invalidate];
        return;
    }
}

@end
