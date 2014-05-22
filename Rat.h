//
//  Rat.h
//  Bartender
//
//  Created by Tom Houpt on 09/6/14.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Bartender.h"

@interface Rat : NSObject {
	
		unsigned long id;
		unsigned long group;
		unsigned long start_time;
		unsigned long end_time; // 0 = end-time not defined yet
		

}

RatType(unsigned long num);


@end
