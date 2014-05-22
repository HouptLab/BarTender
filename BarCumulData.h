//
//  BarSummaryData.h
//  Bartender
//
//  Created by Tom Houpt on 7/5/12.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// NSArray *headerStrings = [NSArray arrayWithObjects: @"Creator", @"Version", @"Type", @"CreationDate", @"Experiment", @"ExptCode", @"Investigators", @"Description", @"Protocol", @"Funding", @"Phase", @"PhaseTestIndex",@"StartDate", @"EndDate",@"Item",@"Unit", @"Subject", @"Comment"];



#define kCreatorString @"Creator"
#define kVersionString @"Version"
#define kTypeString @"Type"
#define kCreationDateString @"CreationDate"
#define kExperimentString @"Experiment"
#define kExptCodeString @"ExptCode"
#define kPIString @"Investigators"
#define kDescriptionString @"Description"
#define kProtocolString @"Protocol"
#define kFundingString @"Funding"


#define kPhaseString @"Phase"
#define kPhaseTestIndexString @"PhaseTestIndex"
#define kStartDateString @"StartDate"
#define kEndDateString @"EndDate"
#define kItemString @"Item"
#define kUnitString @"Unit"
#define kSubjectString @"Subject"
#define kCommentString @"Comment"

#define kTabDelimiterString @"\t"
#define kCommaDelimiterString @","
#define kReturnString @"\r"


// use these codes for tab and return
// kTabCharCode
// kReturnCharCode


@interface BarCumulData : NSObject {
	
	
	NSMutableString *cumulDataString;
	NSString *delimiter;
	NSString *endOfLine;
	NSString *nullData;
	
	NSString *myFilePath;
			   
}

@end
