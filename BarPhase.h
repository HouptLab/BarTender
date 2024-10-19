//
//  BarPhase.h
//  Bartender
//
//  Created by Tom Houpt on 09/7/11.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BarObject.h"



@interface BarPhase : BarObject {

	NSInteger currentDay;
	// zero-indexed -- day 0 == first day
	// current day of -1 means phase has not started
}

-(NSInteger)currentDay;
-(void)setCurrentDay:(NSInteger)day;

@end
