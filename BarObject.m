//
//  BarObject.m
//  Bartender
//
//  Created by Tom Houpt on 09/7/11.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import "BarObject.h"


@implementation BarObject


-(id)initWithName:(NSString *)newName andCode:(NSString *)newCode andDescription:(NSString *)newDescription {
	
	
	self = [super init];
	
	if (self) {
		
		[self setName:newName];
		[self setCode:newCode];
		[self setDescription:newDescription];
		
		[self setDefaults];
	}
	
	return self;
	
	
}

-(id) init; {
	
	
	return ([self initWithName:nil andCode:nil andDescription:nil]);
	
}

-(void) setDefaults; {
	// should be called by "init"
	
	NSLog(@"BarObject setDefaults");
	
}

// ***************************************************************************************
// ***************************************************************************************
// setters and getters
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------

-(void) setName:(NSString *)n {
	
	//[name autoRelease];
	// name = n;
	// [name retain];
	if (nil == n) { name = [NSString string]; }
	else { name = [n copy]; }
	
	
}
-(void) setCode:(NSString *)c {
	
	//[code autoRelease];
	//code = c;
	// [code retain];
	if (nil == c) { code = [NSString string]; }
	else { code = [c copy]; }

}

-(void) setDescription:(NSString *)d {
	
	//[description autoRelease];
	//description = d;
	//[description retain];
	if (nil == d) { description = [NSString string]; }
	else { description = [d copy]; }
}

-(NSString *) name { return name; }
-(NSString *) code { return code; } 
-(NSString *) codeName {
	// return a string with both tag and name, e.g. "AP Area Postrema Lesions"
	
	return [[code stringByAppendingString:@": "]  stringByAppendingString:name];
	
}

-(NSString *) description  { return description; }





// ***************************************************************************************
// ***************************************************************************************
// COPYING
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
- (id)copyWithZone:(NSZone *)zone 
{ 
    BarObject *copy = [[[self class] allocWithZone: zone] 
					   initWithName:[self name]
					   andCode:[self code] 
					   andDescription:[self description]]; 
    return copy; 
} 


@end
