//
//  BarSummaryData.m
//  Bartender
//
//  Created by Tom Houpt on 7/5/12.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import "BarSummaryData.h"
#import "DailyData.h"
#import "BarItem.h"
#import "BCAlert.h"

/*
 
 To write out a BarExperiment summary data to a delimited file
 
 1. initialize a BarSummaryData object with the experiment
 
 2. call [BarSummaryData update] to put the summary data to the summaryDataString
 
 3. write the summary data out to the file with [BarSummaryData writeToFileAtPath:]
 
*/


@implementation BarSummaryData


/*
 
 Rows
 
 // ID
 "Experiment"
 "ExptCode"
 "Description"

 
 // file info fields
"CreationDate" of this summary data file
"Creator"
"Version"
"Type"
 
 // experiment info fields
"Investigators"
"Protocol"
"Funding"
 
 // daily data  fields
"Phase"
"PhaseTestIndex"
"StartDate"
"EndDate"
"Measure"
"Unit"
"Subject"
"Comment"
 
 
 Columns
 summary data includes 
 1. column of header information
 2. Subject name column
 3. Group name column
 4. measure columns for each day of dailydata
	measures include: 
		a. items specified in experiment (food, water, saccharin)
		b. derived measures: preference (e.g. saccharin / total sac + water) and total (sac + water)
 
 */
		

/*
 
 To write out a BarExperiment summary data to a delimited file
 
 1. initialize a BarSummaryData object with the experiment
 
 2. call [BarSummaryData update] to put the summary data to the summaryDataString
 
 3. set the file path with [BarSummaryData setMyFilePath:fp]
 
 4. write the summary data out to the file with [BarSummaryData writeToFile]
 
*/

#define kTabDelimiterString @"\t"
#define kCarriageReturnString @"\r"
#define kNullDataString @"--"

-(id)initWithExperiment:(BarExperiment *)expt; {

	self = [super init];
	if (self) {
		
		experiment = expt;
		
		// set default delimiter
		delimiter = kTabDelimiterString;
		
		// set default end of line character
		endOfLine = kCarriageReturnString;
		
		nullData = kNullDataString;

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

-(void) writeToFileAtPath:(NSString *)myFilePath; {
	if (nil == myFilePath) return;
	
	if (nil == summaryDataString) return;
	
	NSError *error;
	BOOL ok = [summaryDataString writeToFile:myFilePath atomically:YES encoding:NSUnicodeStringEncoding error:&error];
	
	if (!ok) {
		
		NSLog(@"BarSummaryData: Error writing file at %@\n%@", myFilePath, [error localizedDescription]);
		
		NSString *alertMessage = [NSString stringWithFormat:@"There was an error saving the summary data file at %@",myFilePath];
				
		BCOneButtonAlert(NSWarningAlertStyle,alertMessage, [error localizedDescription], @"OK");

		
	}
		
}

-(void) update; {
	
	if (nil == experiment) return;
	
	// put all the data into this buffer:
	summaryDataString = [[NSMutableString alloc] init];
	
	[self writeHeaderRows];
	[self writeDataRows];	
	
}

-(void) writeHeaderRows; {
	
	// header lines...
	
	// update if the file format changes...
	NSString *myCreatorString = @"Bartender";
	NSString *myVersionString = @"2.00";
	NSString *myTypeString = @"Summary Data";
	
	// experiment
	[summaryDataString appendString: kExperimentString]; [summaryDataString appendString: delimiter];
	[summaryDataString appendString: [experiment name]]; [summaryDataString appendString: endOfLine];
	
	// ExptCode
	[summaryDataString appendString: kExptCodeString];[summaryDataString appendString: delimiter];
	[summaryDataString appendString: [experiment code]];[summaryDataString appendString: endOfLine];

	// Description
	[summaryDataString appendString: kDescriptionString];[summaryDataString appendString: delimiter];
	[summaryDataString appendString: [experiment description]];[summaryDataString appendString: endOfLine];
	
	
	// creationDate
	[summaryDataString appendString: kCreationDateString];[summaryDataString appendString: delimiter];
	[summaryDataString appendString: [[NSDate date] description]];[summaryDataString appendString: endOfLine];
	
	

	// creator line
	[summaryDataString appendString: kCreatorString]; [summaryDataString appendString: delimiter];
	[summaryDataString appendString: myCreatorString]; [summaryDataString appendString: endOfLine];

	// version
	[summaryDataString appendString: kVersionString]; [summaryDataString appendString: delimiter];
	[summaryDataString appendString: myVersionString]; [summaryDataString appendString: endOfLine];

	// type
	[summaryDataString appendString: kTypeString]; [summaryDataString appendString: delimiter];
	[summaryDataString appendString: myTypeString]; [summaryDataString appendString: endOfLine];
	

	// PI
	[summaryDataString appendString: kPIString]; [summaryDataString appendString: delimiter];
	[summaryDataString appendString: [experiment investigators]]; [summaryDataString appendString: endOfLine];

	
	// Protocol
	[summaryDataString appendString: kProtocolString]; [summaryDataString appendString: delimiter];
	[summaryDataString appendString: [experiment protocol]]; [summaryDataString appendString: endOfLine];
	
	
	// Funding
	[summaryDataString appendString: kFundingString]; [summaryDataString appendString: delimiter];
	[summaryDataString appendString: [experiment funding]]; [summaryDataString appendString: endOfLine];
	
}


-(void) writeDataRows; {
		
	// Phase, PhaseIndex, StartDate, EndDate, Measure, Unit, Subject, and Comment are proper rows, 
	// so they need to be incremented through the days of data....

	NSLog(@"BarSummaryData: entering writeDataRows");
	
	[self writePhaseDays];
	[self writePhaseTestIndexDays];
	[self writeStartDateDays];
	[self writeEndDateDays];
	[self writeMeasureDays];
	[self writeUnitDays];
	[self writeSubjectDays];
	[self writeCommentDays];
	
	NSLog(@"BarSummaryData: leaving writeDataRows");

}


-(void) writePhaseDays; {
	
	NSUInteger dayIndex,measureIndex;

	NSLog(@"BarSummaryData: entering writePhaseDays");


	// Phase
	[summaryDataString appendString: kPhaseString];
	[summaryDataString appendString: delimiter];
	
	// subject and group should be skipped
	[summaryDataString appendString: nullData];
	[summaryDataString appendString: delimiter];
	[summaryDataString appendString: nullData];
	[summaryDataString appendString: delimiter];
	
	NSUInteger numColumns = [experiment numberOfItems];
	if ([experiment hasPreference]) numColumns+= 2; // will have preference and total for each day
		
	for (measureIndex = 0; measureIndex < numColumns; measureIndex++) {
	
		for (dayIndex = 0; dayIndex < [experiment numberOfDays]; dayIndex++) {
			
			DailyData *dailyData = [experiment dailyDataForDay:dayIndex];
			
			if (0 == [[dailyData phaseName] length]) { [summaryDataString appendString:kNoDataCellText]; }
			else { [summaryDataString appendString:[dailyData phaseName]]; }
			 
			[summaryDataString appendString: delimiter];
			 
		}
        NSLog(@"Day #%ld",dayIndex);
	
	}
	[summaryDataString appendString: endOfLine];
	
	NSLog(@"BarSummaryData: leaving writePhaseDays");

		 
}
-(void) writePhaseTestIndexDays; {
	
	NSUInteger dayIndex,measureIndex;
	
	NSLog(@"BarSummaryData: entering writePhaseTestIndexDays");

	
	// PhaseTestIndex
	[summaryDataString appendString: kPhaseTestIndexString];
	[summaryDataString appendString: delimiter];
	
	// subject and group should be skipped
	[summaryDataString appendString: nullData];
	[summaryDataString appendString: delimiter];
	[summaryDataString appendString: nullData];
	[summaryDataString appendString: delimiter];
	
	NSUInteger numColumns = [experiment numberOfItems];
	if ([experiment hasPreference]) numColumns+= 2; // will have preference and total for each day

	
	for (measureIndex = 0; measureIndex < numColumns; measureIndex++) {
		
		for (dayIndex = 0; dayIndex < [experiment numberOfDays]; dayIndex++) {
			
			DailyData *dailyData = [experiment dailyDataForDay:dayIndex];
			
			if (0 == [[dailyData phaseName] length]) {[summaryDataString appendFormat: kNullDataString]; }
			
			else { [summaryDataString appendFormat: @"%ld", [dailyData phaseDayIndex] + 1]; }
			
			[summaryDataString appendString: delimiter];
			
		}
		
	}
	
	[summaryDataString appendString: endOfLine];
	
	NSLog(@"BarSummaryData: leaving writePhaseTestIndexDays");

	
}
	
-(void) writeStartDateDays; {
		
    NSUInteger dayIndex,measureIndex;
	
	NSLog(@"BarSummaryData: entering writeStartDateDays");

		
		// StartDate
		[summaryDataString appendString: kStartDateString];
		[summaryDataString appendString: delimiter];
		
		// subject and group should be skipped
		[summaryDataString appendString: nullData];
		[summaryDataString appendString: delimiter];
		[summaryDataString appendString: nullData];
		[summaryDataString appendString: delimiter];
	
		NSUInteger numColumns = [experiment numberOfItems];
		if ([experiment hasPreference]) numColumns+= 2; // will have preference and total for each day

		
		for (measureIndex = 0; measureIndex < numColumns; measureIndex++) {
			
			for (dayIndex = 0; dayIndex < [experiment numberOfDays]; dayIndex++) {
				
				DailyData *dailyData = [experiment dailyDataForDay:dayIndex];
				
				[summaryDataString appendString:[dailyData onTimeDescription]];
				
				[summaryDataString appendString: delimiter];
				
			}
			
		}
		
		[summaryDataString appendString: endOfLine];
		
	NSLog(@"BarSummaryData: leaving writeStartDateDays");

}

-(void) writeEndDateDays; {
		
	NSUInteger dayIndex,measureIndex;
	
	NSLog(@"BarSummaryData: entering writeEndDateDays");

		
		// EndDate
		[summaryDataString appendString: kEndDateString];
		[summaryDataString appendString: delimiter];
		
		// subject and group should be skipped
		[summaryDataString appendString: nullData];
		[summaryDataString appendString: delimiter];
		[summaryDataString appendString: nullData];
		[summaryDataString appendString: delimiter];
	
		NSUInteger numColumns = [experiment numberOfItems];
		if ([experiment hasPreference]) numColumns+= 2; // will have preference and total for each day
		
		for (measureIndex = 0; measureIndex < numColumns; measureIndex++) {
			
			for (dayIndex = 0; dayIndex < [experiment numberOfDays]; dayIndex++) {
				
				DailyData *dailyData = [experiment dailyDataForDay:dayIndex];
				
				[summaryDataString appendString:[dailyData offTimeDescription]];
				
				[summaryDataString appendString: delimiter];
				
			}
			
		}
		
		[summaryDataString appendString: endOfLine];
	
	NSLog(@"BarSummaryData: leaving writeEndDateDays");

		
}
-(void) writeMeasureDays; {
	
	NSUInteger dayIndex,itemIndex;
	
	NSLog(@"BarSummaryData: entering writeMeasureDays");

	
	// Item
	[summaryDataString appendString: kMeasureString];
	[summaryDataString appendString: delimiter];
	
	// label the subject and group measures
	[summaryDataString appendString: @"Subject"];
	[summaryDataString appendString: delimiter];
	[summaryDataString appendString: @"Group"];
	[summaryDataString appendString: delimiter];
	
	for (itemIndex = 0; itemIndex < [experiment numberOfItems]; itemIndex++) {
		
		BarItem *item = [experiment itemAtIndex:itemIndex];
		
		for (dayIndex = 0; dayIndex < [experiment numberOfDays]; dayIndex++) {
			
			
			[summaryDataString appendString:[item name]];
			
			[summaryDataString appendString: delimiter];
			
		}
		
	}
	
	if ([experiment hasPreference]) { 
		
		// get preference
		for (dayIndex = 0; dayIndex < [experiment numberOfDays]; dayIndex++) {
			
			
			[summaryDataString appendString: [experiment preferenceTitleText]  ];
			
			[summaryDataString appendString: delimiter];
			
		}
		
		
		// get total
		for (dayIndex = 0; dayIndex < [experiment numberOfDays]; dayIndex++) {
			
			
			[summaryDataString appendString: [experiment totalTitleText] ]; 
						
			[summaryDataString appendString: delimiter];
			
		}
		
	} // has preference
	
	
	
	[summaryDataString appendString: endOfLine];
	
	NSLog(@"BarSummaryData: leaving writeMeasureDays");

	
}
-(void) writeUnitDays; {
	
	NSLog(@"BarSummaryData: entering writeUnitDays");

	
	NSUInteger dayIndex,itemIndex;
	
	// Unit
	[summaryDataString appendString: kUnitString];
	[summaryDataString appendString: delimiter];
	
	// subject and group should be skipped
	[summaryDataString appendString: nullData];
	[summaryDataString appendString: delimiter];
	[summaryDataString appendString: nullData];
	[summaryDataString appendString: delimiter];
	
	for (itemIndex = 0; itemIndex < [experiment numberOfItems]; itemIndex++) {
		
		BarItem *item = [experiment itemAtIndex:itemIndex];
		
		for (dayIndex = 0; dayIndex < [experiment numberOfDays]; dayIndex++) {
			
			[summaryDataString appendString:[item unit]];
			
			[summaryDataString appendString: delimiter];
			
		}
		
	}
	
	if ([experiment hasPreference]) { 
		
		// get preference units ( == units less )
		
		for (dayIndex = 0; dayIndex < [experiment numberOfDays]; dayIndex++) {
			
			[summaryDataString appendString: nullData  ];
			
			[summaryDataString appendString: delimiter];
			
		}
		
		// get total units
		
		NSUInteger prefItem,baseItem;

		[experiment getIndexOfPreferenceItem:&prefItem overItem:&baseItem];
		
		BarItem *item = [experiment itemAtIndex:prefItem];
		
		
		for (dayIndex = 0; dayIndex < [experiment numberOfDays]; dayIndex++) {
						
			[summaryDataString appendString: [item unit] ]; 
			
			[summaryDataString appendString: delimiter];
			
		}
		
	} // has preference
	
	
	[summaryDataString appendString: endOfLine];
	
	NSLog(@"BarSummaryData: leaving writeUnitDays");

	
}
	
-(void) writeCommentDays; {
		
	NSUInteger dayIndex,measureIndex;
	
	NSLog(@"BarSummaryData: entering writeCommentDays");

	
	// Comment
	[summaryDataString appendString: kCommentString];
	[summaryDataString appendString: delimiter];
	
	// subject and group should be skipped
	[summaryDataString appendString: nullData];
	[summaryDataString appendString: delimiter];
	[summaryDataString appendString: nullData];
	[summaryDataString appendString: delimiter];
	
	NSUInteger numColumns = [experiment numberOfItems];
	if ([experiment hasPreference]) numColumns+= 2; // will have preference and total for each day

	
	for (measureIndex = 0; measureIndex < numColumns; measureIndex++) {
		
		for (dayIndex = 0; dayIndex < [experiment numberOfDays]; dayIndex++) {
			
			DailyData *dailyData = [experiment dailyDataForDay:dayIndex];
			
			[summaryDataString appendString:[dailyData comment]];
			
			[summaryDataString appendString: delimiter];
			
		}
		
	}
	
	[summaryDataString appendString: endOfLine];
	
	NSLog(@"BarSummaryData: leaving writeCommentDays");

}
	
-(void) writeSubjectDays; {
	
	NSUInteger dayIndex,itemIndex,subjectIndex;
	
	NSLog(@"BarSummaryData: entering writeSubjectDays");

	
	
	for (subjectIndex =0; subjectIndex < [experiment numberOfSubjects]; subjectIndex++) {
		
		// "Subjects" header in first column
		[summaryDataString appendString: kSubjectString];
		[summaryDataString appendString: delimiter];

		// subject and group name
		[summaryDataString appendString: [experiment nameOfSubjectAtIndex:subjectIndex]];
		[summaryDataString appendString: delimiter];
		[summaryDataString appendString: [experiment nameOfGroupOfSubjectAtIndex:subjectIndex]];
		[summaryDataString appendString: delimiter];
		
		for (itemIndex = 0; itemIndex < [experiment numberOfItems]; itemIndex++) {
			
			NSString *itemName = [[experiment itemAtIndex:itemIndex] name];
			
			for (dayIndex = 0; dayIndex < [experiment numberOfDays]; dayIndex++) {
				
				DailyData *dailyData = [experiment dailyDataForDay:dayIndex];
				
				[summaryDataString appendString: [dailyData getTextForItem:itemName atTerm:kWeightDelta forRat:subjectIndex]  ];
				
				[summaryDataString appendString: delimiter];
				
			} // days
			
		} // items
			
			
		if ([experiment hasPreference]) { 
			
			// get preference
			for (dayIndex = 0; dayIndex < [experiment numberOfDays]; dayIndex++) {
				
				DailyData *dailyData = [experiment dailyDataForDay:dayIndex];
				
				[summaryDataString appendString: [dailyData getPreferenceScoreTextForRat:subjectIndex]  ];
				
				[summaryDataString appendString: delimiter];
				
			}
		
		
			// get total
			for (dayIndex = 0; dayIndex < [experiment numberOfDays]; dayIndex++) {
				
				DailyData *dailyData = [experiment dailyDataForDay:dayIndex];
				
				[summaryDataString appendString: [dailyData getTotalTextForRat:subjectIndex]  ];
				
				[summaryDataString appendString: delimiter];
				
			}
						
		} // has preference
		
		[summaryDataString appendString: endOfLine];
		
		
	} // next subject
	
	NSLog(@"BarSummaryData: leaving writeSubjectDays");

	
}

	
@end
