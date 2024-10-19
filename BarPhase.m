//
//  BarPhase.m
//  Bartender
//
//  Created by Tom Houpt on 09/7/11.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import "BarPhase.h"


@implementation BarPhase

//-(id)init; {
//	
//	self = [super init];
//	if (self) {
//		
//		currentDay = -1; 
//	}
//	return self;
//	
//}

-(void) setDefaults; {
	// should be called by "init"
	
	[super setDefaults];
	
	
	NSLog(@"BarPhase setDefaults");

	currentDay = -1; 	
	
}


-(NSInteger)currentDay; { return currentDay; }
-(void)setCurrentDay:(NSInteger)day; {currentDay = day; }



- (id)copyWithZone:(NSZone *)zone {
	
	BarPhase *copy = [super copyWithZone:zone];
	// copy using superclass BarObject routine
	
	// copy the specific subclass properties
	
	[copy setCurrentDay:[self currentDay]];
	
	return copy;
}



@end
