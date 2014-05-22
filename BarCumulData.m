//
//  BarCumulData.m
//  Bartender
//
//  Created by Tom Houpt on 7/5/12.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import "BarCumulData.h"
#import "DailyData.h"

@implementation BarCumulData

NSString *delimiter;

-(id)init; {

	self = [super init];
	if (self) {
		
		// put all the data into this buffer:
		cumulDataString = [[NSMutableString alloc] init];
		
		// set default delimiter
		delimiter = [NSString stringWithString:@"\t"];
		
		// set default end of line character
		endOfLine = [NSString stringWithString:@"\r"];
		
		nullData = [NSString stringWithString:@"--"];

	}
	return self;
	
}



-(void)setDelimiterString:(NSString *)d; {
	
	delimiter = [d copy];
	
}
-(void)setEndOfLineString:(NSString *)e; {
	
	endOfLine = [e copy];
	
}
-(void)setNullDataString:(NSString *)nd; {
	
	nullData = [nd copy];
	
}

-(void) writeToFile; {
	
	if (nil == myFilePath) return;
	
	[cumulDataString writeToFile:myFilePath atomically:YES];
	
	
}
-(void) writeHeaderLines; {
	
	// header lines...
	
	// update if the file format changes...
	NSString *myCreatorString = @"Bartender";
	NSString *myVersionString = @"2.00";
	NSString *myTypeString = @"Daily Data";


	// creator line
	[cumulDataString appendString: kCreatorString];
	[cumulDataString appendString: delimiter];
	[cumulDataString appendString: myCreatorString];
	[cumulDataString appendString: endOfLine];

	// version
	[cumulDataString appendString: kVersionString];
	[cumulDataString appendString: delimiter];
	[cumulDataString appendString: myVersionString];
	[cumulDataString appendString: endOfLine];

	// type
	[cumulDataString appendString: kTypeString];
	[cumulDataString appendString: delimiter];
	[cumulDataString appendString: myTypeString];
	[cumulDataString appendString: endOfLine];
	
	// creationDate
	[cumulDataString appendString: kCreationDateString];
	[cumulDataString appendString: delimiter];
	[cumulDataString appendString: [[NSDate date] description]];
	[cumulDataString appendString: endOfLine];
	
	// experiment
	[cumulDataString appendString: kExperimentString];
	[cumulDataString appendString: delimiter];
	[cumulDataString appendString: [self name]];
	[cumulDataString appendString: endOfLine];

	// ExptCode
	[cumulDataString appendString: kExptCodeString];
	[cumulDataString appendString: delimiter];
	[cumulDataString appendString: [self code]];
	[cumulDataString appendString: endOfLine];

	// PI
	[cumulDataString appendString: kPIString];
	[cumulDataString appendString: delimiter];
	[cumulDataString appendString: [self investigator]];
	[cumulDataString appendString: endOfLine];

	// Description
	[cumulDataString appendString: kDescriptionString];
	[cumulDataString appendString: delimiter];
	[cumulDataString appendString: [self description]];
	[cumulDataString appendString: endOfLine];
	
	// Protocol
	[cumulDataString appendString: kProtocolString];
	[cumulDataString appendString: delimiter];
	[cumulDataString appendString: [self protocol]];
	[cumulDataString appendString: endOfLine];
	
	
	// Funding
	[cumulDataString appendString: kFundingString];
	[cumulDataString appendString: delimiter];
	[cumulDataString appendString: [self funding]];
	[cumulDataString appendString: endOfLine];
	
	

}


-(void) writeDataDays; {
	
	
	
	// Phase, PhaseIndex, StartDate, EndDate, Header, Unit, Subject, and Comment are proper rows, so they need to be incremented through....


	writePhaseDays;
	writePhaseTestIndexDays;
	writeStartDateDays;
	writeEndDateDays;
	writeItemDays;
	writeUnitDays;
	writeSubjectDays;
	writeCommentDays;
	
	

}


-(void) writePhaseDays; {
	
	unsigned long dayIndex,itemIndex;

	
	// Phase
	[cumulDataString appendString: kPhaseString];
	[cumulDataString appendString: delimiter];
	
	// subject and group should be skipped
	[cumulDataString appendString: nullData];
	[cumulDataString appendString: delimiter];
	[cumulDataString appendString: nullData];
	[cumulDataString appendString: delimiter];
	
	for (itemIndex = 0; itemIndex < [self numItems]; itemIndex++) {
	
		for (dayIndex = 0; dayIndex < [self numDays]; dayIndex++) {
			
			DailyData *dailyData = [self getDataForDay:dayIndex];
			
			[cumulDataString appendString: [dailyData phaseName]];
			 
			[cumulDataString appendString: delimiter];
			 
		}
	
	}
	[cumulDataString appendString: endOfLine];
		 
}
-(void) writePhaseTestIndexDays; {
	
	unsigned long dayIndex,itemIndex;
	
	// PhaseTestIndex
	[cumulDataString appendString: kPhaseTestIndexString];
	[cumulDataString appendString: delimiter];
	
	// subject and group should be skipped
	[cumulDataString appendString: nullData];
	[cumulDataString appendString: delimiter];
	[cumulDataString appendString: nullData];
	[cumulDataString appendString: delimiter];
	
	for (itemIndex = 0; itemIndex < [self numItems]; itemIndex++) {
		
		for (dayIndex = 0; dayIndex < [self numDays]; dayIndex++) {
			
			DailyData *dailyData = [self getDataForDay:dayIndex];
			
			[cumulDataString appendString: @"%d", [dailyData phaseIndex]];
			
			[cumulDataString appendString: delimiter];
			
		}
		
	}
	
	[cumulDataString appendString: endOfLine];
	
}
	
-(void) writeStartDateDays; {
		
		unsigned long dayIndex,itemIndex;
		
		// StartDate
		[cumulDataString appendString: kStartDateString];
		[cumulDataString appendString: delimiter];
		
		// subject and group should be skipped
		[cumulDataString appendString: nullData];
		[cumulDataString appendString: delimiter];
		[cumulDataString appendString: nullData];
		[cumulDataString appendString: delimiter];
		
		for (itemIndex = 0; itemIndex < [self numItems]; itemIndex++) {
			
			for (dayIndex = 0; dayIndex < [self numDays]; dayIndex++) {
				
				DailyData *dailyData = [self getDataForDay:dayIndex];
				
				[cumulDataString appendString:[[dailyData onTime] description]];
				
				[cumulDataString appendString: delimiter];
				
			}
			
		}
		
		[cumulDataString appendString: endOfLine];
		
}

-(void) writeEndDateDays; {
		
		unsigned long dayIndex,itemIndex;
		
		// EndDate
		[cumulDataString appendString: kEndDateString];
		[cumulDataString appendString: delimiter];
		
		// subject and group should be skipped
		[cumulDataString appendString: nullData];
		[cumulDataString appendString: delimiter];
		[cumulDataString appendString: nullData];
		[cumulDataString appendString: delimiter];
		
		for (itemIndex = 0; itemIndex < [self numItems]; itemIndex++) {
			
			for (dayIndex = 0; dayIndex < [self numDays]; dayIndex++) {
				
				DailyData *dailyData = [self getDataForDay:dayIndex];
				
				[cumulDataString appendString:[[dailyData offTime] description]];
				
				[cumulDataString appendString: delimiter];
				
			}
			
		}
		
		[cumulDataString appendString: endOfLine];
		
}
-(void) writeItemDays; {
	
	unsigned long dayIndex,itemIndex;
	
	// Item
	[cumulDataString appendString: kItemString];
	[cumulDataString appendString: delimiter];
	
	// subject and group should be skipped
	[cumulDataString appendString: nullData];
	[cumulDataString appendString: delimiter];
	[cumulDataString appendString: nullData];
	[cumulDataString appendString: delimiter];
	
	for (itemIndex = 0; itemIndex < [self numItems]; itemIndex++) {
		
		BarItem *item = [self getItemAtIndex:itemIndex];
		
		for (dayIndex = 0; dayIndex < [self numDays]; dayIndex++) {
			
			
			[cumulDataString appendString:[item name]];
			
			[cumulDataString appendString: delimiter];
			
		}
		
	}
	
	[cumulDataString appendString: endOfLine];
	
}
-(void) writeUnitDays; {
	
	unsigned long dayIndex,itemIndex;
	
	// Unit
	[cumulDataString appendString: kUnitString];
	[cumulDataString appendString: delimiter];
	
	// subject and group should be skipped
	[cumulDataString appendString: nullData];
	[cumulDataString appendString: delimiter];
	[cumulDataString appendString: nullData];
	[cumulDataString appendString: delimiter];
	
	for (itemIndex = 0; itemIndex < [self numItems]; itemIndex++) {
		
		BarItem *item = [self getItemAtIndex:itemIndex];
		
		for (dayIndex = 0; dayIndex < [self numDays]; dayIndex++) {
			
			[cumulDataString appendString:[item unit]];
			
			[cumulDataString appendString: delimiter];
			
		}
		
	}
	
	[cumulDataString appendString: endOfLine];
	
}
	
-(void) writeCommentDays; {
		
	unsigned long dayIndex,itemIndex;
	
	// Comment
	[cumulDataString appendString: kCommentString];
	[cumulDataString appendString: delimiter];
	
	// subject and group should be skipped
	[cumulDataString appendString: nullData];
	[cumulDataString appendString: delimiter];
	[cumulDataString appendString: nullData];
	[cumulDataString appendString: delimiter];
	
	for (itemIndex = 0; itemIndex < [self numItems]; itemIndex++) {
		
		for (dayIndex = 0; dayIndex < [self numDays]; dayIndex++) {
			
			DailyData *dailyData = [self getDataForDay:dayIndex];
			
			[cumulDataString appendString:[dailyData comment]];
			
			[cumulDataString appendString: delimiter];
			
		}
		
	}
	
	[cumulDataString appendString: endOfLine];
	
}
	
-(void) writeSubjectDays; {
	
	unsigned long dayIndex,itemIndex,subjectIndex;
	
	// Subjects
	[cumulDataString appendString: kSubjectString];
	[cumulDataString appendString: delimiter];
	
	
	for (subjectIndex =0; subjectIndex < [self numSubjects]; subjectIndex++) {
		
		
		
	// subject and group should be skipped
	[cumulDataString appendString: [self nameOfSubjectAtIndex:subjectIndex]];
	[cumulDataString appendString: delimiter];
		[cumulDataString appendString: [self nameOfGroupOfSubjectAtIndex:subjectIndex]];
	[cumulDataString appendString: delimiter];
	
	for (itemIndex = 0; itemIndex < [self numItems]; itemIndex++) {
		
		for (dayIndex = 0; dayIndex < [self numDays]; dayIndex++) {
			
			DailyData *dailyData = [self getDataForDay:dayIndex];
			
			[cumulDataString appendString:[dailyData comment]];
			
			[cumulDataString appendString: delimiter];
			
		}
		
	}
	
	[cumulDataString appendString: endOfLine];
	
}

		
		
	
	
@end
