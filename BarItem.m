//
//  BarItem.m
//  Bartender
//
//  Created by Tom Houpt on 09/6/14.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import "BarItem.h"


@implementation BarItem

//-(id)init; {
//	
//	self = [super init];
//	
//	if (self) {
//		
//	}
//	return self;
//	
//}

-(void) setDefaults; {
	// should be called by "init"
	
	[super setDefaults];
	
	NSLog(@"BarItem setDefaults");
	unit = @"g";
    onOffType = NSControlStateValueOn;
	
	minWeight = 0;
	maxWeight = 5000;
	
	
}


-(NSString *)unit; {return unit; }
-(void) setUnit:(NSString *)u; { 
	
	if (nil == u) { unit = [NSString string]; }
	else { unit = [u copy]; }

}

-(double)minWeight {return minWeight; }
-(double)maxWeight {return maxWeight; }
-(NSString *)minWeightText; { return [NSString stringWithFormat:@"%lf",minWeight]; }
-(NSString *)maxWeightText; { return [NSString stringWithFormat:@"%lf",maxWeight]; }

-(void)setMinWeight:(double)newMinWeight { minWeight = newMinWeight; }
-(void)setMaxWeight:(double)newMaxWeight { maxWeight = newMaxWeight; };

-(double)minY {return minY; }
-(double)maxY {return maxY; }
-(void)setMinY:(double)newMinY { minY = newMinY; }
-(void)setMaxY:(double)newMaxY { maxY = newMaxY; }

-(int) onOffType; { return onOffType; }
-(void) setOnOffType:(int)type;  { onOffType = type; }



- (id)copyWithZone:(NSZone *)zone {
	
	BarItem *copy = [super copyWithZone:zone];
	// copy using superclass BarObject routine
	
	// copy the specific subclass properties
	
	[copy setMinWeight:[self minWeight]];
	[copy setMaxWeight:[self maxWeight]];
	
	[copy setMinY:[self minY]];
	[copy setMaxY:[self maxY]];
	
	[copy setUnit:[self unit]];
	
	[copy setOnOffType:[self onOffType]];

	return copy;
	
}

@end
