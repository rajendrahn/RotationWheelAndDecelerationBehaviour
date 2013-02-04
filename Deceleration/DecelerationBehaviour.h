//
//  DecelerationBehaviour.h
//  Deceleration
//
//  Created by Rajendra HN on 04/02/13.
//  Copyright (c) 2013 Robosoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DecelerationBehaviourTarget <NSObject>

//should return true if the operation is successful and false if the the translation was not possible may be beacuse of the boundary
- (BOOL)addTranslation:(CGPoint)traslation;

@end

typedef void (^DecelerationCompletionBlock)();

@interface DecelerationBehaviour : NSObject

+ (id)instanceWithTarget:(id<DecelerationBehaviourTarget>)target;
- (id)initWithTarget:(id<DecelerationBehaviourTarget>)target;

@property (nonatomic, weak, readonly) id<DecelerationBehaviourTarget> target;

- (void)decelerateWithVelocity:(CGPoint)velocity withCompletionBlock:(DecelerationCompletionBlock)completionBlock;
- (void)cancelDeceleration; //cancelling will not invoke completion block
- (BOOL)decelerating;

@end
