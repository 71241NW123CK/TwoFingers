//
//  AppDelegate.h
//  TwoFingers
//
//  Created by Ryan Hiroaki Tsukamoto on 1/22/13.
//  Copyright (c) 2013 Ryan Hiroaki Tsukamoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TwoFingerView;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property	(nonatomic, readonly, strong)	TwoFingerView* twoFingerView;

@end
