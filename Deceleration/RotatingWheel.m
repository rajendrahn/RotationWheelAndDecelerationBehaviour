//
//  RotatingWheel.m
//  Deceleration
//
//  Created by Rajendra HN on 04/02/13.
//  Copyright (c) 2013 Robosoft. All rights reserved.
//

#import "RotatingWheel.h"
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
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handlePan:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

- (void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint presentTouchPoints = [panGestureRecognizer locationInView:self];
    
    if(![self isTouchPointInsideCircle:presentTouchPoints]) return;
    
    CGPoint translation = [panGestureRecognizer translationInView:self];
    CGPoint previousTouchPoints = CGPointMake(presentTouchPoints.x - translation.x, presentTouchPoints.y - translation.y);
    
    LINE line1,line2;
    line1.point1 = line2.point1 = self.contentCenter;
    line1.point2 = previousTouchPoints;
    line2.point2 = presentTouchPoints;
    
    double angleOfRotation = angleBetweenLines(line2, line1);
    self.transform = CGAffineTransformConcat(self.transform, CGAffineTransformMakeRotation(angleOfRotation));
    
    [panGestureRecognizer setTranslation:CGPointZero inView:self];
}

- (BOOL)isTouchPointInsideCircle:(CGPoint)touchPoint
{
    return (distanceBetweenPoints(self.contentCenter, touchPoint) <= ((_circleRadius == 0) ? self.height/2 : _circleRadius));
}

@end
