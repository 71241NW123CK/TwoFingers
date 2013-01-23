//
//  TwoFingerView.h
//  TwoFingers
//
//  Created by Ryan Hiroaki Tsukamoto on 1/22/13.
//  Copyright (c) 2013 Ryan Hiroaki Tsukamoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

@interface TwoFingerView : UIView

//OpenGLES specific
@property GLint backingWidth;
@property GLint backingHeight;
@property (nonatomic, readonly, strong)	EAGLContext* context;
@property GLuint viewRenderbuffer;
@property GLuint viewFramebuffer;
@property GLuint depthRenderbuffer;
@property (nonatomic, readonly, strong)	NSTimer* animationTimer;
@property NSTimeInterval animationInterval;

-(void)startAnimation;
-(void)stopAnimation;
-(void)drawView;

@end
