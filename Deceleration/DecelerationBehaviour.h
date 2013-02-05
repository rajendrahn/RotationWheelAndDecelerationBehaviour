//
//  DecelerationBehaviour.h
//  Deceleration
//
//  Created by Rajendra HN on 04/02/13.
//

#import <Foundation/Foundation.h>

@protocol DecelerationBehaviourTarget <NSObject>

- (void)addTranslation:(CGPoint)traslation;

@end

typedef void (^DecelerationCompletionBlock)();

@interface DecelerationBehaviour : NSObject

+ (id)instanceWithTarget:(id<DecelerationBehaviourTarget>)target;
- (id)initWithTarget:(id<DecelerationBehaviourTarget>)target;

@property (nonatomic, weak, readonly) id<DecelerationBehaviourTarget> target;

//smoothnessFactor decides how smooth the deceleration will be
//smoothnessFactor's range should be between 0 and < 1 if its beyond those range then behaviour is unexpected
//defaults to 0.8
@property (nonatomic, assign) CGFloat smoothnessFactor;  

- (void)decelerateWithVelocity:(CGPoint)velocity withCompletionBlock:(DecelerationCompletionBlock)completionBlock;
- (void)cancelDeceleration; //cancelling will not invoke completion block
- (BOOL)decelerating;

@end
