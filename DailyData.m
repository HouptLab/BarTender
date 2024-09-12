//
//  DailyData.m
//  Bartender
//
//  Created by Tom Houpt on 12/7/10.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "BarExperiment.h"
#import "BarDocument.h"
#import "DailyData.h"
#import "BarItem.h"
#import "BarGroup.h"

// weight arrays are only allocated when experiment is assigned.
// experiment is assigned either by initFromPath:withExperiment when dailyData is loaded into BarExperiment memory
// or when label is parsed to identify experiment for first time
// or when specific experiment weighing is invoked with initWithExperiment: 

@implementation DailyData

-(id)init; {
    self = [super init];
    if (self) {
		
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		[self setDefaults];
    }
    return self;
}

-(id)initFromPath:(NSString *)path withExperiment:(BarExperiment *)theExpt; {
	// load data from file at specified path; not used for weighing
    self = [super init];
    if (self) {
		// NSLog(@"DailyData: initFromPath");
 		[self setDefaults];
		[self setTheExperiment:theExpt];
		[self setCurrentState:kDataOnly]; // only loading data to access data, not for display or editing
		[self readFromPath:path];
		
    }
    return self;
}

-(id)initWithExperiment:(BarExperiment *)theExpt; {
	
    self = [super init];
    if (self) {
		
 		[self setDefaults];
		[self setTheExperiment:theExpt];		
    }
    return self;
}

-(void)dealloc; {
	
	// NSLog(@"DailyData:	dealloc");
	
	if (onWeight != NULL) { free(onWeight); }
	if (offWeight != NULL) { free(offWeight); }
	
	
}

-(void)setDefaults; {
	
	onTime = nil; // represented as "na" until specific time asigned
	offTime = nil; 
	
	onWeight = NULL; // allocated when experiment asssigned
	offWeight = NULL; 	
	
	phaseName = @"<none>";
	phaseDayIndex = -1; 
	currentState = kWeighingOn; 
	comment = @"";
	
	// allocate the UUID that uniquely identifies the daily data file
	CFUUIDRef     myUUID;
	myUUID = CFUUIDCreate(kCFAllocatorDefault);
	UUID = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, myUUID));
	CFRelease(myUUID);
	
	
}

// ***************************************************************************************
// ***************************************************************************************
// setters and getters 
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------


-(BarExperiment *)theExperiment { return theExperiment; }
-(void)setTheExperiment:(BarExperiment *)newExpt {
		
	theExperiment = newExpt;
	
	if (newExpt != nil) {
				
		// now that we have an experiment, 
		// we know how many subjects & items we have
		// so we can allocate the weight arrays
		
		[self initWeights];
		
	} 
	
}




-(NSInteger)currentState { return currentState; }
-(void)setCurrentState:(NSInteger)newState { currentState = newState;}

-(NSString *) phaseName; {return phaseName; }
-(void)setPhaseName:(NSString *)pName; { phaseName = [pName copy]; }

 

- (NSUInteger) exptDayIndex; {
     
	 // 0 - indexed -- position of self in [theExperiment dataDays] array
	 
	 NSUInteger day = [theExperiment dayIndexOfDailyData:self];
	 
	 if (NSNotFound == day) { return [theExperiment numberOfDays]; }
	 
	 return day;
 }


-(NSInteger)phaseDayIndex; { return phaseDayIndex; }
-(void)setPhaseDayIndex:(NSInteger)pdi; { phaseDayIndex = pdi; }

-(NSString *)comment; {return comment; }
-(void)setComment:(NSString *)c; { comment = [c copy]; }
 
 -(NSString *)UUID; { return UUID; }

-(NSDate *)onTime; { return onTime; }
-(void)setOnTime:(NSDate *)date; { onTime = date; }

-(NSDate *)offTime; { return offTime; }
-(void)setOffTime:(NSDate *)date; { offTime = date; }

-(NSDate *)modificationDate; { return modificationDate; }
-(void)setModificationDate:(NSDate *)date; { modificationDate = date; }

// ***************************************************************************************
// ***************************************************************************************
// FILE  methods
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------


-(void)save; {
	
	
	// save the weights into the Documents/Bartender/DailyData directory
	// On weights are stored in a file called "[ExptCode].onweights"
	// Off weights are stored in a file called "[ExptCode] year-month-day.weights", in which the date is the save date
	// i.e. if bottles in Expt TH were weighed on June 4, 2010 and weighed off June  5, 2010, 
	// then the weights are stored in the file "Documents/Bartender/DailyData/TH 2010-6-5.weights"
	// note that the format of both onweights and weights files are identical XML plists,
	// just that off weights in the .onweights file are set to NaN
	
	// NSLog(@"DailyData: save");
		
	if (currentState == kWeighingOn) {
		[self saveOnWeights];
	}
	else if (currentState == kWeighingOff) {
		
		[self saveOffWeights];
	}
    else if (currentState == kUserEditing) {
        [self saveEdits];
    }
	
}



-(void)saveOnWeights; {
	
	// construct a complete path to the file to store the on weights:
	// e.g. "~/Bartender/DailyData/[ExptCode]/[ExptCode].onweights"
	
	// NSLog(@"DailyData:	saveOnWeights");
	
	// set the time of weighing on to right now
	onTime = [NSDate date];
    modificationDate = [NSDate date];

	
	NSString *filename =  [[theExperiment code] stringByAppendingPathExtension:@"onweights"];
	NSString *dailyDataFilePath = [[theExperiment getExptDailyDataDirectoryPath] stringByAppendingPathComponent:filename];
	
	[self saveToPath:dailyDataFilePath];
 
 NSString *backup_filename =  [[[theExperiment code] stringByAppendingString:[self dateStringForFile:onTime]] stringByAppendingPathExtension:@"onweights.BAK"];
	NSString *backup_dailyDataFilePath = [[theExperiment getExptDailyDataDirectoryPath] stringByAppendingPathComponent:backup_filename];
 
 [self saveToPath:backup_dailyDataFilePath];   
	
	// tell the expeiment that new on weights have been recorded, so we're waiting for the off weights

	[theExperiment updateWithOnWeights];


}

-(void)backupOnWeights; {
	
	// remove old ".onweights.BAK"
	// rename on ".onweights" file as ".onweights.BAK"
	
	NSString *filename =  [[theExperiment code] stringByAppendingPathExtension:@"onweights"];
	NSString *dailyDataFilePath = [[theExperiment getExptDailyDataDirectoryPath] stringByAppendingPathComponent:filename];

	NSString *backupfilename =  [filename stringByAppendingPathExtension:@"BAK"];
	NSString *backupFilePath = [[theExperiment getExptDailyDataDirectoryPath] stringByAppendingPathComponent:backupfilename];
	
	NSError *error = nil; 
	
	[[NSFileManager defaultManager] removeItemAtPath:backupFilePath error:&error];
	
	[[NSFileManager defaultManager] moveItemAtPath:dailyDataFilePath toPath:backupFilePath error:&error];
	
}
-(void)backupOffWeights; {
	
	// remove old ".weights.BAK"
	// rename on ".weights" file as ".weights.BAK"
	
	NSString *filename = [[[theExperiment code] stringByAppendingString:[self dateStringForFile:offTime]] stringByAppendingPathExtension:@"weights"];

	NSString *dailyDataFilePath = [[theExperiment getExptDailyDataDirectoryPath] stringByAppendingPathComponent:filename];
    
	NSString *backupfilename =  [filename stringByAppendingPathExtension:@"BAK"];
	NSString *backupFilePath = [[theExperiment getExptDailyDataDirectoryPath] stringByAppendingPathComponent:backupfilename];
	
	NSError *error = nil;
	
	[[NSFileManager defaultManager] removeItemAtPath:backupFilePath error:&error];
	
	[[NSFileManager defaultManager] moveItemAtPath:dailyDataFilePath toPath:backupFilePath error:&error];
	
}

-(void)saveOffWeights; {
	
	// construct a complete path to the file to store the completed on & off weights:
	// e.g. "~/Bartender/DailyData/[ExptCode]/[ExptCode][Y-M-D].weights"
	
	// NSLog(@"DailyData: saveOffWeights");
	
	
	// set the time of weighing off to right now
	offTime = [NSDate date];
	
	NSString *filename = [[[theExperiment code] stringByAppendingString:[self dateStringForFile:offTime]] stringByAppendingPathExtension:@"weights"];
	NSString *dailyDataFilePath = [[theExperiment getExptDailyDataDirectoryPath] stringByAppendingPathComponent:filename];
	
	[self saveToPath:dailyDataFilePath];
	
	[self backupOnWeights];

	
	// tell the experiment that new OFF weights are saved, so it's daily data will need updating
	// no longer waiting to weigh bottles off
	// update the experiment with the name of the last saved daily data
	// and with the current phase & phase day...
	[theExperiment updateWithOffWeightsAtPath:dailyDataFilePath andPhaseName:phaseName andPhaseDay:phaseDayIndex];
	
}

-(void)saveEdits; {
	
	// construct a complete path to the file to store the completed on & off weights:
	// e.g. "~/Bartender/DailyData/[ExptCode]/[ExptCode][Y-M-D].weights"
	
	// NSLog(@"DailyData: saveEdits");
	
    [self backupOffWeights];
    
	
	// set the time of weighing off to right now
	modificationDate = [NSDate date];
	
	NSString *filename = [[[theExperiment code] stringByAppendingString:[self dateStringForFile:offTime]] stringByAppendingPathExtension:@"weights"];
	NSString *dailyDataFilePath = [[theExperiment getExptDailyDataDirectoryPath] stringByAppendingPathComponent:filename];
	
	[self saveToPath:dailyDataFilePath];
	
   	
}



-(void)saveToPath:(NSString *)filePath; {
	
	// got to write out a plist consiting of the ontime, offtime, and the array of onweights and offweights...
	// NSLog(@"DailyData: saveToPath: path is %@",filePath);
	
	NSMutableDictionary *rootDictionary = [[NSMutableDictionary alloc] init];
	[rootDictionary setObject:@"Bartender" forKey:@"creator"];
	[rootDictionary setObject:@"2.0" forKey:@"version"];
    
    // NSLog(@"DailyData: saveToPath: about to get time descriptions");
    
	[rootDictionary setObject:[self onTimeDescription] forKey:@"weighedOn"];
	[rootDictionary setObject:[self offTimeDescription] forKey:@"weighedOff"];
	[rootDictionary setObject:[self modificationDateDescription] forKey:@"modified"];
    
    // NSLog(@"DailyData: saveToPath: about to get phasename, phasedayindex,comment, and uuid");

	[rootDictionary setObject:phaseName forKey:@"phase"];
	[rootDictionary setObject:[NSNumber numberWithLong:phaseDayIndex] forKey:@"phaseDayIndex"];
	[rootDictionary setObject:comment forKey:@"comment"];
	[rootDictionary setObject:UUID forKey:@"UUID"];
	
    // NSLog(@"DailyData: saveToPath: about to make subjects dictionary array");

	[rootDictionary setObject:[self makeSubjectsDictionaryArray] forKey:@"SubjectsArray"];
	
	NSString *error;
    
    // NSLog(@"DailyData: saveToPath: about to serialize root dictionary");

	id xmlData = [NSPropertyListSerialization dataFromPropertyList:(id)rootDictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
	
	if(xmlData) {
		// NSLog(@"DailyData: No error creating Weights XML data.");
		
		[xmlData writeToFile:filePath atomically:YES];
		
	}
	else {
		// NSLog(@"DailyData: Error creating Weights XML data: %@",error);
	}
	
}

-(NSMutableArray *)makeSubjectsDictionaryArray; {
	// make an array of subject dictionaries
	// e.g., make a dictionary for each subject, add that to an array
	
	NSMutableArray *subjects = [[NSMutableArray alloc] init];
	
	NSUInteger ratIndex;
	
	
	for (ratIndex =0; ratIndex < [theExperiment numberOfSubjects]; ratIndex++) {
		
		[subjects addObject:[self dictionaryForSubjectIndex:ratIndex]];
	}
	
	return subjects;
	
}

-(NSMutableDictionary *)dictionaryForSubjectIndex:(NSUInteger)ratIndex; {
	
	double itemOn, itemOff, itemDelta;
	NSUInteger itemIndex;
	
	NSMutableDictionary *subjectDictionary = [[NSMutableDictionary alloc] init];
	
	
	[subjectDictionary setObject:[theExperiment nameOfSubjectAtIndex:ratIndex] forKey:@"name"];
	
	for (itemIndex=0;itemIndex<[theExperiment numberOfItems ]; itemIndex++) {
		
		if ([self getWeightsForRat:ratIndex 
						   andItem:itemIndex
						  onWeight:&itemOn
						 offWeight:&itemOff
					   deltaWeight:&itemDelta]) {
			
			
			NSString *itemName = [[theExperiment itemAtIndex:itemIndex] name];
			[subjectDictionary setObject:[NSNumber numberWithDouble:itemOn] forKey:[itemName stringByAppendingString:@" On"]];
			[subjectDictionary setObject:[NSNumber numberWithDouble:itemOff] forKey:[itemName stringByAppendingString:@" Off"]];
			
		}
		
	} // next item
	
	return subjectDictionary;
	
}

-(void)unpackSubjectDictionary:(NSDictionary *)subjectDictionary; {
	
	double itemOn, itemOff;
	NSUInteger itemIndex, ratIndex;
	
	// should be able to extract "name" then parse to get subject index
	// then for each item in the experiment, try to get values at key: "itemName On" and "itemName Off"
	// then set the weights for this item for this rat 
	
	NSString *subjectName = [subjectDictionary objectForKey:@"name"];
	if (nil == subjectName) { return; }
	
	ratIndex = [theExperiment subjectIndexFromLabel:subjectName];
    
    if (NSNotFound == ratIndex ) {
         // invalid rat number
         return;
    }
	
	for (itemIndex=0;itemIndex<[theExperiment numberOfItems ]; itemIndex++) {
		
		NSString *itemName = [[theExperiment itemAtIndex:itemIndex] name];
		NSString *itemOnKey = [itemName stringByAppendingString:@" On"];
		NSString *itemOffKey = [itemName stringByAppendingString:@" Off"];
		NSNumber *onNumber = [subjectDictionary objectForKey:itemOnKey];
		NSNumber *offNumber = [subjectDictionary objectForKey:itemOffKey];
		
		itemOn = MISSINGWGT;
		itemOff = MISSINGWGT;
		if (nil != onNumber) { itemOn = [onNumber doubleValue];}
		if (nil != offNumber) { itemOff = [offNumber doubleValue];}
		
		[self setWeightsForRat:ratIndex andItem:itemIndex onWeight:itemOn offWeight:itemOff];		
		
	} // next item
	
}

-(NSString *)dateStringForFile:(NSDate *)myDate; {
	
	// " yyyy-MM-DD HH:mm" -- make sure numbers < 10 are preceded by zero
	// notice leading space, to make file name look pretty
	
	NSString *dateString, *hourString;
	
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *mdyComponents = [gregorian components:(NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear ) fromDate:myDate];
	NSInteger day = [mdyComponents day];
	NSInteger month = [mdyComponents month];
	NSInteger year = [mdyComponents year];
	
	NSInteger hour = [mdyComponents hour];
	NSInteger minute = [mdyComponents minute];
	
	if (hour < 10 && minute < 10)		{ hourString = [NSString stringWithFormat:@"0%ld0%ld",hour,minute]; }
	else if (hour < 10 && minute >= 10) { hourString = [NSString stringWithFormat:@"0%ld%ld",hour,minute]; }
	else if (hour >=10 && minute < 10)  { hourString = [NSString stringWithFormat:@"%ld0%ld",hour,minute]; }
	else if (hour >= 10 && minute >=10) { hourString = [NSString stringWithFormat:@"%ld%ld",hour,minute]; }
	
	if (month < 10 && day < 10)			{ dateString = [NSString stringWithFormat:@" %ld-0%ld-0%ld %@", year, month, day, hourString];}
	else if (month < 10 && day >= 10)	{ dateString = [NSString stringWithFormat:@" %ld-0%ld-%ld %@", year, month, day, hourString];}
	else if (month >= 10 && day < 10)	{ dateString = [NSString stringWithFormat:@" %ld-%ld-0%ld %@", year, month, day, hourString];}
	else if (month >= 10 && day >= 10)	{ dateString = [NSString stringWithFormat:@" %ld-%ld-%ld %@", year, month, day, hourString];}
	
	return dateString;
	
}




-(BOOL)readOnWeights; {
	
	
	// NSLog(@"DailyData: readOnWeights");
	
	NSString *filename =  [[theExperiment code] stringByAppendingPathExtension:@"onweights"];
	NSString *dailyDataFilePath = [[theExperiment getExptDailyDataDirectoryPath] stringByAppendingPathComponent:filename];
	
	// NOTE: make sure that onweights file exists; if it doesn't return NO
	
	[self readFromPath:dailyDataFilePath];
	
	return YES; 
	
}

-(void)readFromPath:(NSString *)filePath; {
	
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	
	// NSLog(@"DailyData: readFromPath");
	
	// load the data in xml format from the file
	NSData *xmlData = [[NSFileManager defaultManager] contentsAtPath:filePath];
	
	// NSLog(@"DailyData: readFromPath loaded xmlData");
	
	
	// unpack the xmlData into the rootDictionary
	NSDictionary *rootDictionary = (NSDictionary *)[NSPropertyListSerialization
													propertyListFromData:xmlData
													mutabilityOption:NSPropertyListMutableContainersAndLeaves
													format:&format
													errorDescription:&errorDesc];
	if (!rootDictionary) {
		// NSLog(@"DailyData: Error reading expt file xml: %@, format: %ld", errorDesc, format);
	}
	
	// NSLog(@"DailyData: DailyData readFromPath read rootdictionary");
	
	
	if ([rootDictionary objectForKey:@"phase"]) { phaseName = [rootDictionary objectForKey:@"phase"]; }
	NSNumber *phaseDayNumber = [rootDictionary objectForKey:@"phaseDayIndex"];
	if (phaseDayNumber ) { phaseDayIndex = [phaseDayNumber intValue]; }
	
	if ([rootDictionary objectForKey:@"comment"]) { comment = [rootDictionary objectForKey:@"comment"]; }
    if ([rootDictionary objectForKey:@"UUID"]) { UUID = [rootDictionary objectForKey:@"UUID"]; }

	
	// get the on and off date-time strings
	// parse the time strings
	// if timeString = @"na" or nil, then set our NSDate to nil
	
	onTime = nil;
	NSString *onTimeString = [rootDictionary objectForKey:@"weighedOn"];
	[self setOnTime:[self dateFromTimeString:onTimeString]];
		

	offTime = nil;
	NSString *offTimeString = [rootDictionary objectForKey:@"weighedOff"];
	[self setOffTime:[self dateFromTimeString:offTimeString]];
    
	modificationDate = nil;
    NSString *modificationDateString = [rootDictionary objectForKey:@"modified"];
	if (nil != modificationDateString) { [self setModificationDate:[self dateFromTimeString:modificationDateString]]; }
    
    // NSLog(@"DailyData: DailyData readFromPath about to unpackSubjectDictionaries ");

	
	// subjects is an array of dictionarys that should be unpacked
	NSArray *subjects =	[rootDictionary objectForKey:@"SubjectsArray"];
	
	for (NSDictionary *subjectDictionary in subjects) {
		
		[self unpackSubjectDictionary:subjectDictionary];
	}
	
}

// ***************************************************************************************
// ***************************************************************************************
// Preference related methods...
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------

-(BOOL) getPreferenceForRat:(NSUInteger)ratIndex preference:(double *)preference total:(double *)total; {
	
	// validate the experiment and subject index
	if (theExperiment == nil)  { return NO; } 
	if (ratIndex >= [theExperiment numberOfSubjects])  { return NO; } 
	
	// does the experiment even use preferences?
	if (![theExperiment hasPreference])  { return NO; } 
	
	NSUInteger sacItem, waterItem;
	double sacOn, sacOff, sacIntake, waterOn, waterOff, waterIntake;
	
	[theExperiment getIndexOfPreferenceItem:(&sacItem) overItem:(&waterItem)];
	
	if (![self getWeightsForRat:ratIndex andItem:sacItem	onWeight:&sacOn		offWeight:&sacOff		deltaWeight:&sacIntake])	 { return NO; }
	if (![self getWeightsForRat:ratIndex andItem:waterItem	onWeight:&waterOn	offWeight:&waterOff		deltaWeight:&waterIntake]) { return NO; }
	
	// validate the intakes before trying to calculate a preference...
    
    // don't report totals if some data is missing
	if (sacIntake == MISSINGWGT || waterIntake == MISSINGWGT)  { return NO; } 
    
    // don't report total intake of 0...
	if (sacIntake + waterIntake == 0)  { return NO; } 
    
    // allow negative intakes
    // if (sacIntake  < 0 || waterIntake < 0 ) { return NO; } 

    // avoid divide by zero
	if (![theExperiment usePreferenceOverTotal] && waterIntake == 0) { return NO; } 
	
    // calculate total and preference
    (*total) = sacIntake + waterIntake;

	if ([theExperiment usePreferenceOverTotal]) {
		(*preference) = sacIntake / (sacIntake + waterIntake);
	}
	else {
		(*preference) = sacIntake / waterIntake;
	}
	
	return YES;
	
}


// ***************************************************************************************
// ***************************************************************************************
// Weight related methods.... 
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------

-(void)setToOnWeights { [self setCurrentState: kWeighingOn]; }


-(void)setToOffWeights { [self setCurrentState: kWeighingOff]; }


#define WGT(x,y,z) ((x)[(unsigned long)(y*[theExperiment numberOfItems]+z)])
// WGT(<double *onWeight or double *offWeight>,<int ratIndex>,<int itemIndex>)
// index into the onWeight or offWeight arrays

-(void) initWeights {
	
	NSUInteger r,i,numRats,numItems;
	onWeight = offWeight = NULL;
	
	if (theExperiment == nil) { return; }
	
	numRats = [theExperiment numberOfSubjects];
	numItems = [theExperiment numberOfItems];
	
	onWeight = (double *)malloc(sizeof(double) * (size_t)numRats * (size_t)numItems);
	offWeight = (double *)malloc(sizeof(double) * (size_t)numRats * (size_t)numItems);
	
	if (onWeight != NULL && offWeight != NULL) {
		
		for (r=0;r < numRats; r++) {
			for (i=0;i<numItems;i++) {
				WGT(onWeight,r,i) = MISSINGWGT; 
				WGT(offWeight,r,i) = MISSINGWGT; 
			}
			
		}
	}
}

-(BOOL) validateRatIndex:(NSUInteger)ratIndex andItemIndex:(NSUInteger)itemIndex {
	
	// make sure we have an experiment, and that the rat and item indices are within range...
	if (theExperiment == nil) { return NO; }
	if (onWeight == NULL || offWeight == NULL)  { return NO; }
	if (ratIndex >=  [theExperiment numberOfSubjects] || itemIndex >=  [theExperiment numberOfItems])  { return NO; }
	
	return YES;
	
}


-(BOOL) getWeightsForRat:(NSUInteger)ratIndex andItem:(NSUInteger)itemIndex onWeight:(double *)onwgt offWeight:(double *)offwgt deltaWeight:(double *)deltawgt {
		
	// set default values...
	(*onwgt) = MISSINGWGT;
	(*offwgt) = MISSINGWGT;
	(*deltawgt) = MISSINGWGT;
	
	// make sure we have an experiment, and that the rat and item indices are within range...
	if (![self validateRatIndex:ratIndex andItemIndex:itemIndex])  { return NO; }
	
	
	// get the on and off weights out of the big arrays
	(*onwgt) = WGT(onWeight,ratIndex,itemIndex);
	(*offwgt) = WGT(offWeight,ratIndex,itemIndex);
	
	// if we have valid values for weights, calculate the delta...
	if ( [[theExperiment itemAtIndex:itemIndex] onOffType]) {
		if ( (*onwgt) != MISSINGWGT && (*offwgt) != MISSINGWGT) { (*deltawgt) = (*onwgt) - (*offwgt); }
	}
	else {
		// not an on/off weight, so no delta -- treat delta just as onwght...
		if ( (*onwgt) != MISSINGWGT) { (*deltawgt) = (*onwgt); }
		
	}
		
	return YES;
	
}


-(BOOL) setWeightsForRat:(NSUInteger)ratIndex andItem:(NSUInteger)itemIndex onWeight:(double)onwgt offWeight:(double)offwgt {
	
	// make sure we have an experiment, and that the rat and item indices are within range...
	if (![self validateRatIndex:ratIndex andItemIndex:itemIndex])  { return NO; }
	
	[self setOnWeightForRat:ratIndex andItem:itemIndex weight:onwgt];
	[self setOffWeightForRat:ratIndex andItem:itemIndex weight:offwgt];
	
	return YES;
}


-(BOOL) setOnWeightForRat:(NSUInteger)ratIndex andItem:(NSUInteger)itemIndex weight:(double)wgt {
		
	// make sure we have an experiment, and that the rat and item indices are within range...
	
	if (![self validateRatIndex:ratIndex andItemIndex:itemIndex])  { return NO; }
	
	WGT(onWeight,ratIndex,itemIndex) = wgt;
	
	return YES;
}


-(BOOL) setOffWeightForRat:(NSUInteger)ratIndex andItem:(NSUInteger)itemIndex weight:(double)wgt {
	
    // make sure we have an experiment, and that the rat and item indices are within range...
	if (![self validateRatIndex:ratIndex andItemIndex:itemIndex])  { return NO; }
	
	WGT(offWeight,ratIndex,itemIndex) = wgt;
	
	return YES;
	
}


-(void) clearOnWeights {
	
	// set all the on weights to the MISSINGWGT value
	// note that clearing the on weights also clears the off weights
	
	NSUInteger r,i;
	if (theExperiment == nil || onWeight == NULL || offWeight == NULL)  { return; }
	
	for (r = 0;r < [theExperiment numberOfSubjects];r++) {
		for (i=0;i< [theExperiment numberOfItems];i++) {
			WGT(onWeight,r,i) = MISSINGWGT;
			WGT(offWeight,r,i) = MISSINGWGT;
		}
	}	
}


-(void) clearOffWeights {
	
	// set all the off weights to the MISSINGWGT value
	
	NSUInteger r,i;
	if (theExperiment == nil || offWeight == NULL) { return; }
	
	for(r = 0;r < [theExperiment numberOfSubjects];r++) {
		for (i=0;i< [theExperiment numberOfItems];i++) {
			WGT(offWeight,r,i) = MISSINGWGT;
		}
	}	
	
}


-(NSUInteger) numberOfUnweighedOnItems {
	
	// count the number of items that have missingwgt for the on weights...
	// returns 0 if there is some problem...
	
	if (theExperiment == nil || onWeight == NULL || offWeight == NULL)  { return 0; }
	
	NSUInteger unweighed = 0;
	NSUInteger r,i;
	
	for(r = 0;r < [theExperiment numberOfSubjects];r++) {
		for (i=0;i<[theExperiment numberOfItems];i++) {
			if (WGT(onWeight,r,i) == MISSINGWGT) unweighed++;
		}
	}	
	return(unweighed);
	
}


-(NSUInteger) numberOfUnweighedOffItems {
	
	// count the number of items that have missingwgt for the off weights...
	// returns 0 if there is some problem...
	
	if (theExperiment == nil || onWeight == NULL || offWeight == NULL) { return 0; }
	
	NSUInteger unweighed = 0;
	NSUInteger r,i;
	
	for(r = 0;r < [theExperiment numberOfSubjects];r++) {
		for (i=0;i<[theExperiment numberOfItems];i++) {
			if (WGT(offWeight,r,i) == MISSINGWGT) unweighed++;
		}
	}	
	
	return(unweighed);
}	


-(NSUInteger) numberOfUnweighedItems {
	// return unweigh OnItems or OffItems, depending on current state
	
	switch (currentState) {
			
			
		case kWeighingOn:
			return [self numberOfUnweighedOnItems];
			break;
			
		case kWeighingOff:
			return [self numberOfUnweighedOffItems];
			break;
			
		case kDisplayOnly:
			return 0;
			break;
	}
	
	return 0;
	
	
}


-(void)	carryOverOffWeightsToOnWeights {}
//NOTE this will require referencing the last daily data, on disk?


// ***************************************************************************************
// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
/// Time Methods
///--------------------------------------------------------------------------------------------------

/** return weighed on time as a string
 
 @return NSString with the weighed on time in (weekday yyyy-MM-DD HH:MM) format for display
 
 */

-(NSString *)onTimeString; {
	
	if (onTime) {
		
//		NSDateFormatter *dateFormatter =
//			[[[NSDateFormatter alloc] init] autorelease];
//			[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//			[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:kDateWithDayFormatString];
		
		return [dateFormatter stringFromDate:onTime];
	}
	return @"pending";
	
}

/** return weighed off time as a string
 
 @return NSString with the weighed off time in (weekday yyyy-MM-DD HH:MM) format for display
 
 */

-(NSString *)offTimeString; {
	
	
	if (offTime) {
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:kDateWithDayFormatString];
		
		return [dateFormatter stringFromDate:offTime];
		
		
	}
	return @"pending";
	
}

/** return weighed ON time as a date description for storage
 
 @return NSString with the weighed on time in (yyyy-MM-DD HH:mm:SS ±Z) format, or "na" if not defined yet
 
 */

-(NSString *)onTimeDescription; {
	
	
	if (onTime) {
		return [onTime description];		
	}
	return @"na";
	
}
-(NSString *)modificationDateDescription; {
	
	
	if (modificationDate) {
		return [modificationDate description];
	}
	return @"na";
	
}

/** return weighed OFF time as a date description for storage
 
 @return NSString with the weighed off time in (yyyy-MM-DD HH:mm:SS ±Z) format, or "na" if not defined yet
 
 */

-(NSString *)offTimeDescription; {
	
	
	if (offTime) {
			return [offTime description];		
	}
	return @"na";
	
}


/** takes a international format time string, converts it to an NSDate
 if string is nil or "na", then NSDate is set to nil
 
 @param NSString with the time in international string representation format (yyyy-MM-DD HH:MM:SS ±HHMM)
 
 */

-(NSDate *)dateFromTimeString:(NSString *)timeString; {
	
	if (nil == timeString) { return nil; }
	if ([timeString isEqualToString:@"na"])  { return nil; }
	
	return [NSDate dateWithString:timeString];
	
	
}


-(NSString *)shortTimeStringFromDate:(NSDate *)date; {
    
    if (date) {
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:kDateWithDayFormatString];
		
		return [dateFormatter stringFromDate:date];
		
		
	}
	return @"pending";

}

// ***************************************************************************************
// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
/// Text Methods
///--------------------------------------------------------------------------------------------------


-(NSString *) getTextForItem:(NSString *)itemName atTerm:(NSUInteger)itemTerm forRat:(NSUInteger)ratIndex {
	
	
	double onwgt,offwgt, deltawgt;
	NSUInteger itemIndex = 0;
	
	
	if (itemTerm == kWeightUnknownTerm) {
		return kNoDataCellText;
	}
	
	// NOTE convert itemName into an itemIndex
	
	itemIndex = [theExperiment itemIndexFromName:itemName];	
	
	
	//validate the experiment and the rat and item indices
	if (![self validateRatIndex:ratIndex andItemIndex:itemIndex]) {
		return kNoDataCellText;
	}
	
	if (![self getWeightsForRat:ratIndex andItem:itemIndex onWeight:&onwgt offWeight:&offwgt deltaWeight:&deltawgt]) {	
		return kNoDataCellText;
	}
	switch (itemTerm) {
			
		case kWeightOn:
			return [self weightAsNSString:onwgt];
			break;
			
		case kWeightOff:
			return [self weightAsNSString:offwgt];
			break;
			
		case kWeightDelta:
			return [self weightAsNSString:deltawgt];
			break;
	}
	
	// fall through to default...
	
	return kNoDataCellText;
	
}

-(NSString *) weightAsNSString:(double)wgt {
	
	if (wgt == MISSINGWGT) { return kNoDataCellText; }
	else { return [NSString stringWithFormat:@"%.2lf", wgt]; }
	
}

-(NSString *) getPreferenceScoreTextForRat:(NSUInteger)ratIndex {
	
	double preference,total;
	
	if (![self getPreferenceForRat:ratIndex preference:&preference total:&total]) { return kNoDataCellText; }
	
	return [NSString stringWithFormat:@"%.2lf",preference];
	
}

-(NSString *) getTotalTextForRat:(NSUInteger)ratIndex {
	
	double preference,total;
	
	if (![self getPreferenceForRat:ratIndex preference:&preference total:&total]) { return kNoDataCellText; }
	
	return [NSString stringWithFormat:@"%.2lf",total];
	
}


// ***************************************************************************************
// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
/// Group Average Methods
///--------------------------------------------------------------------------------------------------

// get array of column labels by getting [dailyData itemLabels] (need to prepend "Groups" column heading)
// get array of rows by getting [dailyData groupMeans]; each row is an array of BCMeanValue objects for each item
// prepend name of group to each row
// get text for each mean by calling [BCMeanValue mean2Text] 

-(NSArray *)itemLabels; {
// an array of NSStrings containing labels for the daily data labels
// e.g. "Saccharin", "Water", "Total", "Pref",
    
    NSMutableArray *labels = [[NSMutableArray alloc] init];
    
    for (BarItem *theItem in [theExperiment items]) {
        
        [labels addObject:[theItem name]];
    }
    
    if ([theExperiment hasPreference]) {
        
        [labels addObject:@"Total"];
        [labels addObject:@"Pref"];
        
    }
        
    return labels;

}

-(NSArray *)groupLabels; {
// an array of NSStrings containing names of the expt groups
// e.g. "NN", "NL", "LN", "LL"
    
    NSMutableArray *labels = [[NSMutableArray alloc] init];
    
    for (BarGroup *theGroup in [theExperiment groups]) {
        
        if (! [[theGroup code] isEqualToString:kNoDataCellText]) { [labels addObject:[theGroup code]]; }
    }
    
    return labels;
    
}

-(NSArray *)itemMeansForGroupIndex:(NSUInteger)groupIndex; {
    
// an array of BCMeanValue objects, one object for each item in the daily data for the given group

    NSMutableArray *means = [[NSMutableArray alloc] init];;
    
   NSUInteger itemIndex, subjectIndex;
    double onwgt, offwgt, deltawgt;
    
    for (itemIndex=0; itemIndex< [theExperiment numberOfItems]; itemIndex++) {
        
        
        BCMeanValue *theMean = [[BCMeanValue alloc] init];
        [theMean zeroMean];
        
        for (subjectIndex=0;subjectIndex<[theExperiment numberOfSubjects]; subjectIndex++) {
        
            if (groupIndex == [theExperiment indexOfGroupOfSubjectAtIndex:subjectIndex]) {
                
                [self getWeightsForRat:subjectIndex andItem:itemIndex onWeight:&onwgt offWeight:&offwgt deltaWeight:&deltawgt ];
                    
                if ( deltawgt != MISSINGWGT) { [theMean sumMean: deltawgt]; }
            }
            
        }
        [theMean divideMean];

        for (subjectIndex=0;subjectIndex<[theExperiment numberOfSubjects]; subjectIndex++) {
            
            if (groupIndex == [theExperiment indexOfGroupOfSubjectAtIndex:subjectIndex]) {
                
                [self getWeightsForRat:subjectIndex andItem:itemIndex onWeight:&onwgt offWeight:&offwgt deltaWeight:&deltawgt ];
                
                if ( deltawgt != MISSINGWGT) { [theMean sumErr: deltawgt]; }
            }
            
        }
        [theMean divideErr];

        [means addObject:theMean];
        
    } // all items
    
    // now need to get means for preference and total
    
    if ([theExperiment hasPreference]) {
                
        BCMeanValue *thePreferenceMean = [[BCMeanValue alloc] init];
        BCMeanValue *theTotalMean = [[BCMeanValue alloc] init];
        double total, preference;
        
        for (subjectIndex=0;subjectIndex<[theExperiment numberOfSubjects]; subjectIndex++) {
            
            if (groupIndex == [theExperiment indexOfGroupOfSubjectAtIndex:subjectIndex]) {
                
                if ( [self getPreferenceForRat:subjectIndex preference:&preference total:&total]) {
                
                    [theTotalMean sumMean: total]; 
                    [thePreferenceMean sumMean: preference];

                }
            }
            
        }
        
        [theTotalMean divideMean];
        [thePreferenceMean divideMean];
        
        for (subjectIndex=0;subjectIndex<[theExperiment numberOfSubjects]; subjectIndex++) {
            
            if (groupIndex == [theExperiment indexOfGroupOfSubjectAtIndex:subjectIndex]) {
                
                if ( [self getPreferenceForRat:subjectIndex preference:&preference total:&total]) {
                    [theTotalMean sumErr: total];
                    [thePreferenceMean sumErr: preference]; 
                }
            }
            
        }
        [theTotalMean divideErr];
        [thePreferenceMean divideErr];
        
        [means addObject:theTotalMean];
        [means addObject:thePreferenceMean];
            
    }    // preference & total

 
    return means;
}

-(NSArray *)groupMeans; {
// an array of arrays; each object in the array is an array of group means
    
    NSMutableArray *groupMeans = [[NSMutableArray alloc] init];

    NSUInteger groupIndex;
    // skip the unassigned group, so start at groupIndex = 1...?
    for (groupIndex=0; groupIndex< [theExperiment numberOfGroups]; groupIndex++) {
        
        BarGroup *theGroup = [theExperiment groupAtIndex:groupIndex];
        
        if (! [[theGroup code] isEqualToString:kNoDataCellText]) {
            [groupMeans addObject:[self itemMeansForGroupIndex:groupIndex]];
        }
        
    }

    return groupMeans;
}
@end
