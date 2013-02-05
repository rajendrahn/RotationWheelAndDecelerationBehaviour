//
//  ViewController.m
//  Deceleration
//
//  Created by Rajendra HN on 04/02/13.
//  Copyright (c) 2013 Robosoft. All rights reserved.
//

#import "ViewController.h"
#import "RotatingWheel.h"
#import "ViewUtils.h"
#import "DecelerationBehaviour.h"

CGFloat degreeToRadian(CGFloat degree)
{
    return degree * M_PI / 180;
}

@interface ViewController () <DecelerationBehaviourTarget>

@property (weak, nonatomic) IBOutlet RotatingWheel *rotatingView;
@property (weak, nonatomic) IBOutlet UIView *slideView;
@property (weak, nonatomic) IBOutlet UIView *slidingView;
@property (nonatomic, strong) DecelerationBehaviour *deceleratingBehaviour;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _rotatingView.circleRadius = _rotatingView.height/2;
    _rotatingView.referenceAngles = @[
    [NSNumber numberWithFloat:degreeToRadian(15)],
    [NSNumber numberWithFloat:degreeToRadian(45)],
    [NSNumber numberWithFloat:degreeToRadian(75)],
    [NSNumber numberWithFloat:degreeToRadian(105)],
    [NSNumber numberWithFloat:degreeToRadian(135)],
    [NSNumber numberWithFloat:degreeToRadian(165)],
    [NSNumber numberWithFloat:degreeToRadian(195)],
    [NSNumber numberWithFloat:degreeToRadian(225)],
    [NSNumber numberWithFloat:degreeToRadian(255)],
    [NSNumber numberWithFloat:degreeToRadian(285)],
    [NSNumber numberWithFloat:degreeToRadian(315)],
    [NSNumber numberWithFloat:degreeToRadian(345)],
    ];
//    _rotatingView.shouldDecelerate = NO;
    _deceleratingBehaviour = [DecelerationBehaviour instanceWithTarget:self];
    _deceleratingBehaviour.smoothnessFactor = 0.9;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [_rotatingView setAngle:M_PI_2 animated:YES];
}

- (void)addTranslation:(CGPoint)traslation
{
    CGRect slidingViewFrame = _slidingView.frame;
    slidingViewFrame.origin.x += traslation.x;
    slidingViewFrame.origin.y += traslation.y;
    if(CGRectContainsRect(self.view.bounds, slidingViewFrame))
    {
        _slidingView.frame = slidingViewFrame;
    }
    else
    {
        //make it stop at the boundary
        if (CGRectGetMinX(slidingViewFrame) < 0 || CGRectGetMaxX(slidingViewFrame) > self.view.width)
        {
            slidingViewFrame.origin.x = (CGRectGetMinX(slidingViewFrame) < 0) ? 0 : (CGRectGetMaxX(self.view.bounds) - slidingViewFrame.size.width);
        }

        if (CGRectGetMinY(slidingViewFrame) < 0 || CGRectGetMaxY(slidingViewFrame) > self.view.height)
        {
            slidingViewFrame.origin.y = (CGRectGetMinY(slidingViewFrame) < 0) ? 0 : (CGRectGetMaxY(self.view.bounds) - slidingViewFrame.size.height);
        }
         _slidingView.frame = slidingViewFrame;
        [_deceleratingBehaviour cancelDeceleration];
    }
}

- (IBAction)slidingViewPanned:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:_slideView];
    _slidingView.center = CGPointMake(_slidingView.x + translation.x, _slidingView.y + translation.y);
    [sender setTranslation:CGPointZero inView:_slideView];
    if (sender.state == UIGestureRecognizerStateCancelled ||
        sender.state == UIGestureRecognizerStateEnded ||
        sender.state == UIGestureRecognizerStateFailed)
    {
        [_deceleratingBehaviour decelerateWithVelocity:[sender velocityInView:_slideView] withCompletionBlock:nil];
    }
}

- (IBAction)doubleTap:(id)sender
{
    _slideView.hidden = !_slideView.hidden;
}
@end
