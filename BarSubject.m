//
//  BarSubject.m
//  Bartender
//
//  Created by Tom Houpt on 09/7/11.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import "BarSubject.h"


@implementation BarSubject

-(id)initWithGroupIndex:(unsigned long)index {
	
	self = [super init];
	
	if (self != nil) {
		
		[self setGroupIndex:index];
		
	}
	
	return self;
	
}


-(unsigned long)groupIndex {
	
	return groupIndex;
}

-(void)setGroupIndex:(unsigned long)index {
	
	groupIndex = index;
}


- (id)copyWithZone:(NSZone *)zone 
{ 
    BarSubject *copy = [[[self class] allocWithZone: zone] 
					   initWithGroupIndex:[self groupIndex]]; 
    return copy; 
} 



@end
