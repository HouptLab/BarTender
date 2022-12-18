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
#import "BarSubject.h"
#import "BCAlert.h"
#import "FirebaseSummary.h"
#import "BCMergeDictionary.h"

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
"Project"
 
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
   
        numDataDays = [experiment numberOfDays];
         // load all daily data into memory
        dailyDataArray = [NSMutableArray arrayWithCapacity: numDataDays];
        for (NSUInteger d=0;d< numDataDays; d++ )  {
            [dailyDataArray addObject: [experiment dailyDataForDay:d]];
        }
		
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

-(void) writeToFirebase; {

      FirebaseSummary *firebase = [[FirebaseSummary alloc] init]; 
    
    // put experiment data into a dictionary which we can then serialize as json
    NSMutableDictionary *exptDictionary = [NSMutableDictionary dictionary];

    NSDictionary *contacts = @{ @"Tom Houpt" : @{ @"email" : @"[EMAIL]",  @"phone" : @"[PHONE]" }};

    [exptDictionary setObject: contacts
                       forKey:@"contacts"];


    NSMutableDictionary *drugs = [NSMutableDictionary dictionary];
    for (NSUInteger i=0;i< [experiment numberOfDrugs]; i++ ) {
        [drugs setObject: [[[experiment drugs] objectAtIndex:i] description]
                   forKey: [[[experiment drugs] objectAtIndex:i] name]];
    }

    [exptDictionary setObject: drugs
                       forKey:@"drugs"];

    NSMutableDictionary *groups = [NSMutableDictionary dictionary];
    for (NSUInteger i=0;i< [experiment numberOfGroups]; i++ ) {
        [groups setObject: [[[experiment groups] objectAtIndex:i] description]
                   forKey: [[[experiment groups] objectAtIndex:i] name]];
    }
    [exptDictionary setObject: groups
                       forKey:@"groups"];

    [exptDictionary setObject: [experiment investigators]
                       forKey:@"investigators"];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];

    [formatter setDateFormat:kDateWithDayFormatString];

    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];

    [exptDictionary setObject: dateString
                       forKey:@"last_uploaded"];



    NSString *lastString = [formatter stringFromDate:[experiment last_data_update]];

    [exptDictionary setObject: lastString
                       forKey:@"last_updated"];
                       
     NSNumber *lastMS =  [NSNumber numberWithInteger: (NSInteger)([[experiment last_data_update] timeIntervalSince1970] * 1000.0)];
     [exptDictionary setObject: lastMS
                       forKey:@"last_updated_ms"];



//    NSMutableString *measures = [NSMutableString string];
//
//    for (NSUInteger i=0;i< [experiment numberOfItems]; i++ ) {
//        [measures appendString: [[[experiment items] objectAtIndex:i] name]];
//        [measures appendString: @","];
//    }

    NSMutableDictionary *measures = [NSMutableDictionary dictionary];
    for (NSUInteger i=0;i< [experiment numberOfItems]; i++ ) {
        [measures setObject: [[[experiment items] objectAtIndex:i] description]
                   forKey: [[[experiment items] objectAtIndex:i] name]];
    }
    if ([experiment hasPreference]) {
        NSUInteger topitem,bottomitem;
        [experiment getIndexOfPreferenceItem:&topitem overItem:&bottomitem];
         NSString *name = [NSString stringWithFormat:@"%@ Preference",[[[experiment items] objectAtIndex:topitem] name] ];
         NSString *description;
         if ([experiment usePreferenceOverTotal]) {
             description = [NSString stringWithFormat:@"Preference for %@ over total %@ + %@",
                            [[[experiment items] objectAtIndex:topitem] name] ,
                            [[[experiment items] objectAtIndex:topitem] name] ,
                            [[[experiment items] objectAtIndex:bottomitem] name] ];
         } else {
         description = [NSString stringWithFormat:@"Preference for %@ over %@",
                            [[[experiment items] objectAtIndex:topitem] name] ,
                        [[[experiment items] objectAtIndex:bottomitem] name] ];
         }
        [measures setObject: description
                     forKey: name];        
    }
    


    [exptDictionary setObject: measures
                       forKey:@"measures"];


    [exptDictionary setObject: [experiment name]
                        forKey:@"name"];

    [exptDictionary setObject: [experiment code]
                       forKey:@"code"];
    
    [exptDictionary setObject: [experiment project_name]
                       forKey:@"project_name"];
    
    [exptDictionary setObject: [experiment project_code]
                       forKey:@"project_code"];
    
    [exptDictionary setObject: [NSNumber numberWithUnsignedInteger:[experiment numberOfSubjects]]
                       forKey:@"num_subjects"];

    [exptDictionary setObject: [experiment protocol]
                       forKey:@"protocol"];

  [exptDictionary setObject: [experiment wiki]
                       forKey:@"wikipage"];

    NSDateFormatter *offDateFormatter = [[NSDateFormatter alloc] init];
    [offDateFormatter setDateFormat:kDateFormatString];
    
   
    
    NSMutableDictionary *subjects = [NSMutableDictionary dictionary];
    for (NSUInteger s=0;s< [experiment numberOfSubjects]; s++ ) {

         NSMutableDictionary *subject = [NSMutableDictionary dictionary];

            NSMutableDictionary *subject_data = [NSMutableDictionary dictionary];
            for (NSUInteger i=0;i< [experiment numberOfItems]; i++ ) {
                NSMutableDictionary *item_data = [NSMutableDictionary dictionary];

                
                 for (NSUInteger d=0;d< numDataDays; d++ ) {
                     double onwgt, offwgt, deltawgt;

                     DailyData *dailyData = (DailyData *)[dailyDataArray objectAtIndex:d];;
                     [dailyData getWeightsForRat:s andItem:i onWeight:&onwgt offWeight:&offwgt deltaWeight:&deltawgt];

                     [item_data setObject: [NSNumber numberWithDouble:deltawgt]
                                   forKey: [offDateFormatter stringFromDate:[dailyData offTime]]];

                 }

                [subject_data setObject: item_data
                                 forKey: [[[experiment items] objectAtIndex:i] name]];

            }            
            if ([experiment hasPreference]) {
                
                NSUInteger topitem,bottomitem;
                [experiment getIndexOfPreferenceItem:&topitem overItem:&bottomitem];
                NSString *name = [NSString stringWithFormat:@"%@ Preference",[[[experiment items] objectAtIndex:topitem] name] ];
                
                NSMutableDictionary *item_data = [NSMutableDictionary dictionary];
                
                for (NSUInteger d=0;d< numDataDays; d++ ) {
                    double onwgt, offwgt, top_deltawgt,bottom_deltawgt;
                    
                    DailyData *dailyData = (DailyData *)[dailyDataArray objectAtIndex:d];;
                    [dailyData getWeightsForRat:s andItem:topitem onWeight:&onwgt offWeight:&offwgt deltaWeight:&top_deltawgt];
                    [dailyData getWeightsForRat:s andItem:bottomitem onWeight:&onwgt offWeight:&offwgt deltaWeight:&bottom_deltawgt];
                    
                    double preference = -32000;
                    
                    if (-32000 != top_deltawgt && -32000 != bottom_deltawgt){
                        if ([experiment usePreferenceOverTotal]) {
                            double denominator = top_deltawgt + bottom_deltawgt;
                            if (denominator != 0) {
                                preference = top_deltawgt / denominator;
                            }
                        }
                        else {
                            if (bottom_deltawgt != 0) {
                                preference = top_deltawgt / bottom_deltawgt;
                            }
                        }
                    }
                    [item_data setObject: [NSNumber numberWithDouble:preference]
                                  forKey: [offDateFormatter stringFromDate:[dailyData offTime]]];
                } // next day
    
                [subject_data setObject: item_data
                                 forKey: name];
            } // has preference
   
        [subject setObject:subject_data
                    forKey: @"data"];

        NSUInteger groupIndex = [(BarSubject *)[[experiment subjects] objectAtIndex:s] groupIndex];

        [subject setObject: [[[experiment groups] objectAtIndex:groupIndex] name]
                    forKey: @"group"];

        NSString *subjectName = [NSString stringWithFormat:@"%@%02ld",[experiment code],(s+1)];
        [subjects setObject: subject
                   forKey:subjectName];
    }

    [exptDictionary setObject: subjects
                       forKey:@"subjects"];

    [exptDictionary setObject: [self getMeans]
                       forKey:@"group_means"];
    
    NSError *error;
    NSData *currentExptJSONData = [firebase getExpt:[experiment code]];
   //  NSData *targetExptJSONData = [targetExptJSON dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSDictionary *currentExptDictionary = [NSJSONSerialization JSONObjectWithData:currentExptJSONData options:kNilOptions error:&error];
    
    [exptDictionary mergeWithSourceDictionary: currentExptDictionary];
  
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:exptDictionary
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
//    NSString *jsonString = NULL;
//    if (! jsonData) {
//        NSLog(@"Got an error: %@", error);
//    } else {
//        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    }

    // NSString *merged_code = [NSString stringWithFormat:@"%@_merged",[experiment code] ];
    
    NSString *merged_code = [experiment code];
    
    if (NULL != jsonData) {
        [[[FirebaseSummary alloc] init] saveExpt:merged_code withData:jsonData];
    }
}

-(NSDictionary *)getMeans; {

// TODO: instantiate an "unassigned group" if there are subjects that are not in a group
    
    NSDateFormatter *offDateFormatter = [[NSDateFormatter alloc] init];
    [offDateFormatter setDateFormat:kDateFormatString];
    
    NSMutableDictionary *group_means = [NSMutableDictionary dictionary];
    for (NSUInteger g=0;g< [experiment numberOfGroups]; g++ ) {
        
        NSMutableDictionary *group_data = [NSMutableDictionary dictionary];
        for (NSUInteger i=0;i< [experiment numberOfItems]; i++ ) {
            NSMutableDictionary *item_data = [NSMutableDictionary dictionary];
                for (NSUInteger d=0;d< numDataDays; d++ ) {
                double onwgt, offwgt, deltawgt;
                
                DailyData *dailyData = (DailyData *)[dailyDataArray objectAtIndex:d];
                
                double mean = 0, count=0, sem = 0,M2=0,delta,delta2;
                
                for (NSUInteger s=0;s< [experiment numberOfSubjects]; s++ ) {
                    
                    BarSubject *subject = [experiment subjectAtIndex:s];
                    if (g == [subject groupIndex]) {
                        
                        [dailyData getWeightsForRat:s andItem:i onWeight:&onwgt offWeight:&offwgt deltaWeight:&deltawgt];
            
                        if (-32000 != deltawgt){
                            count += 1;
                            delta = deltawgt - mean;
                            mean += delta / count;
                            delta2 = deltawgt - mean;
                            M2 += delta * delta2;
                        }

                                                
                    } // right group
                } // next subject
                
                if (0 == count) { mean = -32000; }
                if (count >= 2) { sem = sqrt( M2/(count-1))/ sqrt(count); }
                    [item_data setObject: @{ 
                       @"mean":[NSNumber numberWithDouble:mean], 
                       @"n": [NSNumber numberWithUnsignedInteger:(unsigned long)count],
                       @"sem": [NSNumber numberWithDouble:sem]}
                              forKey: [offDateFormatter stringFromDate:[dailyData offTime]]];
                
            } // next day
            
            [group_data setObject: item_data
                             forKey: [[[experiment items] objectAtIndex:i] name]];
            
        }  // next item      
        if ([experiment hasPreference]) {
            
            NSUInteger topitem,bottomitem;
            [experiment getIndexOfPreferenceItem:&topitem overItem:&bottomitem];
            NSString *name = [NSString stringWithFormat:@"%@ Preference",[[[experiment items] objectAtIndex:topitem] name] ];
            
            NSMutableDictionary *item_data = [NSMutableDictionary dictionary];
            
            for (NSUInteger d=0;d< numDataDays; d++ ) {
                double onwgt, offwgt, top_deltawgt,bottom_deltawgt;
                
                DailyData *dailyData = (DailyData *)[dailyDataArray objectAtIndex:d];;
                double mean = 0, count=0, sem = 0,M2=0,delta,delta2;
                
                for (NSUInteger s=0;s< [experiment numberOfSubjects]; s++ ) {
                    
                    BarSubject *subject = [experiment subjectAtIndex:s];
                    if (g == [subject groupIndex]) {
                        [dailyData getWeightsForRat:s andItem:topitem onWeight:&onwgt offWeight:&offwgt deltaWeight:&top_deltawgt];
                        [dailyData getWeightsForRat:s andItem:bottomitem onWeight:&onwgt offWeight:&offwgt deltaWeight:&bottom_deltawgt];
                
                        double preference = -32000;
                        
                        if (-32000 != top_deltawgt && -32000 != bottom_deltawgt){
                            if ([experiment usePreferenceOverTotal]) {
                                double denominator = top_deltawgt + bottom_deltawgt;
                                if (denominator != 0) {
                                    preference = top_deltawgt / denominator;
                                }
                            }
                            else {
                                if (bottom_deltawgt != 0) {
                                    preference = top_deltawgt / bottom_deltawgt;
                                }
                            }
                        }
                        
                        if (preference != -32000) {
                            count += 1;
                            delta = preference - mean;
                            mean += delta / count;
                            delta2 = preference - mean;
                            M2 += delta * delta2;
                            
                        }
                    } // right group g  
                } // next s
                if (0 == count) { mean = -32000; }
                if (count >= 2) { sem = sqrt( M2/(count-1))/ sqrt(count); }
                [item_data setObject: @{ @"mean":[NSNumber numberWithDouble:mean], @"sem": [NSNumber numberWithDouble:sem]}
                              forKey: [offDateFormatter stringFromDate:[dailyData offTime]]];
            } // next day
            
            [group_data setObject: item_data
                               forKey: name];
        } // has preference
        
        [group_means setObject: group_data
                        forKey: [experiment nameOfGroupAtIndex:g]];
    } // next group
        
    return group_means;
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
	
	
	// Project
    // experiment
    [summaryDataString appendString: kProjectString]; [summaryDataString appendString: delimiter];
    [summaryDataString appendString: [experiment project_name]]; [summaryDataString appendString: endOfLine];
    
    // ExptCode
    [summaryDataString appendString: kProjectCodeString];[summaryDataString appendString: delimiter];
    [summaryDataString appendString: [experiment project_code]];[summaryDataString appendString: endOfLine];	
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
	
		for (dayIndex = 0; dayIndex < numDataDays; dayIndex++) {
			
			DailyData *dailyData = (DailyData *)[dailyDataArray objectAtIndex:dayIndex];
			
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
		
		for (dayIndex = 0; dayIndex < numDataDays; dayIndex++) {
			
			DailyData *dailyData = (DailyData *)[dailyDataArray objectAtIndex:dayIndex];
			
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
			
			for (dayIndex = 0; dayIndex < numDataDays; dayIndex++) {
				
				DailyData *dailyData = (DailyData *)[dailyDataArray objectAtIndex:dayIndex];
				
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
			
			for (dayIndex = 0; dayIndex < numDataDays; dayIndex++) {
				
				DailyData *dailyData = (DailyData *)[dailyDataArray objectAtIndex:dayIndex];
				
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
		
		for (dayIndex = 0; dayIndex < numDataDays; dayIndex++) {
			
			
			[summaryDataString appendString:[item name]];
			
			[summaryDataString appendString: delimiter];
			
		}
		
	}
	
	if ([experiment hasPreference]) { 
		
		// get preference
		for (dayIndex = 0; dayIndex < numDataDays; dayIndex++) {
			
			
			[summaryDataString appendString: [experiment preferenceTitleText]  ];
			
			[summaryDataString appendString: delimiter];
			
		}
		
		
		// get total
		for (dayIndex = 0; dayIndex < numDataDays; dayIndex++) {
			
			
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
		
		for (dayIndex = 0; dayIndex < numDataDays; dayIndex++) {
			
			[summaryDataString appendString:[item unit]];
			
			[summaryDataString appendString: delimiter];
			
		}
		
	}
	
	if ([experiment hasPreference]) { 
		
		// get preference units ( == units less )
		
		for (dayIndex = 0; dayIndex < numDataDays; dayIndex++) {
			
			[summaryDataString appendString: nullData  ];
			
			[summaryDataString appendString: delimiter];
			
		}
		
		// get total units
		
		NSUInteger prefItem,baseItem;

		[experiment getIndexOfPreferenceItem:&prefItem overItem:&baseItem];
		
		BarItem *item = [experiment itemAtIndex:prefItem];
		
		
		for (dayIndex = 0; dayIndex < numDataDays; dayIndex++) {
						
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
		
		for (dayIndex = 0; dayIndex < numDataDays; dayIndex++) {
			
			DailyData *dailyData = (DailyData *)[dailyDataArray objectAtIndex:dayIndex];
			
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
			
			for (dayIndex = 0; dayIndex < numDataDays; dayIndex++) {
				
				DailyData *dailyData = (DailyData *)[dailyDataArray objectAtIndex:dayIndex];
				
				[summaryDataString appendString: [dailyData getTextForItem:itemName atTerm:kWeightDelta forRat:subjectIndex]  ];
				
				[summaryDataString appendString: delimiter];
				
			} // days
			
		} // items
			
			
		if ([experiment hasPreference]) { 
			
			// get preference
			for (dayIndex = 0; dayIndex < numDataDays; dayIndex++) {
				
				DailyData *dailyData = (DailyData *)[dailyDataArray objectAtIndex:dayIndex];
				
				[summaryDataString appendString: [dailyData getPreferenceScoreTextForRat:subjectIndex]  ];
				
				[summaryDataString appendString: delimiter];
				
			}
		
		
			// get total
			for (dayIndex = 0; dayIndex < numDataDays; dayIndex++) {
				
				DailyData *dailyData = (DailyData *)[dailyDataArray objectAtIndex:dayIndex];
				
				[summaryDataString appendString: [dailyData getTotalTextForRat:subjectIndex]  ];
				
				[summaryDataString appendString: delimiter];
				
			}
						
		} // has preference
		
		[summaryDataString appendString: endOfLine];
		
		
	} // next subject
	
	NSLog(@"BarSummaryData: leaving writeSubjectDays");

	
}

	
@end
