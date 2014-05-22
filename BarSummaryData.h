//
//  BarSummaryData.h
//  Bartender
//
//  Created by Tom Houpt on 7/5/12.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

/*
 
 To write out a BarExperiment summary data to a delimited file
 
 1. initialize a BarSummaryData object with the experiment
 
 2. call [BarSummaryData update] to put the summary data to the summaryDataString
 
 3. write the summary data out to the file with [BarSummaryData writeToFileAtPath:]
 
 */



#import <Cocoa/Cocoa.h>
#import "BarExperiment.h"

// NSArray *headerStrings = [NSArray arrayWithObjects: @"Creator", @"Version", @"Type", @"CreationDate", @"Experiment", @"ExptCode", @"Investigators", @"Description", @"Protocol", @"Funding", @"Phase", @"PhaseTestIndex",@"StartDate", @"EndDate",@"Measure",@"Unit", @"Subject", @"Comment"];


// file info fields
#define kCreatorString @"Creator"
#define kVersionString @"Version"
#define kTypeString @"Type"
#define kCreationDateString @"CreationDate"

// experimental info fields
#define kExperimentString @"Experiment"
#define kExptCodeString @"ExptCode"
#define kPIString @"Investigators"
#define kDescriptionString @"Description"
#define kProtocolString @"Protocol"
#define kFundingString @"Funding"

// daily data fields
#define kPhaseString @"Phase"
#define kPhaseTestIndexString @"PhaseTestIndex"
#define kStartDateString @"StartDate"
#define kEndDateString @"EndDate"
#define kMeasureString @"Measure"
#define kUnitString @"Unit"
#define kSubjectString @"Subject"
#define kCommentString @"Comment"

// default file delimiters
#define kTabDelimiterString @"\t"
#define kCommaDelimiterString @","
#define kReturnString @"\r"


@interface BarSummaryData : NSObject {
	
	BarExperiment *experiment;
	
	NSMutableString *summaryDataString;
	
	
	NSString *delimiter;
	NSString *endOfLine;
	NSString *nullData;

}

- (id) initWithExperiment:(BarExperiment *)expt;

- (void) setDelimiterString:(NSString *)d;
- (void) setEndOfLineString:(NSString *)e;
- (void) setNullDataString:(NSString *)nd;

- (void) writeToFileAtPath:(NSString *)myFilePath;
- (void) update;
- (void) writeHeaderRows;
- (void) writeDataRows;
- (void) writePhaseDays;
- (void) writePhaseTestIndexDays;
- (void) writeStartDateDays; 
- (void) writeEndDateDays;
- (void) writeMeasureDays;
- (void) writeUnitDays;
- (void) writeCommentDays;
- (void) writeSubjectDays; 

@end
