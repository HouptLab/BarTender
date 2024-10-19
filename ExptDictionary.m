//
//  ExptDictionary.m
//  Bartender
//
//  Created by Tom Houpt on 09/9/12.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//



@implementation ExptDictionary


NSMutableDictionary *rootObj = [NSMutableDictionary 

								
	NSDictionary *innerDict;
	NSString *name;
	NSDate *dob;
	NSArray *scores;

	scores = [NSArray arrayWithObjects:[NSNumber numberWithInt:6],
			  [NSNumber numberWithFloat:4.6], [NSNumber numberWithLong:6.0000034], nil];
	name = @"George Washington";
	dob = [NSDate dateWithString:@"1732-02-17 04:32:00 +0300"];
	innerDict = [NSDictionary dictionaryWithObjects:
				 [NSArray arrayWithObjects: name, dob, scores, nil]
											forKeys:[NSArray arrayWithObjects:@"Name", @"DOB", @"Scores"]];
	

-(NSDictionary *)makeExptParametersDictionary {
	
	// make a dictionary from the expt parameters:
								
/*	NSDictionary *exptParametersDict = [NSDictionary dictionaryWithObjects:

		[NSArray arrayWithObjects:
			name, code, description, investigators, protocol, funding,
			[NSNumber numberWithUnsignedLong:startTime], [NSNumber numberWithUnsignedLong:endTime],
			[NSNumber numberWithBool:waitingForOff], 
			[NSNumber numberWithBool:useGroups], 
			[NSNumber numberWithBool:hasPreference],
			[NSNumber numberWithUnsignedLong:prefItemIndex], 
			[NSNumber numberWithUnsignedLong:baseItemIndex], 
			nil]
		forKeys:[NSArray arrayWithObjects:
			@" name", @"code", @"description", @"investigators", @"protocol", @"funding",
			@"startTime", @"endTime",
			@"waitingForOff", 
			@"useGroups", 
			@"hasPreference",
			@"prefItemIndex", 
			@"baseItemIndex"]
		];
							
	[rootObj setObject:exptParametersDict forKey:@"Parameters"];
 */
								
}
								
								

								
								fprintf(fp,name); fprintf(fp,"\n");
								fprintf(fp,comment); fprintf(fp,"\n");
								fprintf(fp,"Start_time: %ld\n",start_time);
								fprintf(fp,"End_time: %ld\n",end_time);
								fprintf(fp,"Waiting_for_off: %ld\n",(short)waiting_for_off);
								fprintf(fp,"Preference: %ld\n",(short)hasPreference);
								fprintf(fp,"prefItem: %ld\n",(short)prefItem);
								fprintf(fp,"baseItem: %ld\n",(short)baseItem);							
								
								
								
								
								scores = [NSArray arrayWithObjects:[NSNumber numberWithInt:8],
			  [NSNumber numberWithFloat:4.9],
			  [NSNumber numberWithLong:9.003433], nil];
	name = @"Abraham Lincoln";
	dob = [NSDate dateWithString:@"1809-02-12 13:18:00 +0400"];
	innerDict = [NSDictionary dictionaryWithObjects:
				 [NSArray arrayWithObjects: name, dob, scores, nil]
											forKeys:[NSArray arrayWithObjects:@"Name", @"DOB", @"Scores"]];
	[rootObj setObject:innerDict forKey:@"Lincoln"];

	id plist = [NSPropertyListSerialization dataFromPropertyList:(id)rootObj
														  format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];


@end
