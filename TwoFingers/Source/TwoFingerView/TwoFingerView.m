//
//  TwoFingerView.m
//  TwoFingers
//
//  Created by Ryan Hiroaki Tsukamoto on 1/22/13.
//  Copyright (c) 2013 Ryan Hiroaki Tsukamoto. All rights reserved.
//

#import "TwoFingerView.h"

#define USE_DEPTH_BUFFER 0

@interface TwoFingerView()
{
	float halfWidth;
	float halfHeight;
	
	float itemX;
	float itemY;
	float itemScaleFactor;
	float itemAngle;// RADIANS PLOX KTHX
	
	bool touch0Active;
	float touch0ScreenX;
	float touch0ScreenY;
	
	bool touch1Active;
	float touch1ScreenX;
	float touch1ScreenY;
}

@property (nonatomic, readwrite, strong)	EAGLContext* context;
@property (nonatomic, readwrite, strong)	NSTimer* animationTimer;

-(BOOL)createFramebuffer;
-(void)destroyFramebuffer;

-(void)drawViewPrefix;
-(void)drawViewSuffix;

-(void)drawItem;

@end

@implementation TwoFingerView

+(Class)layerClass
{
	return [CAEAGLLayer class];
}

-(void)layoutSubviews
{
    [EAGLContext setCurrentContext:_context];
    [self destroyFramebuffer];
    [self createFramebuffer];
	[self drawView];
}


- (id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		CAEAGLLayer* eaglLayer = (CAEAGLLayer*)self.layer;
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		if(!_context || ![EAGLContext setCurrentContext:_context])	return nil;
		_animationInterval = 1.0 / 60.0;
		itemX = 0.0f;
		itemY = 0.0f;
		itemScaleFactor = 1.0f;
		itemAngle = 0.0f;
		halfWidth = 0.5f * self.frame.size.width;
		halfHeight = 0.5f * self.frame.size.height;
		self.multipleTouchEnabled = YES;
	}
	return self;
}

-(void)drawView
{
	[self drawViewPrefix];
	
	[self drawItem];
	
	[self drawViewSuffix];
};

-(void)drawItem
{
	glLineWidth(5.0f);
	const float sidelength = 64.0f;
	const GLfloat xAxisVerts[] =
	{
		0.0f, 0.0f,
		sidelength, 0.0f
	};
	const GLfloat yAxisVerts[] =
	{
		0.0f, 0.0f,
		0.0f, sidelength
	};
	const GLfloat hypotenuseVerts[] =
	{
		sidelength, 0.0f,
		0.0f, sidelength
	};
	glPushMatrix();
		glTranslatef(itemX, itemY, 0.0f);
		glRotatef(180.0f * M_1_PI * itemAngle, 0.0f, 0.0f, 1.0f);
		glScalef(itemScaleFactor, itemScaleFactor, 1.0f);
		glColor4f(1.0f, 0.0f, 0.0f, 1.0f);
		glVertexPointer(2, GL_FLOAT, 0, xAxisVerts);
		glDrawArrays(GL_LINES, 0, 2);
		glColor4f(0.0f, 1.0f, 0.0f, 1.0f);
		glVertexPointer(2, GL_FLOAT, 0, yAxisVerts);
		glDrawArrays(GL_LINES, 0, 2);
		glColor4f(0.0f, 0.0f, 1.0f, 1.0f);
		glVertexPointer(2, GL_FLOAT, 0, hypotenuseVerts);
		glDrawArrays(GL_LINES, 0, 2);
	glPopMatrix();
	
}

-(void)startAnimation
{
	self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:_animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}

-(void)stopAnimation
{
	self.animationTimer = nil;
}

-(BOOL)createFramebuffer
{
    glGenFramebuffersOES(1, &_viewFramebuffer);
    glGenRenderbuffersOES(1, &_viewRenderbuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _viewRenderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _viewRenderbuffer);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &_backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &_backingHeight);
    if(USE_DEPTH_BUFFER)
	{
        glGenRenderbuffersOES(1, &_depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, _depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, _backingWidth, _backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, _depthRenderbuffer);
    }
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) return NO;
    return YES;
}

-(void)destroyFramebuffer
{
    glDeleteFramebuffersOES(1, &_viewFramebuffer);
    _viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &_viewRenderbuffer);
    _viewRenderbuffer = 0;
    if(_depthRenderbuffer)
	{
        glDeleteRenderbuffersOES(1, &_depthRenderbuffer);
        _depthRenderbuffer = 0;
    }
}

-(void)drawViewPrefix
{
    [EAGLContext setCurrentContext:_context];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _viewFramebuffer);
    glViewport(0, 0, _backingWidth, _backingHeight);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	glOrthof(-halfWidth, halfWidth, -halfHeight, halfHeight, -1.0f, 1.0f);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	glEnableClientState(GL_VERTEX_ARRAY);
}

-(void)drawViewSuffix
{
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _viewRenderbuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch* touch in touches)
	{
		float touchX = [touch locationInView:self].x - halfWidth;
		float touchY = halfHeight - [touch locationInView:self].y;
		if(!touch0Active)
		{
			touch0ScreenX = touchX;
			touch0ScreenY = touchY;
			touch0Active = true;
		}
		else if(!touch1Active)
		{
			touch1ScreenX = touchX;
			touch1ScreenY = touchY;
			touch1Active = true;
		}
	}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	float touch0PreviousScreenX = touch0ScreenX;
	float touch0PreviousScreenY = touch0ScreenY;
	float touch1PreviousScreenX = touch1ScreenX;
	float touch1PreviousScreenY = touch1ScreenY;
	for(UITouch* touch in touches)
	{
		float touchPreviousX = [touch previousLocationInView:self].x - halfWidth;
		float touchPreviousY = halfHeight - [touch previousLocationInView:self].y;
		float touchCurrentX = [touch locationInView:self].x - halfWidth;
		float touchCurrentY = halfHeight - [touch locationInView:self].y;
		if(touchPreviousX == touch0PreviousScreenX && touchPreviousY == touch0PreviousScreenY)
		{
			touch0ScreenX = touchCurrentX;
			touch0ScreenY = touchCurrentY;
		}
		if(touchPreviousX == touch1PreviousScreenX && touchPreviousY == touch1PreviousScreenY)
		{
			touch1ScreenX = touchCurrentX;
			touch1ScreenY = touchCurrentY;
		}
	}
	if(touch0Active)
	{
		if(touch1Active)
		{
//			NSLog(@"0");
			float previousCenterX = 0.5f * (touch0PreviousScreenX + touch1PreviousScreenX);
			float previousCenterY = 0.5f * (touch0PreviousScreenY + touch1PreviousScreenY);
			float currentCenterX = 0.5f * (touch0ScreenX + touch1ScreenX);
			float currentCenterY = 0.5f * (touch0ScreenY + touch1ScreenY);
			
			//a
			float previousVectorX = itemX - previousCenterX;
			//bi
			float previousVectorY = itemY - previousCenterY;
			
			float previousSpanX = touch1PreviousScreenX - touch0PreviousScreenX;
			float previousSpanY = touch1PreviousScreenY - touch0PreviousScreenY;
			float previousSpan = sqrtf(previousSpanX * previousSpanX + previousSpanY * previousSpanY);
			
			float currentSpanX = touch1ScreenX - touch0ScreenX;
			float currentSpanY = touch1ScreenY - touch0ScreenY;
			float currentSpan = sqrtf(currentSpanX * currentSpanX + currentSpanY * currentSpanY);
			
			float scaleRatio = previousSpan > 0.0f ? currentSpan / previousSpan : 1.0f;
			
			float previousAngle = atan2f(previousSpanY, previousSpanX);
			float currentAngle = atan2f(currentSpanY, currentSpanX);
			float angleDiff = currentAngle - previousAngle;
			
			//c
			float angleA = cos(angleDiff);
			//d
			float angleB = sin(angleDiff);
			
			//(a + bi) * (c + di) = ac - bd + (ad + bc)i
			float currentVectorX = scaleRatio * (previousVectorX * angleA - previousVectorY * angleB);
			float currentVectorY = scaleRatio * (previousVectorX * angleB + previousVectorY * angleA);
			
			itemX = currentCenterX + currentVectorX;
			itemY = currentCenterY + currentVectorY;
			
			itemScaleFactor *= scaleRatio;
			const float minimumScaleFactor = 0.0625f;
			if(itemScaleFactor < minimumScaleFactor)
			{
				itemScaleFactor = minimumScaleFactor;
				touch0Active = false;
				touch1Active = false;
			}
			
			itemAngle += angleDiff;
			while(itemAngle < 0)	itemAngle += 2.0f * M_PI;
			while(itemAngle > 2.0 * M_PI)	itemAngle -= 2.0f * M_PI;
		}
		else
		{
//			NSLog(@"1");
			float diffX = touch0ScreenX - touch0PreviousScreenX;
			float diffY = touch0ScreenY - touch0PreviousScreenY;
			itemX += diffX;
			itemY += diffY;
		}
	}
	else if(touch1Active)
	{
//		NSLog(@"2");
		float diffX = touch1ScreenX - touch1PreviousScreenX;
		float diffY = touch1ScreenY - touch1PreviousScreenY;
		itemX += diffX;
		itemY += diffY;
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch* touch in touches)
	{
		float touchPreviousX = [touch previousLocationInView:self].x - halfWidth;
		float touchPreviousY = halfHeight - [touch previousLocationInView:self].y;
		float touchCurrentX = [touch locationInView:self].x - halfWidth;
		float touchCurrentY = halfHeight - [touch locationInView:self].y;
		if
		(
			(touchPreviousX == touch0ScreenX && touchPreviousY == touch0ScreenY)
			||
			(touchCurrentX == touch0ScreenX && touchCurrentY == touch0ScreenY)
		)
		{
			touch0Active = false;
		}
		if
		(
			(touchPreviousX == touch1ScreenX && touchPreviousY == touch1ScreenY)
			||
			(touchCurrentX == touch1ScreenX && touchCurrentY == touch1ScreenY)
		)
		{
			touch1Active = false;
		}
	}
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	touch0Active = false;
	touch1Active = false;
}

@end
