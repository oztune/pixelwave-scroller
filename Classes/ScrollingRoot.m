/*
 *  _____                       ___                                            
 * /\  _ `\  __                /\_ \                                           
 * \ \ \L\ \/\_\   __  _    ___\//\ \    __  __  __    ___     __  __    ___   
 *  \ \  __/\/\ \ /\ \/ \  / __`\\ \ \  /\ \/\ \/\ \  / __`\  /\ \/\ \  / __`\ 
 *   \ \ \/  \ \ \\/>  </ /\  __/ \_\ \_\ \ \_/ \_/ \/\ \L\ \_\ \ \_/ |/\  __/ 
 *    \ \_\   \ \_\/\_/\_\\ \____\/\____\\ \___^___ /\ \__/|\_\\ \___/ \ \____\
 *     \/_/    \/_/\//\/_/ \/____/\/____/ \/__//__ /  \/__/\/_/ \/__/   \/____/
 *       
 *           www.pixelwave.org + www.spiralstormgames.com
 *                            ~;   
 *                           ,/|\.           
 *                         ,/  |\ \.                 Core Team: Oz Michaeli
 *                       ,/    | |  \                           John Lattin
 *                     ,/      | |   |
 *                   ,/        |/    |
 *                 ./__________|----'  .
 *            ,(   ___.....-,~-''-----/   ,(            ,~            ,(        
 * _.-~-.,.-'`  `_.\,.',.-'`  )_.-~-./.-'`  `_._,.',.-'`  )_.-~-.,.-'`  `_._._,.
 * 
 * Copyright (c) 2011 Spiralstorm Games http://www.spiralstormgames.com
 * 
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#import "ScrollingRoot.h"

@implementation ScrollingRoot

- (void) initializeAsRoot
{
	float rowHeight = 50.0f;
	int numRows = 30;
	
	PXDisplayObject *contents = [self newListWithRowHeight:rowHeight numRows:numRows];
	float listHeight = rowHeight * numRows;
	[self addChild:contents];
	
	/////
	
	scroller = [[Scroller alloc] init];
	scroller.delegate = self;
	
	scroller.min = 0.0f;
	scroller.max = listHeight;
	scroller.viewportSize = self.stage.stageHeight;
	
	[self.stage addEventListenerOfType:PXTouchEvent_TouchDown listener:PXListener(touchDown:)];
	[self.stage addEventListenerOfType:PXTouchEvent_TouchMove listener:PXListener(touchMove:)];
	[self.stage addEventListenerOfType:PXTouchEvent_TouchUp listener:PXListener(touchUp:)];
	[self.stage addEventListenerOfType:PXTouchEvent_TouchCancel listener:PXListener(touchUp:)];
	[self addEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame)];
}

- (PXDisplayObject *)newListWithRowHeight: (float)rowHeight numRows: (int)numRows {
	// Create an item to serve as the content
	PXSprite *contents = [[PXSprite alloc] init];
	
	// Create some lines and labels
	PXGraphics *g = contents.graphics;
	
	[g lineStyleWithThickness:1.0 color:0xaaaaaa alpha:1.0];
	
	PXTextField *txt;
	
	int i;
	float y = 0;
	float w = self.stage.stageWidth;
	for (i = 0; i < numRows; ++i) {
		y = i * rowHeight;
		[g moveToX:0 y:y];
		[g lineToX:w y:y];
		
		txt = [[PXTextField alloc] initWithFont:@"Helvetica"];
		txt.text = [NSString stringWithFormat:@"Item %i", i];
		txt.fontSize = 20.0f;
		txt.y = y + rowHeight * 0.5f;
		txt.x = 10.0f;
		txt.alignVertical = 0.5f;
		[contents addChild:txt];
		[txt release];
	}
	
	return contents;
}

// Managing the scroller

- (void) touchDown: (PXTouchEvent *)e {
	[scroller start:e.stageY];
}
- (void) touchMove: (PXTouchEvent *)e {
	[scroller move:e.stageY];
}
- (void) touchUp: (PXTouchEvent *)e {
	[scroller end];
}

- (void) onFrame {
	float fps = self.stage.frameRate;
	[scroller update:1.0f/fps];
}

// Scroller delegate methods

- (void) scroller:(Scroller *)scroller didChangeValue:(float)value {
	PXDisplayObject *obj = [self childAtIndex:0];
	
	obj.y = value;
}

@end
