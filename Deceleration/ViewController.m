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

@interface ViewController ()

@property (weak, nonatomic) IBOutlet RotatingWheel *rotatingView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _rotatingView.circleRadius = _rotatingView.height/2;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_rotatingView setAngle:M_PI_2 animated:YES];
}
@end
