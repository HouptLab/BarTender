//
//  BarItem.h
//  Bartender
//
//  Created by Tom Houpt on 09/6/14.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BarObject.h"

@interface BarItem : BarObject {	

	double minWeight;
	double maxWeight;
		// maximum and minimum weights for an item; values outside these limits
		// will not be accepted as valid weights for the item
		// i.e., a water bottle must weigh between 200g (empty) and 500g (full).
	
	double minY;
	double maxY;
		// for plotting on a Y axis
	
	NSString *unit;
	
	int onOffType;
	// most items are weighed on & off for consumption, but could be one-time weight
	// e.g. daily body weight
	
}

//-(BOOL)checkCode(NSString *string);
// given a labelstring, check if our tag is part of the string
// item strings are of the structure ExptCode_RatNum_ItemCode
// return if true

-(double)minWeight;
-(double)maxWeight;
-(NSString *)minWeightText;
-(NSString *)maxWeightText;
-(void)setMinWeight:(double)newMinWeight;
-(void)setMaxWeight:(double)newMaxWeight;

-(double)minY;
-(double)maxY;
-(void)setMinY:(double)newMinY;
-(void)setMaxY:(double)newMaxY;

-(NSString *) unit;
-(void) setUnit:(NSString *)u;

-(int) onOffType;
-(void) setOnOffType:(int)type;



@end
