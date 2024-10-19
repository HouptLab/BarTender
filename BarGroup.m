//
//  BarGroup.m
//  Bartender
//
//  Created by Tom Houpt on 09/6/14.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import "BarGroup.h"


@implementation BarGroup

-(void) setDefaults; {
	
	// should be called by "init"
	
	[super setDefaults];
	
	NSLog(@"Bargroup setDefaults");
	
	
}




-(NSColor *)color {
	
	return color;
}
-(void)setColor:(NSColor *)newColor {
	
	color = [newColor copy];
	
}


- (id)copyWithZone:(NSZone *)zone {
	
	BarGroup *copy = [super copyWithZone:zone];
		// copy using superclass BarObject routine
	
	// copy the specific subclass properties
		
	[copy setColor:[self color]];
		
	return copy;
}


@end
