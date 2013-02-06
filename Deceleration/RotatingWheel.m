//
//  RotatingWheel.m
//  Deceleration
//
//  Created by Rajendra HN on 04/02/13.
//

#import "RotatingWheel.h"
#import "DecelerationBehaviour.h"
#import "ViewUtils.h"
#import "ArrayUtils.h"
#import <objc/message.h>

typedef struct
{
    CGPoint point1;
    CGPoint point2;
} LINE;

double angleBetweenLines(LINE line1, LINE line2)
{
    double angle1 = atan2(line1.point1.y - line1.point2.y,line1.point1.x - line1.point2.x);
    double angle2 = atan2(line2.point1.y - line2.point2.y,line2.point1.x - line2.point2.x);
    return angle1 - angle2;
}

double distanceBetweenPoints(CGPoint point1, CGPoint point2)
{
    return sqrt(((point2.x - point1.x)*(point2.x - point1.x)) + ((point2.y - point1.y)*(point2.y - point1.y)));
}

@interface RotatingWheel ()<DecelerationBehaviourTarget, UIGestureRecognizerDelegate>

@property (nonatomic, strong) DecelerationBehaviour *deceleratingBehaviour;
@property (nonatomic, assign) BOOL rotationDirectionClockwise;

@end

@implementation RotatingWheel

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) [self setUp];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) [self setUp];
    return self;
}

- (void)setUp
{
    self.angle = 0.0f;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handlePan:)];
    panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:panGestureRecognizer];
    
    _deceleratingBehaviour = [DecelerationBehaviour instanceWithTarget:self];
    _deceleratingBehaviour.smoothnessFactor = 0.92;
    _shouldDecelerate = YES;
}

- (void)setAngle:(CGFloat)angle
{
    //keep the angle in [0-2PI] range
    int times = angle / (2 * M_PI);
    angle = angle - times * 2 * M_PI;
    if(angle < 0) angle += 2*M_PI;
    _angle = angle;
    self.transform = CGAffineTransformMakeRotation(angle);
}

- (void)setReferenceAngles:(NSArray *)referenceAngles
{
    //sort the array for convinence
    _referenceAngles = [referenceAngles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return (((NSNumber *)obj1).doubleValue > ((NSNumber *)obj2).doubleValue);
    }];
}

- (void)setShouldDecelerate:(BOOL)shouldDecelerate
{
    _shouldDecelerate = shouldDecelerate;
    if(!shouldDecelerate) [_deceleratingBehaviour cancelDeceleration];
}

- (void)setAngle:(CGFloat)angle animated:(BOOL)animated
{
    void (^animationblock)(void) = ^()
    {
        self.angle = angle;
    };
    
    if(animated) [UIView animateWithDuration:0.3 animations:animationblock];
    else animationblock();
}

- (void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if(panGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        [_deceleratingBehaviour cancelDeceleration];
        if([_delegate respondsToSelector:@selector(rotatingWheelDidStartRotating:)])
        {
            [_delegate rotatingWheelDidStartRotating:self];
        }
    }
    CGPoint presentTouchPoint = [panGestureRecognizer locationInView:self];
    CGPoint translation = [panGestureRecognizer translationInView:self];
    CGPoint previousTouchPoint = CGPointMake(presentTouchPoint.x - translation.x, presentTouchPoint.y - translation.y);
    
    CGFloat angularRotation = [self rotateFromPoint:previousTouchPoint toPoint:presentTouchPoint];
    if (translation.x != 0 || translation.y != 0)
    {
        _rotationDirectionClockwise = angularRotation > 0;
    }
    
    [panGestureRecognizer setTranslation:CGPointZero inView:self];
    if (panGestureRecognizer.state == UIGestureRecognizerStateCancelled ||
        panGestureRecognizer.state == UIGestureRecognizerStateEnded ||
        panGestureRecognizer.state == UIGestureRecognizerStateFailed)
    {
        if([_delegate respondsToSelector:@selector(rotatingWheelDidEndDraging:)])
        {
            [_delegate rotatingWheelDidEndDraging:self];
        }
        if(!_shouldDecelerate) return;
        CGPoint velocity = [panGestureRecognizer velocityInView:self];
        CGFloat velocityVectorMagneture = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat angularVelocity = velocityVectorMagneture / distanceBetweenPoints(presentTouchPoint, self.contentCenter);
        
        if(!_rotationDirectionClockwise) angularVelocity = -angularVelocity;
        
        velocity.x = angularVelocity;
        velocity.y = angularVelocity;
        
        [_deceleratingBehaviour decelerateWithVelocity:velocity withCompletionBlock:^{
            //move to closest of the reference angle
            if (_referenceAngles)
            {
                NSInteger nextIndex = [_referenceAngles indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                    if (((NSNumber *)obj).doubleValue > self.angle)
                    {
                        *stop = YES;
                        return YES;
                    }
                    return NO;
                }];
                if(nextIndex == NSNotFound) return;
                NSInteger previousIndex = (nextIndex == 0) ? _referenceAngles.count - 1 : nextIndex - 1;
                CGFloat lengthOfArcForNextIndex = _circleRadius * ([_referenceAngles[nextIndex] doubleValue] - self.angle);
                CGFloat lengthOfArcForPreviousIndex = _circleRadius * ([_referenceAngles[previousIndex] doubleValue] - self.angle);
                if (previousIndex == _referenceAngles.count - 1)
                {
                    lengthOfArcForPreviousIndex = 2 * M_PI * _circleRadius - lengthOfArcForPreviousIndex;
                }
                NSInteger nearestIndex = (ABS(lengthOfArcForNextIndex) > ABS(lengthOfArcForPreviousIndex)) ? previousIndex : nextIndex;
                [self setAngle:[_referenceAngles[nearestIndex] doubleValue] animated:YES];
            }
            if([_delegate respondsToSelector:@selector(rotatingWheelDidEndDeceletation:)])
            {
                [_delegate rotatingWheelDidEndDeceletation:self];
            }
        }];
    }
}

- (void)addTranslation:(CGPoint)traslation
{
    self.angle += traslation.x;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return [self touchPointInsideCircle:[gestureRecognizer locationInView:self]];
}

- (CGFloat)rotateFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2
{
    LINE line1,line2;
    line1.point1 = line2.point1 = self.contentCenter;
    line1.point2 = point1;
    line2.point2 = point2;
    
    double angleOfRotation = angleBetweenLines(line2, line1);
    self.angle += angleOfRotation;
    return angleOfRotation;
}

- (BOOL)touchPointInsideCircle:(CGPoint)touchPoint
{
    return (distanceBetweenPoints(self.contentCenter, touchPoint) <= ((_circleRadius == 0) ? self.height/2 : _circleRadius));
}

@end
