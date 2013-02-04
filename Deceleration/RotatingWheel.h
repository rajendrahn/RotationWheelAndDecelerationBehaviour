//
//  RotatingWheel.h
//  Deceleration
//
//  Created by Rajendra HN on 04/02/13.
//  Copyright (c) 2013 Robosoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RotatingWheel : UIView

//any touch outside the circle with self.center as center and self.circleRadius as radius will be discarded.
@property (nonatomic, assign) CGFloat circleRadius;

//angle in radians
@property (nonatomic, assign) CGFloat angle;
- (void)setAngle:(CGFloat)angle animated:(BOOL)animated;

@end
