//
//  Weight.h
//  Bartender
//
//  Created by Tom Houpt on 09/6/14.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Bartender.h"


@interface Weight : NSObject {

	
	ItemType *item;	
	double on;
	double off;
	Boolean got_on,got_off;	// TRUE if not weighed this day..
	

}

Weight(ItemType *i);
void SetOn(double o);
void SetOff(double o);
void GetWeights(double *on, double *off, Boolean *got_on,Boolean *got_off);


@end
