//
//  BarObject.h
//  Bartender
//
//  Created by Tom Houpt on 09/7/11.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// BarObjects are objects with a code, name and description:
//	BarItem
//	BarGroup
//	BarPhase
//	BarExperiment

@interface BarObject : NSObject <NSCopying> {
	
	
	NSString *name; // eg. "Area Postrema Lesions"
	NSString *code;	// eg "AP"
	NSString *description; // brief description of the experiment
	
	

}
-(id)initWithName:(NSString *)newName andCode:(NSString *)newCode andDescription:(NSString *)newDescription;

-(void) setName:(NSString *)n;
-(void) setCode:(NSString *)t;
-(void) setDescription:(NSString *)d;

-(void) setDefaults; // should be overridden by subclass...

-(NSString *) name; // return a string with  name, e.g. "Area Postrema Lesions"
-(NSString *) code; // return a string with the abbreviatede expt tag e.g. "AP"
-(NSString *) codeName; // return a string with both tag and name, e.g. "AP Area Postrema Lesions"
-(NSString *) description;



@end
