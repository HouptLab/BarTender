//
//  BarGroup.h
//  Bartender
//
//  Created by Tom Houpt on 09/6/14.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Bartender.h"
#import "BarObject.h"


@interface BarGroup : BarObject {
		
	NSColor *color;
	
}



-(NSColor *)color;
-(void)setColor:(NSColor *)newColor;

@end
