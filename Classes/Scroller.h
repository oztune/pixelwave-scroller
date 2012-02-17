//
//  Scroller.h
//  Scrolling
//
//  Created by Oz Michaeli on 2/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Scroller;

@protocol ScrollerDelegate <NSObject>
@required
- (void) scroller: (Scroller *)scroller didChangeValue: (float) value;
@optional
// Scrolling is when the object moves with momentum
- (void) scrollerDidStartScrolling: (Scroller *)scroller;
- (void) scrollerDidStopScrolling: (Scroller *)scroller;
// Dragging is when the user is dragging the object
- (void) scrollerDidStartDragging: (Scroller *)scroller;
- (void) scrollerDidStopSDragging: (Scroller *)scroller;
@end

/**
 * Manages scrolling along a single axis
 */
@interface Scroller : NSObject {
@private
	float value;
	float vel;
	
	BOOL isMoving, isDragging, bounded;
	float bound;
	
	float min, max;
	float viewportSize;
	
	float lastTouchValue, touchStartValue, panStartValue;
	float lastMoveTime;
	
	float springMultiplier;
	
	id<ScrollerDelegate> delegate;
}

@property (nonatomic, assign) id<ScrollerDelegate> delegate;

@property (nonatomic, assign) float min;
@property (nonatomic, assign) float max;
@property (nonatomic, assign) float viewportSize;

// Call this on touch down with the position
// of the touch
- (void) start: (float)value;
// Call this on touch move with the position
// of the touch
- (void) move: (float)value;
// Call this on touch up
- (void) end;
// Call this once a frame, passing the amount of
// seconds between frames
- (BOOL) update: (float)dt;

@end
