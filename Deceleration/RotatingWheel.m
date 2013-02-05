//
//  RotatingWheel.m
//  Deceleration
//
//  Created by Rajendra HN on 04/02/13.
//  Copyright (c) 2013 Robosoft. All rights reserved.
//

#import "RotatingWheel.h"
#import "DecelerationBehaviour.h"
#import "ViewUtils.h"

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
    self.angle = 0.0f;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handlePan:)];
    panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:panGestureRecognizer];
    
    _deceleratingBehaviour = [DecelerationBehaviour instanceWithTarget:self];
    _deceleratingBehaviour.smoothnessFactor = 0.92;
}

- (void)setAngle:(CGFloat)angle
{
    _angle = angle;
    self.transform = CGAffineTransformMakeRotation(angle);
}

- (void)setAngle:(CGFloat)angle animated:(BOOL)animated
{
    void (^animationblock)(void) = ^()
    {
        self.angle = angle;
    };
    
    if (animated)
    {
        [UIView animateWithDuration:0.3 animations:animationblock];
    }
    else
    {
        animationblock();
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    [_deceleratingBehaviour cancelDeceleration];
    CGPoint presentTouchPoint = [panGestureRecognizer locationInView:self];
    CGPoint translation = [panGestureRecognizer translationInView:self];
    CGPoint previousTouchPoint = CGPointMake(presentTouchPoint.x - translation.x, presentTouchPoint.y - translation.y);
    
    CGFloat angularRotation = [self rotateFromPoint:previousTouchPoint toPoint:presentTouchPoint];
    if (angularRotation != 0)
    {
        _rotationDirectionClockwise = angularRotation > 0;
    }
    
    [panGestureRecognizer setTranslation:CGPointZero inView:self];
    if (panGestureRecognizer.state == UIGestureRecognizerStateCancelled ||
        panGestureRecognizer.state == UIGestureRecognizerStateEnded ||
        panGestureRecognizer.state == UIGestureRecognizerStateFailed)
    {
        CGPoint velocity = [panGestureRecognizer velocityInView:self];
        CGFloat velocityVectorMagneture = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat angularVelocity = velocityVectorMagneture / distanceBetweenPoints(presentTouchPoint, self.contentCenter);
        if(!_rotationDirectionClockwise) angularVelocity = -angularVelocity;
        velocity.x = angularVelocity;
        velocity.y = angularVelocity;
        [_deceleratingBehaviour decelerateWithVelocity:velocity withCompletionBlock:nil];
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
