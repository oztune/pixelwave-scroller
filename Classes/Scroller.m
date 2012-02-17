//
//  Scroller.m
//  Scrolling
//
//  Created by Oz Michaeli on 2/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Scroller.h"

#import "Pixelwave.h"

// Slowing down the scroll after a swipe
#define SC_PAN_FRICTION 0.92f
// Snapping back from bounds
#define SC_SPRING_REBOUND_DRAG 0.11f

static float BASE_PAN_SPRING_DRAG = 0.55;
static float MAX_VEL = 10000.0;

@implementation Scroller

@synthesize delegate;
@synthesize min, max, viewportSize;

- (id)init
{
    self = [super init];
    if (self) {
		springMultiplier = 1.0f;
    }
    
    return self;
}

- (void) _onPosChange {
	[self.delegate scroller:self didChangeValue:-value];
}
- (void) _startMoving {
	if (isMoving) return;
	isMoving = YES;
	
	if ([self.delegate respondsToSelector:@selector(scrollerDidStartScrolling:)]) {
		[self.delegate scrollerDidStartScrolling:self];
	}
}
- (void) _stopMoving {
	vel = 0.0f;
	if (isMoving == false) return;
	isMoving = false;
	
	if ([self.delegate respondsToSelector:@selector(scrollerDidStopScrolling:)]) {
		[self.delegate scrollerDidStopScrolling:self];
	}
}
- (void) _updateMoveVel: (float)val {
	float diff = val - lastTouchValue;
	lastTouchValue = val;
	
	float cTime = PXGetTimerSec();
	
	if (lastMoveTime >= 0.0) {
		float dt = (cTime - lastMoveTime);// * 0.001f;
		if (dt > 0.1f) {
			vel = 0.0f;
		} else {
			vel = -diff / dt;
		}
	}
	
	lastMoveTime = cTime;
}
- (void) _setIsDragging: (BOOL)val {
	if (val == isDragging) return;
	isDragging = val;
	
	if (isDragging) {
		if ([self.delegate respondsToSelector:@selector(scrollerDidStartDragging:)]) {
			[self.delegate scrollerDidStartDragging:self];
		}
	} else {
		if ([self.delegate respondsToSelector:@selector(scrollerDidStopScrolling:)]) {
			[self.delegate scrollerDidStopSDragging:self];
		}
	}
}
- (void) _checkBounds {
	bounded = NO;
	
	float boundVal;
	
	// boundVal is where value is _supposed_ to be at max/min
	
	float epsilon = 0.5f;
	
	boundVal = min;
	if (value < boundVal - epsilon) {
		bound = boundVal;
		bounded = YES;
	} else {
		boundVal = max - viewportSize;
		
		if (boundVal < 0) boundVal = 0.0f;
		
		if (value > boundVal + epsilon) {
			bound = boundVal;
			bounded = YES;
		}
	}
}

- (void) start: (float)_value {
	lastTouchValue = _value;
	touchStartValue = _value;
	
	if (bounded) {
		value = bound;
		[self _onPosChange];
	}
	
	panStartValue = value;
	
	lastMoveTime = -1.0f;
	[self _stopMoving];
}
- (void) move: (float)_value {
	float thresh = 4.0f;
	
	[self _updateMoveVel:_value];
	
	float touchTrans = _value - touchStartValue;
	
	if (!isDragging) {
		if (ABS(touchTrans) < thresh && ABS(touchTrans) < thresh) {
			return;
		}
		[self _setIsDragging:YES];
	}
	
	value = panStartValue - touchTrans;
	
	if (YES) {
		[self _checkBounds];
		
		if (bounded) {
			value = bound + (value - bound) * (BASE_PAN_SPRING_DRAG * springMultiplier);
		}
	}
	
	[self _onPosChange];
}
- (BOOL) update: (float)dt {
	if (isDragging) return NO;
	
	if (vel > MAX_VEL) vel = MAX_VEL;
	if (vel < -MAX_VEL) vel = -MAX_VEL;
	
	float startVal = value;
	
	value += vel * dt;
	
	if (YES) {
		[self _checkBounds];
		
		if (bounded) {
			float springFriction = pow(pow(springMultiplier * 0.8f, 60.0f), dt);
			
			vel *= springFriction;
			value += (bound - value) * SC_SPRING_REBOUND_DRAG;
		}
	}
	
	vel *= SC_PAN_FRICTION;
	float xd = startVal - value;
	
	if (!bounded && (xd * xd) < 0.001f) {
		[self _stopMoving];
		return false;
	}
	
	[self _onPosChange];
	return true;
}
- (void) end {
	if (!isDragging) {
		[self _stopMoving];
	} else {
		// If the user pressed down, moved, then held it there for
		// more than 0.03 seconds, we don't use the calculated velocity
		if (lastMoveTime >= 0.0f) {
			float cTime = PXGetTimerSec();
			float diff = (cTime - lastMoveTime);// * 0.001f;
			
			if (diff > 0.09f) {
				[self _stopMoving];
			}
		}
	}
	
	[self _checkBounds];
	
	if ((vel * vel > 0.6) || bounded) {
		[self _startMoving];
	}
	
	[self _setIsDragging:NO];
}

@end
