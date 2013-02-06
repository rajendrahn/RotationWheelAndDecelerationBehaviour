//
//  RotatingWheel.h
//  Deceleration
//
//  Created by Rajendra HN on 04/02/13.
//

#import <UIKit/UIKit.h>

@class RotatingWheel;

@protocol RotatingWheelDelegate <NSObject>

@optional
- (void)rotatingWheelDidStartRotating:(RotatingWheel *)rotatingWheel;
- (void)rotatingWheelDidEndDraging:(RotatingWheel *)rotatingWheel;
- (void)rotatingWheelDidEndDeceletation:(RotatingWheel *)rotatingWheel;

@end

@interface RotatingWheel : UIView

//any touch outside the circle with self.center as center and self.circleRadius as radius will be discarded.
@property (nonatomic, assign) CGFloat circleRadius;

//array of NSNumbers which contains the reference angles to which the rotation must end to.
//i.e when user rotates the circle, if the referenceAngles is not nil, then circle will rest in the nearest refernce angle.
//Note: the values must be in [0 - 2*PI] range. If the condition are not met behaviour will be unexpected
//Optional and if set to nil it will not be considered
@property (nonatomic, strong) NSArray *referenceAngles;

@property (nonatomic, assign) BOOL shouldDecelerate;    //defaults to YES

//angle in radians
@property (nonatomic, assign) CGFloat angle;
- (void)setAngle:(CGFloat)angle animated:(BOOL)animated;

@property (nonatomic, weak) id<RotatingWheelDelegate> delegate;

@end
