//
//  BarExperiment.m
//  Bartender
//
//  Created by Tom Houpt on 09/6/14.
//  Copyright Behavioral Cybernetics 2009 . All rights reserved.
//

#import "BarExperiment.h"

#import "BarUtilities.h"
#import "BarItem.h"
#import "BarGroup.h"
#import "BarDrug.h"
#import "BarSubject.h"
#import "BarPhase.h"
#import "DailyData.h"
#import "DailyDataDocument.h"
#import "BarSummaryData.h"
#import "BarDirectories.h"
#import "FirebaseSummary.h"
#import "Bartender_Constants.h"

@implementation BarExperiment

- (id)init; {
	// init is called if we are creating a new experiment

    
	self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		
	//	[self setDefaults];
		
		// init is called if we are creating a new experiment
		[self setNewExptDefaults];
    
    }
    return self;
	
}
	
-(id)initFromPath:(NSString *)filePath {
	
	NSLog (@"entered BarExperiment initFromPath");
	self = [super init];
    if (self) {
		
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		
//		[self setDefaults];
		
		[self loadFromPath:filePath];

		
    }
    return self;
	
	
}

-(void)setDefaults {
	
	// called from init
	
	[super setDefaults];
	
	NSLog(@"BarExperiment setDefaults");
	
	
	[self setName:@"Untitled"];
	[self setCode:@"??"];
	[self setInvestigators:@"Your name here"];
	[self setProtocol:@"Review cmte protocol #"];
	[self setProjectCode:@"CFP"];
    [self setProjectName:@"Conditioned Flavor Preferences"];
    [self setWiki:@"Wiki page here"];

	
	[self setDescription:@"Describe experiment here"];
//	[self setBackupSummaryPath:	[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0]];
	
	
	startTime = 0;
	endTime = 0;
	
	currentPhaseName = @"<none>";
	lastDailyDataPath = @"<none>";
	[self setWaitingForOff:NO]; // sets the status string to "OFF"
	
	
	subjects = [[NSMutableArray alloc] init];
	items = [[NSMutableArray alloc] init];
	groups = [[NSMutableArray alloc] init];
	phases = [[NSMutableArray alloc] init];
	drugs = [[NSMutableArray alloc] init];
    
	// do not allocate dataDays until we actually start loading them from disk
	// dataDays = [[NSMutableArray alloc] init];
	
	dailyDataNeedsUpdating = YES;
		
	
}

-(void)setNewExptDefaults {
	
	// NOTE: load new experiment from the default template?
	
	//	if ([bartender defaultTemplatePath]) {
	//		
	//		[self loadFromTemplatePath:[bartender defaultTemplatePath]];
	//		
	//		return;
	//		
	//	}
	//	
	// no default, so use my defaults...
	// a couple of default items
	BarItem *item;
	
	item = [[BarItem alloc] initWithName:@"Saccharin" andCode:@"S" andDescription:@"0.125% saccharin solution" ];
	[items addObject:item];
	
	item = [[BarItem alloc] initWithName:@"Water" andCode:@"W" andDescription:@"distilled water" ];
	[items addObject:item];
	
	[self setPreferenceIndexofItem:0 overItem:1];
	[self setHasPreference:YES];
	[self setUsePreferenceOverTotal:YES];
	
	// a default group
	BarGroup *group;
	
	group = [[BarGroup alloc] initWithName:@"Unassigned" andCode:kNoDataCellText andDescription:@"unassigned subjects" ];
	[groups addObject:group];
	
	// add a bunch of subjects
	[self setNumberOfSubjects:24];
	
	// a default phase
	BarPhase *phase;
	
	phase = [[BarPhase alloc] initWithName:@"<none>" andCode:kNoDataCellText andDescription:@"undefined phase" ];
	[phases addObject:phase];
	
	
}



// ***************************************************************************************
// ***************************************************************************************
// setters and getters
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------

-(void)setInvestigators:(NSString *)newInvestigators {

	// [investigators autorelease];
	investigators = [newInvestigators copy];
}

-(void)setProtocol:(NSString *)newProtocol  {
	
	// [protocol autorelease];
	protocol = [newProtocol copy];
}
-(void)setWiki:(NSString *)newWiki  {
    
    // [protocol autorelease];
    wiki = [newWiki copy];
}

-(void)setProjectCode:(NSString *)newCode {
	project_code = [newCode copy];
}
-(void)setProjectName:(NSString *)newName {
    project_name = [newName copy];
}

- (void) setTemplateFlag:(BOOL)flag; {templateFlag = flag; }

-(void)setStartTime:(unsigned long) s { startTime = s; }
-(void)setEndTime:(unsigned long) e {endTime = e; }

-(void)setWaitingForOff:(BOOL)wfo {
	
	waitingForOff = wfo; 
	if (waitingForOff) { status = @"ON"; }
	else { status = @"OFF"; }
}
-(void)setUseGroups:(BOOL) uG { useGroups = uG; }

// these setters only set the array ptr

-(void)setSubjects: (NSMutableArray *)nS { subjects = nS; }	
-(void)setItems: (NSMutableArray *)nI { items = nI; }
-(void)setGroups: (NSMutableArray *)nG { groups = nG; }
-(void)setPhases: (NSMutableArray *)nP {phases = nP; }
-(void)setDrugs: (NSMutableArray *)nD {drugs = nD; }

//-(void) setBackupSummaryPath:(NSString *)newPath;  {
//	if (nil != newPath) { backupSummaryPath = [newPath copy]; }
//	else { backupSummaryPath = nil; }
//}



-(NSString *)investigators	{ return investigators; }
-(NSString *)protocol		{ return protocol; }
-(NSString *)project_code		{ return project_code; }
-(NSString *)project_name       { return project_name; }
-(NSString *)wiki        { return wiki; }

- (NSString *) getSummaryFileName; {

	NSString *fileName = [NSString stringWithFormat:@"%@ Summary.txt",[self code]];
	
	return fileName;

}


- (BOOL) templateFlag; { return templateFlag; }

-(unsigned long)startTime	{ return startTime; }
-(unsigned long)endTime	{ return endTime; }


-(BOOL)waitingForOff {return waitingForOff; }

-(NSString *)status; {
	// status of bottles -- if "dailydata.onweights" file exists, then bottles have been weighed on
	// otherwise, bottles are OFF, and need to be weighed on
	
	if (waitingForOff) status = @"ON";
	else status = @"OFF";
	
	return status;

}
-(BOOL)useGroups { return useGroups; }


// - (NSString *) backupSummaryPath; { return backupSummaryPath; }



- (void)updateWithOnWeights; {
	
	// tell the expeiment that new on weights have been recorded, so we're waiting for the off weights
	[self setWaitingForOff:YES];
	[self save];	
	
}

- (void)updateWithOffWeightsAtPath:(NSString *)path andPhaseName:(NSString *)phaseName andPhaseDay:(NSInteger)day; {

	// tell the experiment that new OFF weights are saved, so it's daily data will need updating
	// no longer waiting to weigh bottles off
	// update the experiment with the name of the last saved daily data
	// and with the current phase & phase day...
	
	[self setWaitingForOff:NO];
	[self setLastDailyDataPath:path];
	[self setCurrentPhaseDay:day];
	[self setCurrentPhaseName:phaseName];	
	[self save];
	[self saveBackupSummary];

}


-(void) saveBackupSummary; {
	
	BarSummaryData *summary = [[BarSummaryData alloc] initWithExperiment:self ];
	
	[summary update];
 
     NSString *backupSummaryPath = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderLocalBackupDirectoryKey];
    
	
	NSString *backupFilePath = [backupSummaryPath stringByAppendingPathComponent:[self getSummaryFileName]];
	
	[summary writeToFileAtPath:backupFilePath];

    [summary writeToFirebase];

	
	
}

// **********************************************************************
// DailyData Methods -- 

-(NSString *) lastDailyDataPath; { return lastDailyDataPath; }

-(void) setLastDailyDataPath:(NSString *)path; {
	if (nil != path) { lastDailyDataPath = [path copy];}
	else { lastDailyDataPath = nil; }
}


- (NSUInteger)numberOfDays; {
	
	// count number of daily data files (*.weights)  are in the DailyData directory
	
	
	NSUInteger count = 0;
	
	NSString *path = [self getExptDailyDataDirectoryPath]; // set to our daily data directory
	
	[self countDailyDataFilesInPath:path counter:&count];
    
    NSLog(@"BarExperiment numberOfDays: %ld", count);
		
	return count;
}

- (DailyData *) dailyDataForDay:(NSUInteger)dayIndex; {
	
	// 1. load the daily data if it is not already in memory
	// 2. return the appropriate day
	
	[self loadDailyData];
	
    if (dayIndex > ([dataDays count]-1)) { return nil;}
    
	return [dataDays objectAtIndex:dayIndex];
	
}

-(NSUInteger) dayIndexOfDailyData:(DailyData *)dailyData; {
	
	
	// return NSNotFound if daily data not indexed yet (i.e.  weighed on, weighing off still pending)
	
	[self loadDailyData];
	
	
	for (DailyData *oneDay in dataDays) {
		
		if ( [[dailyData UUID] isEqualToString:[oneDay UUID]]) {
			
			return [dataDays indexOfObject:oneDay];
			
		}
		
	}
	
	 return NSNotFound;
	
}

-(void)loadDailyData; {

    dataDays = [[NSMutableArray alloc] init];
	
	// if (nil == dataDays || dailyDataNeedsUpdating) {
		
		NSString *path = [self getExptDailyDataDirectoryPath]; // set to our daily data directory
		
		[self readDailyDataFromPath:path];
		
		dailyDataNeedsUpdating = NO;
		
	// }
	
	
}

-(void) countDailyDataFilesInPath:(NSString *)path counter:(NSUInteger *)count; {
	
	// counts ".weights" files
	// does NOT count "*.onweights" file
	
	/*	
	 if filePath is a directory, then 
	 create a new SubjectGroupObject with this path, 
	 and set name from the filename end of the path
	 recurse! with new SubjectGroupObject as the parent
	 
	 if filePath is a file then
	 if filePath is an image file then
	 create a new SubjectObject with this path, 
	 and set name from the filename end of the path
	 add to parent SubjectGroupObject
	 return
	 
	 */
	BOOL dir;
	
    if (nil == path) { (*count) = 0; return; }
    
	[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&dir]; 
	
	if (dir) {
		
		NSUInteger i, n;
		
		NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
		
		n = [content count]; 
		
		for (i=0; i<n; i++) {
			
			NSString *subItemName = [content objectAtIndex:i];
			NSString *subPath = [path stringByAppendingPathComponent:subItemName];
			
			[self countDailyDataFilesInPath:subPath counter:count];
			
		}
		
	}
	else { // it's not a directory
		
		if ([self isDailyDataFile:path]) { // its a source/data file for our experiment ?
			// counts ".weights" files
			// does NOT count "*.onweights" file
	
			(*count) ++; 
		}
		
	}
	
}

-(void) readDailyDataFromPath:(NSString *)path {
	
	
	/*	
	 if filePath is a directory, then 
	 create a new SubjectGroupObject with this path, 
	 and set name from the filename end of the path
	 recurse! with new SubjectGroupObject as the parent
	 
	 if filePath is a file then
	 if filePath is an image file then
	 create a new SubjectObject with this path, 
	 and set name from the filename end of the path
	 add to parent SubjectGroupObject
	 return
	 
	 */
	BOOL dir;
	
    if (nil == path) { return; }
    
    
	[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&dir]; 
	
	if (dir) {
		
		NSUInteger i, n;
		
		NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        NSArray *sortedContent = [content sortedArrayUsingComparator:
                                  ^(id path1, id path2)
                                  {                               
                                      // compare 
                                      NSComparisonResult comp = [path1 compare:path2 options:NSCaseInsensitiveSearch];
                                      return comp;                                
                                  }];
		n = [content count]; 
		
		for (i=0; i<n; i++) {
			
			NSString *subItemName = [sortedContent objectAtIndex:i];
			NSString *subPath = [path stringByAppendingPathComponent:subItemName];
			
			[self readDailyDataFromPath:subPath];
			
		}
		
	}
	else { // it's not a directory
		
		if ([self isDailyDataFile:path]) { // its a source/data file for our experiment ?
			
			DailyData *oneDailyData = [[DailyData alloc] initFromPath:path withExperiment:self];
			
			
			[dataDays addObject:oneDailyData];
			
		}
		
	}
	
}

- (BOOL)isDailyDataFile:(NSString*)filePath {
	
	// looking for a filename of the format, e.g., "TQ 2012-7-9 1415.weights"
	// 1. check if path points to a file (and not a directory or package)
	// 2. check that it has the right extension (".weights")
	// 3. check that filename is prefixed with our expt code (e.g. "TQ ")
	
	BOOL itsAFile = NO;
	BOOL hasExtension = NO;
	BOOL hasPrefix = NO;
	BOOL isDataFile = NO;	

	// 1. check if path points to a file (and not a directory or package)
	
	
	NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
	if (fileAttribs)
	{
		// Check for packages.
		if ([NSFileTypeDirectory isEqualTo:[fileAttribs objectForKey:NSFileType]]) {
			
			if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath:filePath] == NO) {
				itsAFile = YES;	// If it is a file, it's OK to add.
			}
		}
		else {
			
			itsAFile = YES;	// It is a file, so it's OK to add.
		}
	}
	
	if (!itsAFile) return NO;
	
	// 2. check that it has the right extension (".weights") 
	
	NSString *extension = [filePath pathExtension];
	hasExtension = [extension isEqualToString:@"weights"];
	
	
	// 3. check that filename is prefixed with our expt code (e.g. "TQ ")
	
	NSString *fileName = [filePath lastPathComponent];
    hasPrefix =  [fileName hasPrefix:[self code]];
//	NSRange prefixRange = [fileName rangeOfString:[self code]];
//	if ( 0 == prefixRange.location && 2 == prefixRange.length) { hasPrefix = YES; }
	
	// if we have the right extension & prefix, then it's a datafile
	
	if (hasExtension && hasPrefix) isDataFile = YES;
	
	return isDataFile;
}

-(BOOL) onWeightsFileExists; {	
	
	NSString *filename =  [[self code] stringByAppendingPathExtension:@"onweights"];
	NSString *onWeightsPath = [[self getExptDailyDataDirectoryPath] stringByAppendingPathComponent:filename];
	
	return ([[NSFileManager defaultManager] fileExistsAtPath:onWeightsPath]);
			
}
			
			

-(NSString *) getExptDailyDataDirectoryPath; {
	
	// returns a string with the path to the directory for our current data
	// e.g. "~/Bartender/DailyData/[ExptCode]/"
	// creates the directories if it can't find them
	
	NSLog(@"BarExpt	getExptDailyDataDirectoryPath");
	
	NSError *fileManagerError;
	
	NSString *dailyDataDirectoryPath = GetDailyDataDirectoryPath();
	
	NSString *exptDailyDataDirectoryPath = [dailyDataDirectoryPath stringByAppendingPathComponent:[self code]];
	
	// need to make sure dailydata directory occurs
	
	NSFileManager *defaultFileManager = [ NSFileManager defaultManager];
	
	// check if the appropriate directories exist, create them if they don't exist
	[defaultFileManager 
	 createDirectoryAtPath:exptDailyDataDirectoryPath
	 withIntermediateDirectories:YES
	 attributes:nil
	 error:&fileManagerError]; //returns YES on success
	
	//NOTE: we should check for an ERROR here
	
	return exptDailyDataDirectoryPath;
	
	
}
-(void) dailyDataNeedsUpdating;	 {
	
	// called by DailyData to notify experiment that new daily data has been saved 
	
	dailyDataNeedsUpdating = YES;
}
// ***************************************************************************************
// ***************************************************************************************
// Subject methods
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------

-(NSMutableArray *) subjects { return subjects; }



-(void) setNumberOfSubjects:(NSUInteger)n {
	
	NSUInteger current_count = [subjects count];
	NSUInteger i;
	BarSubject *subject;

	if (current_count < n) {
		
		// add subjects to the end of the array until we have n subjects		
		for (i=current_count; i < n; i++) {
			
			subject = [[BarSubject alloc] initWithGroupIndex:0];
			[subjects addObject:subject];
		}
	}
	else if (current_count > n) {
		
		// NOTE: remove subjects from the end of the array
			
		NSRange aRange;
		aRange.location = n;
		aRange.length = current_count - n;
		[subjects removeObjectsInRange:aRange];
			
	}

}



-(NSUInteger) numberOfSubjects { 

	return [subjects count];

}



-(BarSubject *)subjectAtIndex:(NSUInteger)index { 
	
	return (BarSubject *)[subjects objectAtIndex:index];
}

-(NSUInteger)indexOfSubject:(BarSubject *)subject {
	
	return [subjects indexOfObject:subject];
	
}

-(NSUInteger) subjectIndexFromLabel:(NSString *)labelString {
	
	// given a label of format "[ExptAbbr][Subject Number][ItemCode]"
	// extract the number of the subject
	// -1 if outside the range of subject numbers
	

    NSArray *label_codes = [labelString parseAsBarTenderLabel];

    if (nil == label_codes) {
            return NSNotFound;
    }


    NSUInteger tag_number;
    NSUInteger rat;

    tag_number = [label_codes[kParseIndexSubjectIndex] unsignedIntValue] - 1;
    // rat indices are zero-indexed internally, so decrement the number on the label

	if ( tag_number == NSNotFound || tag_number >= [self numberOfSubjects]) {
        // invalid rat number
		rat = NSNotFound;
	}
	else {
		rat =  tag_number;
	}
		
	return(rat);
	
}



-(NSString *)nameOfSubjectAtIndex:(NSUInteger)index {
	
	// rat's name is of the form "[Expt Code]00n", e.g. "AP003" or "AP032"
	

	
    NSString *subjectName = [[NSString alloc] initWithFormat:@"%@%02ld",code,index+1];

    return subjectName;
}



-(BarGroup *)groupOfSubjectAtIndex:(NSUInteger)index { 

	if (index >=[subjects count] ) { return nil; }
	
	BarSubject *subject = (BarSubject *)[subjects objectAtIndex:index];
	
	return (BarGroup *)[groups objectAtIndex:[subject groupIndex]];


}

-(NSString *)nameOfGroupOfSubjectAtIndex:(NSUInteger)index; { 
	
    if (index >=[subjects count] ) { return nil; }
	
	return [[self groupOfSubjectAtIndex:index] name];
	
}

-(NSString *)codeOfGroupOfSubjectAtIndex:(NSUInteger)index; { 
	
    if (index >=[subjects count] ) { return nil; }
	
	return [[self groupOfSubjectAtIndex:index] code];
	
}

- (NSUInteger) indexOfGroupOfSubjectAtIndex:(NSUInteger)index; {
        
    if (index >= [subjects count] ) {
        return NSNotFound;
    }
	
	BarSubject *subject = (BarSubject *)[subjects objectAtIndex:(NSUInteger)index];
    
    return [subject groupIndex];
    
}




// ***************************************************************************************
// ***************************************************************************************
// Item methods
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------

-(NSMutableArray *) items {
	
	return items;
}



-(void) addNewItem {
	
	
	BarItem *newItem = [[BarItem alloc] initWithName:@"Untitled Item" andCode:@"I" andDescription:@"an item"];
	[items addObject:newItem];

	
}



-(void) deleteItem:(BarItem *)theItem {
	
	
	[items removeObject:theItem];
	
}



-(void) deleteItemAtIndex:(NSUInteger) index {
	
    BarItem *theItem = [items objectAtIndex:index];
	if (nil != theItem) {
        [self deleteItem:theItem];
    }

}



-(NSUInteger) numberOfItems {

	return [items count];
}



-(BarItem *) itemAtIndex:(NSUInteger)index {

	return [items objectAtIndex:index];
}



-(NSUInteger) indexOfItem: (BarItem *)theItem {
	
	// returns NSNotFound if item not in the array
	
	return [items indexOfObject:theItem];

}




-(BarItem *) itemWithCode:(NSString *)testCode {
	
	NSUInteger i;
	BarItem *testItem;
	
	for (i=0; i< [items count]; i++) {
		
		testItem = [items objectAtIndex:i];
		
		if  ([[testItem code] caseInsensitiveCompare:testCode]== NSOrderedSame) return testItem;
		
	}
	
	return nil;

}

-(BarItem *) itemWithName:(NSString *)itemNameString {
	
	NSUInteger i;
	BarItem *testItem;
	
	for (i=0; i< [items count]; i++) {
		
		testItem = [items objectAtIndex:i];
		
		if  ([[testItem name] compare:itemNameString]== NSOrderedSame) return testItem;
		
	}
	
	return nil;
	
}


-(NSUInteger)itemIndexFromName:(NSString *)itemNameString {
	
	
	BarItem *theItem = [self itemWithName:itemNameString];
	
	return [self indexOfItem:theItem];
	
}


-(NSUInteger)itemIndexFromLabel:(NSString *)labelString {
	
	// given a tag of format "[ExptAbbr][Subject Number][ItemCode]"
	// extract the itemcode, and thus the item and its index..
	// -1 if not recognized
	
	// first read the experiment letter code (alpha)
	// then read the rat index numbers (numeric digits)
	// then read the item code (alpha characters)
	// i.e. in "EX005F", "F" is the item code
 


    NSArray * label_codes = [labelString parseAsBarTenderLabel];

    if (nil == label_codes) {

        return NSNotFound;
    }
	
    BarItem *theItem = [self itemWithCode:[label_codes objectAtIndex:kParseIndexItemCode]];
	
	return [self indexOfItem:theItem];
	
}





// ***************************************************************************************
// ***************************************************************************************
// Group methods
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------

-(NSMutableArray *) groups {

	return groups;

}



-(void) addNewGroup {
	
	BarGroup *newGroup = [[BarGroup alloc] initWithName:@"Untitled Group" andCode:@"G" andDescription:@"a group"];
	[groups addObject:newGroup];
		
}



-(void) deleteGroup:(BarGroup *)theGroup{
	
    BarGroup *theUnassignedGroup = [self unassignedGroup];
    // TODO: should we be able to  delete "Unassigned" group
    // if (theGroup == theUnassignedGroup) { return; }
	[groups removeObject:theGroup];
    
    // NOTE: need to reassign all subjects assigned to this group to "Unassigned"
    // easier to do this once we have re-written code to use objects instead of indexes
    
//	for (BarSubject *theSubject in subjects) {
//        
//        if ([theSubject group] == theGroup) {
//            
//            [theSubject setGroup:theUnassignedGroup];
//        }
//    }
}



-(void) deleteGroupAtIndex:(NSUInteger) index {

    BarGroup *theGroup = [groups objectAtIndex:index];
	if (nil != theGroup) {
        [self deleteGroup:theGroup];
    }
	
}



-(NSUInteger) numberOfGroups {
	
	return [groups count];

}



-(BarGroup *)groupAtIndex:(NSUInteger)index {
	
	return (BarGroup *)[groups objectAtIndex:index];

}

-(NSUInteger) getGroupIndex:(BarGroup *)theGroup {
	
	// return NSNotFound if not in the array
	
	return [groups indexOfObject:theGroup];
}



-(void) setBlockGroups {
	
	//assign subjects to groups in blocks
	// e.g. veh,veh,veh...,drugA,drugA,drugA, ..., drugB,drugB,drugB,..
	
	// don't forget that the 0th block is the unassigned block, and shouldn't be assigned...

	
	NSUInteger numberOfBlocks,subjectsPerBlock, blockIndex,groupIndex, index, subIndex;
	
	// initialize group assignements to "unassigned" (group 0)
	
	for (index = 0; index < [self numberOfSubjects]; index++) {		
		[[self subjectAtIndex:index ] setGroupIndex:0 ] ;
		
	}
	
	// the number of  blocks is the same as the number of groups
	// we subtract 1 to account for default unassigned group
	numberOfBlocks = [self numberOfGroups]-1;
	if (0 == numberOfBlocks) numberOfBlocks = 1;
	subjectsPerBlock = [self numberOfSubjects] / numberOfBlocks;
	
	
	for (blockIndex = 0;blockIndex < numberOfBlocks; blockIndex++) {
		
		groupIndex = blockIndex +1; // the unassinged group at index 0 doesn't count...
	
		for (index = 0; index < subjectsPerBlock; index++) {
			
			subIndex = (blockIndex * subjectsPerBlock) + index;
			
			BarSubject *subject = [self subjectAtIndex:subIndex];
		
			[subject setGroupIndex:groupIndex ] ;
		
		}
		
	}
		
}



-(void) setAlternatingGroups {
	//assign subjects to alternating groups 
	// e.g. veh,drugA,drugB,veh,drugA,drugB,veh,drugA,drugB,...
	
	// don't forget that the 0th block is the unassigned block, and shouldn't be assigned...
	
	NSUInteger numberOfBlocks, subjectsPerBlock,blockIndex, index, subIndex;
	
	
	
	// initialize group assignements to "unassigned" (group 0)
	
	for (index = 0; index < [self numberOfSubjects]; index++) {		
		[[self subjectAtIndex:index ] setGroupIndex:0 ] ;
		
	}
	
	if ([self numberOfGroups] < 2) return;
	
	// the number of  blocks is the same as the number of groups
	// CHECK NUMBER OF GROUPS > 0
	
	numberOfBlocks = [self numberOfSubjects] / ([self numberOfGroups] -1);
	subjectsPerBlock = [self numberOfGroups]-1;
	
	for (blockIndex = 0;blockIndex < numberOfBlocks;blockIndex++) {
				
		for (index = 0; index < subjectsPerBlock; index++) {
			
			subIndex = (blockIndex *subjectsPerBlock) + index;
			
			BarSubject *subject = [self subjectAtIndex:subIndex];
			
			[subject setGroupIndex: index+1 ] ;
			
		}
		
	}
	
	
	
	
}



-(NSString *)codeOfGroupAtIndex:(NSUInteger)index {
	
	BarGroup *theGroup;
	
	theGroup = [groups objectAtIndex:index];
	if (theGroup !=nil ) return [theGroup code];
	else return nil;

}
- (NSUInteger) indexOfGroupWithCode:(NSString *)groupCode; {
    
    NSUInteger i;
    
    for (i=0; i<[groups count]; i++){
        
        BarGroup *theGroup = (BarGroup *)groups[i];
        
        if ([[theGroup code] isEqualToString:groupCode]) {
            return i;
        }
    }
    
    return NSNotFound;
    
}
- (BarGroup *) unassignedGroup; {
    
    for (BarGroup *theGroup in groups) {
        
        if ([[theGroup name] isEqualToString:@"Unassigned"]) {
            
            return theGroup;
        }
    }
    
    return nil;
    
}

// ***************************************************************************************
// ***************************************************************************************
// Drug methods
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------

// NOTE: store current experimental drug by name of drug; so will break if user changes name

-(NSMutableArray *) drugs {

    return drugs;
}



-(void) addNewDrug {

    BarDrug *newDrug = [[BarDrug alloc] initWithName:@"Untitled Drug" andCode:@"Rx" andDescription:nil];
    [drugs addObject:newDrug];

}

-(void) deleteDrug:(BarDrug *)theDrug{

    [drugs removeObject:theDrug];

}
-(void) deleteDrugAtIndex:(NSUInteger) index {

    [drugs removeObjectAtIndex:index];

}


-(NSUInteger) numberOfDrugs {

    return [drugs count];

}



-(BarGroup *)drugAtIndex:(NSUInteger)index {

    return [drugs objectAtIndex:index];

}



-(NSUInteger) getDrugIndex:(BarDrug *)theDrug {

    // returns NSNotFound if not in array

    return [drugs indexOfObject:theDrug];

}



-(NSString *)nameOfDrugAtIndex:(NSUInteger)index {

    BarDrug *theDrug;

    theDrug = [drugs objectAtIndex:index];
    if (theDrug !=nil ) return [theDrug name];
    else return nil;

}



-(void)addDrugNamesToMenu:(NSMenu *)drugMenu; {

    NSMenuItem *drugNameItem;

    if (drugMenu == nil) return;

    // clear out the menu
    [drugMenu removeAllItems];

    if ( 0 == [drugs count] ) {

        drugNameItem = [[NSMenuItem alloc] initWithTitle:@"<none>" action:NULL keyEquivalent:[NSString string]];
        // default "no-measure" menu item with default action & no key equivalent

        // add the menu item to  the menu
        [drugMenu addItem:drugNameItem];
    }

    for (BarDrug *theDrug in drugs) {

        drugNameItem = [[NSMenuItem alloc] initWithTitle:[theDrug name] action:NULL keyEquivalent:[NSString string]];
        // add the menu item to  the menu
        [drugMenu addItem:drugNameItem];

    }



}

-(BarDrug *)drugWithName:(NSString *)drugName; {

    if (nil == drugName) return nil;

    for (BarDrug *theDrug in drugs) {

        if ([[theDrug name] isEqualToString:drugName]) { return theDrug; }

    }

    return nil;


}

// ***************************************************************************************
// ***************************************************************************************
// Phase methods
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------

// NOTE: store current experimental phase by name of phase; so will break if user changes name

-(NSMutableArray *) phases {

	return phases;
}



-(void) addNewPhase {
	
	BarPhase *newPhase = [[BarPhase alloc] initWithName:@"Untitled Phase" andCode:@"P" andDescription:nil];
	[phases addObject:newPhase];
	
}

-(void) deletePhase:(BarPhase *)thePhase{
	
	[phases removeObject:thePhase];
	
}
-(void) deletePhaseAtIndex:(NSUInteger) index {
	
	[phases removeObjectAtIndex:index];
	
}


-(NSUInteger) numberOfPhases {
	
	return [phases count];

}



-(BarGroup *)phaseAtIndex:(NSUInteger)index {
	
	return [phases objectAtIndex:index];

}



-(NSUInteger) getPhaseIndex:(BarPhase *)thePhase {
	
	// returns NSNotFound if not in array

	return [phases indexOfObject:thePhase];
	
}



-(NSString *)nameOfPhaseAtIndex:(NSUInteger)index {
	
	BarPhase *thePhase;
	
	thePhase = [phases objectAtIndex:index];
	if (thePhase !=nil ) return [thePhase name];
	else return nil;

}
	
	

-(void)addPhaseNamesToMenu:(NSMenu *)phaseMenu; {
	
	NSMenuItem *phaseNameItem;
	
	if (phaseMenu == nil) return;
	
	// clear out the menu
	[phaseMenu removeAllItems];
		
	if ( 0 == [phases count] ) {
	
		phaseNameItem = [[NSMenuItem alloc] initWithTitle:@"<none>" action:NULL keyEquivalent:[NSString string]];
		// default "no-measure" menu item with default action & no key equivalent
		
		// add the menu item to  the menu
		[phaseMenu addItem:phaseNameItem];
	}
	
	for (BarPhase *thePhase in phases) {
		
		phaseNameItem = [[NSMenuItem alloc] initWithTitle:[thePhase name] action:NULL keyEquivalent:[NSString string]];
		// add the menu item to  the menu
		[phaseMenu addItem:phaseNameItem];

	}
	
	
	
}

-(BarPhase *)phaseWithName:(NSString *)phaseName; {
	
	if (nil == phaseName) return nil;
	
	for (BarPhase *thePhase in phases) {
		
		if ([[thePhase name] isEqualToString:phaseName]) { return thePhase; }
		
	}
	
	return nil;
	
	
}


- (NSString *)currentPhaseName; { return currentPhaseName; }


-(void) setCurrentPhaseName:(NSString *)phaseName; { 
	
	if (nil != phaseName) {currentPhaseName = [phaseName copy]; }
	else {phaseName = nil; }
	
	BarPhase *thePhase = [self phaseWithName:currentPhaseName];
	if (nil == thePhase) { currentPhaseName = @"<none>"; }
}


-(void) setCurrentPhaseDay:(NSInteger)day; { 
	
	// 0 indexed 
	// - 1 if not yet started
	// only works if there is a real phase t be set.
	BarPhase *thePhase = [self phaseWithName:currentPhaseName];
	if (nil != thePhase) {
		[thePhase setCurrentDay:day];
	}		
	
	
}

-(NSInteger)dayOfPhaseOfName:(NSString *)phaseName; {
	
	// NOTE: if phases aren't contiguous, then phaseDay gets reset to 1
	// if the phase name is not a known phase e.g. "<none>", return -1 
	
	if ([phaseName isEqualToString:currentPhaseName]) {
		BarPhase *thePhase = [self phaseWithName:phaseName];
		if (nil != thePhase) {
			return [thePhase currentDay];
		}
	}
	return -1;
	
	
}

-(NSString *)nameOfPhaseOfDay:(NSUInteger)dayIndex; {
    
    DailyData *theDay = [self dailyDataForDay:dayIndex];
    return [theDay phaseName];
}





// ***************************************************************************************
// ***************************************************************************************
// Preference methods
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------

-(NSString *) preferenceTitleText; {
	
	
	return ( [NSString stringWithFormat:@"%@ Preference", [[self itemAtIndex:prefItemIndex] name]]);

}

-(NSString *) totalTitleText; {


	return ( [NSString stringWithFormat:@"Total %@ + %@ ", [[self itemAtIndex:prefItemIndex] name], [[self itemAtIndex:baseItemIndex] name]]);

}
							

-(BOOL)hasPreference { return hasPreference; }
-(void)setHasPreference:(BOOL)newPreference { hasPreference = newPreference; }
-(NSUInteger)prefItemIndex { return prefItemIndex;}
-(NSUInteger)baseItemIndex { return baseItemIndex;}


-(void) getIndexOfPreferenceItem:(NSUInteger *)s overItem:(NSUInteger *)w {

	(*s) = prefItemIndex;
	(*w) = baseItemIndex;
	
}


-(void) setPreferenceIndexofItem:(NSUInteger)s overItem:(NSUInteger)w {
	
	prefItemIndex=s;
	baseItemIndex = w;

}

-(BOOL) usePreferenceOverTotal; { return usePreferenceOverTotal; }
-(void) setUsePreferenceOverTotal:(BOOL)useTotal; { usePreferenceOverTotal = useTotal; }

// ***************************************************************************************
// ***************************************************************************************
// COPYING methods
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone {
	
	
	// NOTE: need to update this...
	BarExperiment *copy = [super copyWithZone: zone];
        // calls barobject copy, to copy name, description, code strings

	
	// general expt info
    
    // strings
	[copy setInvestigators: [self investigators]];
	[copy setProtocol: [self protocol]];
	[copy setProjectCode:[self project_code]];
    [copy setProjectName:[self project_name]];

    [copy setWiki:[self wiki]];
	
    // Boolean
	[copy setTemplateFlag: [self templateFlag]];
	
	// NSDates
	[copy setStartTime:[self startTime]];
	[copy setEndTime:[self endTime]];
	
    //Boolean
	[copy setWaitingForOff:[self waitingForOff]];

    //Boolean
	[copy setUseGroups:[self useGroups]];
   
    //Boolean
	[copy setHasPreference:[self hasPreference]];
    
    // integers
	[copy setPreferenceIndexofItem:[self prefItemIndex]  overItem:[self baseItemIndex]];
	
    // integers
    [copy setUsePreferenceOverTotal: [self usePreferenceOverTotal]];
	
    // bar objects
	[copy setSubjects: [[NSMutableArray allocWithZone: zone] initWithArray: [self subjects] copyItems:YES]];
	[copy setItems: [[NSMutableArray allocWithZone: zone] initWithArray: [self items] copyItems:YES]];
	[copy setGroups: [[NSMutableArray allocWithZone: zone] initWithArray: [self groups] copyItems:YES]];
	[copy setPhases: [[NSMutableArray allocWithZone: zone] initWithArray: [self phases] copyItems:YES]];
    [copy setDrugs: [[NSMutableArray allocWithZone: zone] initWithArray: [self drugs] copyItems:YES]];

	
    // NSStrings
    [copy setCurrentPhaseName:[self currentPhaseName]];
	[copy setLastDailyDataPath:[self lastDailyDataPath]];
//	[copy setBackupSummaryPath:[self backupSummaryPath]];

	
	return copy;
}
	 


// ***************************************************************************************
// ***************************************************************************************
// FILE methods
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------

-(BOOL)archive; {
	
	// move the experiment and associated files into the Archive folder
	NSError *error = nil; 

	
	// rename (move) file "~/Documents/Bartender/Experiments/<code>.barexpt"
	// to file "~/Documents/Bartender/Archives/<code>/<code>.barexpt"
	
	// NOTE: check if archiveDirectoryPath directory already exists, and if so add version number to avoid overwriting....
		
	NSString *exptDirectoryPath = GetExptDirectoryPath();
	
	NSString *exptFilePath = [[exptDirectoryPath stringByAppendingPathComponent:[self code] ] stringByAppendingPathExtension:@"barexpt"];
	// "~/Documents/Bartender/Experiments/<code>.barexpt"

	NSString *archiveDirectoryPath = GetArchiveDirectoryPath([self code]);
	//"~/Documents/Bartender/Archived/<code>"
	
	NSString *archiveFilePath = [[archiveDirectoryPath stringByAppendingPathComponent:[self code] ] stringByAppendingPathExtension:@"barexpt"];
	// "~/Documents/Bartender/Archived/<code>/<code>.barexpt"
	
	[[NSFileManager defaultManager] moveItemAtPath:exptFilePath toPath:archiveFilePath error:&error];
	
	
	// rename (move) directory "~/Documents/Bartender/DailyData/<code>"
	// to directory "~/Documents/Bartender/Archives/<code>/DailyData"

	NSString *dailyDataDirectoryPath = [self getExptDailyDataDirectoryPath];
	//"~/Documents/Bartender/DailyData/[<code>"
	
	NSString *archiveDailyDataDirectoryPath = [archiveDirectoryPath stringByAppendingPathComponent:@"DailyData"];
	//"~/Documents/Bartender/Archived/<code>/DailyData"
	
	[[NSFileManager defaultManager] moveItemAtPath:dailyDataDirectoryPath toPath:archiveDailyDataDirectoryPath error:&error];

	// NOTE: check for errors and error handling?
	
 
 // TODO: set archive flag on firebase
 
     FirebaseSummary *firebase = [[FirebaseSummary alloc] init]; 
     
     [firebase setArchive:[self code]];
    
	return YES;
	
}


-(BOOL) trash; {
	
	// move the experiment and associated files into the Trash
	
	// get the paths of the experiment file and the daily data directory
	// convert to URLs
	// pass the URLs in an array to the sharedWorkSpace for recycling into the trash
	
	
	NSString *exptDirectoryPath = GetExptDirectoryPath();
	NSString *exptFilePath = [[exptDirectoryPath stringByAppendingPathComponent:[self code] ] stringByAppendingPathExtension:@"barexpt"];
	// "~/Documents/Bartender/Experiments/<code>.barexpt"
	
	NSString *dailyDataDirectoryPath = [self getExptDailyDataDirectoryPath];
	//"~/Documents/Bartender/DailyData/[<code>"

	NSURL *exptFileURL = [NSURL fileURLWithPath:exptFilePath isDirectory:NO];
	NSURL *dailyDataDirectoryURL = [NSURL fileURLWithPath:dailyDataDirectoryPath isDirectory:YES];
	
	NSArray *URLs = [NSArray arrayWithObjects:exptFileURL,dailyDataDirectoryURL,nil];
	// an array of file urls
	
	[[NSWorkspace sharedWorkspace] recycleURLs:URLs completionHandler:^(NSDictionary *newURLs, NSError *error) {
		if (error != nil) {
			// Deal with any errors here.
		}
	}];
	
	return YES;
	
}

-(BOOL)save {
	
	// NOTE: should we check here for appropriate CODE and at least 1 item?
	
		
	NSString *exptDirectoryPath = GetExptDirectoryPath();
	
	NSString *exptFilePath = [[exptDirectoryPath stringByAppendingPathComponent:[self code] ] stringByAppendingPathExtension:@"barexpt"];
	
	return [self saveToPath:exptFilePath];
	
}

-(BOOL)saveAsTemplate:(NSString *)templateName; {
	
		
	NSString *templateDirectoryPath = GetTemplateDirectoryPath();
	
	NSString *templateFilePath = [[templateDirectoryPath stringByAppendingPathComponent:templateName] stringByAppendingPathExtension:@"bartemplate"];
	
	return [self saveToPath:templateFilePath];
	
}

	
-(BOOL)saveToPath:(NSString *)exptFilePath; {
	
	NSString *error;

	
	NSMutableDictionary *rootDictionary = [[NSMutableDictionary alloc] init];
	
	[rootDictionary setObject:@"Bartender" forKey:@"creator"];

    NSMutableString *version = [NSMutableString string];
    [version appendString: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    [version appendString:@"."];
    [version appendString: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];

	[rootDictionary setObject:version forKey:@"version"];
	[rootDictionary setObject:[self makeExptParametersDictionary] forKey:@"ExptParameters"];
	[rootDictionary setObject:[self makeSubjectDictionary] forKey:@"Subjects"];
	[rootDictionary setObject:[self makeGroupDictionary] forKey:@"Groups"];
	[rootDictionary setObject:[self makeItemDictionary] forKey:@"Items"];
	[rootDictionary setObject:[self makePhaseDictionary] forKey:@"Phases"];
	[rootDictionary setObject:[self makeCurrentInfoDictionary] forKey:@"CurrentInfo"];
	
	id xmlData = [NSPropertyListSerialization dataFromPropertyList:(id)rootDictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
 
	if(xmlData) {
		NSLog(@"BarExpt: No error creating XML data.");
		
		
		[xmlData writeToFile:exptFilePath atomically:YES];
		
		return YES;
	}
	else {
		NSLog(@"BarExpt: Error creating XML data: %@",error);
		return NO;
	}
	
	return NO;
	
}
-(BOOL) loadFromPath:(NSString *)exptFilePath; {
	
	NSString *errorDesc = nil;
	NSPropertyListFormat format;

	NSLog(@"BarExpt: loadFromPath entered");
	
	// check if the file exists
	if (![[NSFileManager defaultManager] fileExistsAtPath:exptFilePath]) {
		NSLog(@"BarExpt: Can't find the expt file");
		return NO;
	}
	
	NSLog(@"BarExpt: loadFromPath found file");
	
	// load the data in xml format from the file
	NSData *xmlData = [[NSFileManager defaultManager] contentsAtPath:exptFilePath];
	
	NSLog(@"BarExpt loadFromPath loaded xmlData");

	
	// unpack the xmlData into the rootDictionary
	NSDictionary *rootDictionary = (NSDictionary *)[NSPropertyListSerialization
										  propertyListFromData:xmlData
										  mutabilityOption:NSPropertyListMutableContainersAndLeaves
										  format:&format
										  errorDescription:&errorDesc];
	if (!rootDictionary) {
		NSLog(@"BarExpt: Error reading expt file xml: %@, format: %lu", errorDesc, format);
	}
	
	NSLog(@"BarExpt loadFromPath read rootdictionary");
	
	// check on existance of all dictionaries and their items!!!
	
	if (!rootDictionary) return NO;

	NSDictionary *exptParametersDictionary = [rootDictionary objectForKey:@"ExptParameters"];
	NSDictionary *subjectDictionary = [rootDictionary objectForKey:@"Subjects"];
	NSDictionary *groupDictionary = [rootDictionary objectForKey:@"Groups"];
	NSDictionary *itemDictionary = [rootDictionary objectForKey:@"Items"];
	NSDictionary *phaseDictionary = [rootDictionary objectForKey:@"Phases"];
	NSDictionary *currentInfoDictionary = [rootDictionary objectForKey:@"CurrentInfo"];
	
		
	if (exptParametersDictionary) [self unpackExptParametersDictionary:exptParametersDictionary];
	if (subjectDictionary)[self unpackSubjectDictionary:subjectDictionary];
	if (groupDictionary)[self unpackGroupDictionary:groupDictionary];
	if (itemDictionary)[self unpackItemDictionary:itemDictionary];
	if (phaseDictionary)[self unpackPhaseDictionary:phaseDictionary];
	if (currentInfoDictionary)[self unpackCurrentInfoDictionary:currentInfoDictionary];
	
	return YES;	
	
}

-(BOOL) loadFromTemplatePath:(NSString *)templateFilePath; {
	
	// clear out the arrays so we can fill them with contents of template
	
	[subjects  removeAllObjects];
	[items removeAllObjects];
	[phases  removeAllObjects];
	[groups removeAllObjects]; 
	
	// load from template file like any experiment
	[self loadFromPath:templateFilePath];
	
	// now get rid of name, code, and description...
	[self setName:@"Untitled"];
	[self setCode:@"??"];
	[self setDescription:@"Describe experiment here"];
	
	return YES;
}

-(NSDictionary *)makeExptParametersDictionary {
		
		// make a dictionary from the expt parameters:
	
	NSLog(@"BarExpt: makeExptParametersDictionary");
		
		NSDictionary *exptParametersDictionary = [NSDictionary 
											
			dictionaryWithObjects:
				[NSArray arrayWithObjects:
					 name, code, description, investigators, protocol, wiki,project_code,project_name,
					 [NSNumber numberWithUnsignedLong:startTime], [NSNumber numberWithUnsignedLong:endTime],
					// [NSNumber numberWithBool:waitingForOff],  set by presence of ".onweights" file
					 [NSNumber numberWithBool:useGroups], 
					 [NSNumber numberWithBool:hasPreference],
					 [NSNumber numberWithUnsignedLong:prefItemIndex],
					 [NSNumber numberWithUnsignedLong:baseItemIndex],
					 [NSNumber numberWithBool:usePreferenceOverTotal],
			//		 backupSummaryPath,
					 nil]
			 forKeys:
				[NSArray arrayWithObjects:
					 @"name", @"code", @"description", @"investigators", @"protocol", @"wiki",@"project_code",@"project_name",
					 @"startTime", @"endTime",
					// @"waitingForOff", // set by presence of ".onweights" file
					 @"useGroups", 
					 @"hasPreference",
					 @"prefItemIndex", 
					 @"baseItemIndex",
					 @"usePreferenceOverTotal",
				//	 @"backupSummaryPath",
					 nil]
		 ];
		
	return exptParametersDictionary;
		
}


-(BOOL)unpackExptParametersDictionary:(NSDictionary *)dictionary {
	
	// extract the  expt parameters from the dictionary
	
	NSLog(@"BarExpt: Entered unpack expt parameters");
	
	if ([dictionary objectForKey:@"name"]) [self setName:[dictionary objectForKey:@"name"]];	
	if ([dictionary objectForKey:@"code"]) [self setCode:[dictionary objectForKey:@"code"]];
	if ([dictionary objectForKey:@"description"]) [self setDescription:[dictionary objectForKey:@"description"]];
	if ([dictionary objectForKey:@"investigators"]) [self setInvestigators:[dictionary objectForKey:@"investigators"]];
	if ([dictionary objectForKey:@"protocol"]) [self setProtocol:[dictionary objectForKey:@"protocol"]];
    if ([dictionary objectForKey:@"wiki"]) [self setWiki:[dictionary objectForKey:@"wiki"]];
	if ([dictionary objectForKey:@"project_code"]) [self setProjectCode:[dictionary objectForKey:@"project_code"]];
    if ([dictionary objectForKey:@"project_name"]) [self setProjectName:[dictionary objectForKey:@"project_name"]];
	
	if ([dictionary objectForKey:@"startTime"]) [self setStartTime:[[dictionary objectForKey: @"startTime"] unsignedLongValue]];
	if ([dictionary objectForKey:@"endTime"]) [self setEndTime:[[dictionary objectForKey:@"endTime"] unsignedLongValue]];
	
	// [self setWaitingForOff:[[dictionary objectForKey:"waitingForOff"] boolValue]];
	// waitingForOff is set by checking for presence of "[ExptCode].onweights" file
	
	if ([dictionary objectForKey:@"useGroups"])  [self setUseGroups:[[dictionary objectForKey:@"useGroups"] boolValue]];
	
	if ([dictionary objectForKey:@"hasPreference"]) [self setHasPreference:[[dictionary objectForKey:@"hasPreference"] boolValue]];
	
	if ([dictionary objectForKey:@"prefItemIndex"] && [dictionary objectForKey:@"baseItemIndex"]) {
			[self setPreferenceIndexofItem:[[dictionary objectForKey:@"prefItemIndex"] unsignedLongValue]
						  overItem:[[dictionary objectForKey:@"baseItemIndex"] unsignedLongValue]];
	}

	if ([dictionary objectForKey:@"usePreferenceOverTotal"]) [self setUsePreferenceOverTotal:[[dictionary objectForKey:@"usePreferenceOverTotal"] boolValue]];

//	if ([dictionary objectForKey:@"backupSummaryPath"]) [self setBackupSummaryPath:[dictionary objectForKey:@"backupSummaryPath"]];	

	
	
	return YES;
	
}




-(NSDictionary *)makeSubjectDictionary {
	
	// just make an NSArray with an NSUInteger groupIndex for each subject
	
	NSLog(@"BarExpt: makeSubjectDictionary");
	
	NSUInteger i, groupIndex;
	
	NSMutableArray *indices = [[NSMutableArray alloc] init];

	for (i=0; i < [subjects count]; i++) {
		
		groupIndex = [[subjects objectAtIndex:i] groupIndex];
		
		[indices addObject:[NSNumber numberWithUnsignedLong: groupIndex]];

	}
	
	NSDictionary *subjectDictionary = [NSDictionary  dictionaryWithObject:indices  forKey:@"GroupIndices"];
	
	return subjectDictionary;
	
	
}

-(BOOL) unpackSubjectDictionary:(NSDictionary *) dictionary {


	NSUInteger i, groupIndex;
	NSNumber *nsNumber;

	NSArray *indices = [dictionary objectForKey:@"GroupIndices"];
	
	for (i=0; i < [indices count]; i++) {
		
		nsNumber = (NSNumber *)[indices objectAtIndex:i];
		
		groupIndex = [nsNumber unsignedLongValue];
		
		BarSubject *theSubject = [[BarSubject alloc] initWithGroupIndex: groupIndex];
		
		[subjects addObject:theSubject];
		
	}
	
	return YES; 

}



-(NSDictionary *)makeGroupDictionary {
	
	// name, code, description, and color
	
	NSLog(@"BarExpt: makeGroupDictionary");

	
	NSUInteger i;
	
	NSMutableArray *groupArray = [[NSMutableArray alloc] init];

	
	for (i=0; i < [groups count]; i++) {
		
		BarGroup *theGroup = [groups objectAtIndex:i];
		
		NSDictionary *groupSubDictionary = [NSDictionary 
			dictionaryWithObjects:
				[NSArray arrayWithObjects: [theGroup name], [theGroup code], [theGroup description], nil]
			forKeys:
				[NSArray arrayWithObjects: @"name", @"code", @"description", nil]
			];
		
		// NOTE need to add group colors
											
											
		[groupArray addObject:groupSubDictionary];
		
	}
	
	NSDictionary *groupDictionary = [NSDictionary  dictionaryWithObject:groupArray  forKey:@"GroupsArray"];
	
	return groupDictionary;	
}


-(BOOL) unpackGroupDictionary:(NSDictionary *) dictionary   {

	NSUInteger i;

	NSDictionary *subDictionary;
	BarGroup *theGroup;
	
	NSArray *groupArray = [dictionary objectForKey:@"GroupsArray"];
 
	for (i=0;i< [groupArray count]; i++) {
		
		subDictionary = (NSDictionary *)[groupArray objectAtIndex:i];
		
		theGroup = [[BarGroup alloc] 
							  initWithName:[subDictionary objectForKey:@"name"] 
							  andCode:[subDictionary objectForKey:@"code"] 
							  andDescription:[subDictionary objectForKey:@"description"] 
							  ];

		
		[[self groups] addObject:theGroup];
		
	}


	return YES;  

}

-(NSDictionary *)makeDrugDictionary {

    // name, code, description, and color

    NSLog(@"BarExpt: makeDrugDictionary");


    NSUInteger i;

    NSMutableArray *drugArray = [[NSMutableArray alloc] init];


    for (i=0; i < [drugs count]; i++) {

        BarDrug *theDrug = [drugs objectAtIndex:i];

        NSDictionary *drugSubDictionary = [NSDictionary
                                            dictionaryWithObjects:
                                            [NSArray arrayWithObjects: [theDrug name], [theDrug code], [theDrug description], nil]
                                            forKeys:
                                            [NSArray arrayWithObjects: @"name", @"code", @"description", nil]
                                            ];

        // NOTE need to add drug colors


        [drugArray addObject:drugSubDictionary];

    }

    NSDictionary *drugDictionary = [NSDictionary  dictionaryWithObject:drugArray  forKey:@"DrugsArray"];

    return drugDictionary;
}


-(BOOL) unpackDrugDictionary:(NSDictionary *) dictionary   {

    NSUInteger i;

    NSDictionary *subDictionary;
    BarDrug *theDrug;

    NSArray *drugArray = [dictionary objectForKey:@"DrugsArray"];

    for (i=0;i< [drugArray count]; i++) {

        subDictionary = (NSDictionary *)[drugArray objectAtIndex:i];

        theDrug = [[BarDrug alloc]
                    initWithName:[subDictionary objectForKey:@"name"]
                    andCode:[subDictionary objectForKey:@"code"]
                    andDescription:[subDictionary objectForKey:@"description"]
                    ];


        [[self drugs] addObject:theDrug];

    }


    return YES;

}




-(NSDictionary *)makeItemDictionary {
	
	// name, code, description
	
	NSLog(@"BarExpt: makeItemDictionary");
	
	NSUInteger i;
	
	NSMutableArray *itemArray = [[NSMutableArray alloc] init];
	
	
	for (i=0; i < [items count]; i++) {
		
		BarItem *theItem = [items objectAtIndex:i];
		
		NSDictionary *itemSubDictionary = [NSDictionary 
											dictionaryWithObjects:
										   [NSArray arrayWithObjects: [theItem name], [theItem code], [theItem description], [NSNumber numberWithInt:[theItem onOffType]], nil]
											forKeys:
												[NSArray arrayWithObjects: @"name", @"code", @"description", @"onOffType",nil]
											];
				
		
		[itemArray addObject:itemSubDictionary];
		
	}
	
	NSDictionary *itemDictionary = [NSDictionary  dictionaryWithObject:itemArray  forKey:@"ItemsArray"];
	
	return itemDictionary;	
	
	
}
-(BOOL) unpackItemDictionary:(NSDictionary *) dictionary   {
	
	NSUInteger i;
	
	NSDictionary *subDictionary;
	
	NSArray *itemArray = [dictionary objectForKey:@"ItemsArray"];
	
	for (i=0;i< [itemArray count]; i++) {
		
		subDictionary = (NSDictionary *)[itemArray objectAtIndex:i];
		
		BarItem *theItem = [[BarItem alloc] init];
		
		if ([subDictionary objectForKey:@"name"]) [theItem setName: [subDictionary objectForKey:@"name"]];
		if ([subDictionary objectForKey:@"code"]) [theItem setCode: [subDictionary objectForKey:@"code"]];
		if ([subDictionary objectForKey:@"description"]) [theItem setDescription: [subDictionary objectForKey:@"description"]];
		if ([subDictionary objectForKey:@"onOffType"]) [theItem setOnOffType: [[subDictionary objectForKey:@"onOffType"] intValue]];
	
		[[self items] addObject:theItem];
		
	}
	
	
	return YES;  
	
}

-(NSDictionary *)makePhaseDictionary; {
	
	// name, description
	
	NSLog(@"BarExpt: makePhaseDictionary");
	
	NSUInteger i;
	
	NSMutableArray *phaseArray = [[NSMutableArray alloc] init];
	
	
	for (i=0; i < [phases count]; i++) {
		
		BarPhase *thePhase = [phases objectAtIndex:i];
		
		NSDictionary *phaseSubDictionary = [NSDictionary 
										   dictionaryWithObjects:
										   [NSArray arrayWithObjects: [thePhase name], [thePhase description], [NSNumber numberWithLong: [thePhase currentDay]], nil]
										   forKeys:
										   [NSArray arrayWithObjects: @"name",  @"description", @"currentDay",nil]
										   ];
		
		
		[phaseArray addObject:phaseSubDictionary];
		
	}
	
	NSDictionary *phaseDictionary = [NSDictionary  dictionaryWithObject:phaseArray  forKey:@"PhasesArray"];
	
	return phaseDictionary;	
	
	
}
-(BOOL) unpackPhaseDictionary:(NSDictionary *) dictionary; {
	
	NSUInteger i;
	
	NSDictionary *subDictionary;
	
	NSArray *phaseArray = [dictionary objectForKey:@"PhasesArray"];
	
	for (i=0;i< [phaseArray count]; i++) {
		
		subDictionary = (NSDictionary *)[phaseArray objectAtIndex:i];
		
		BarPhase *thePhase = [[BarPhase alloc] init];
		
		if ([subDictionary objectForKey:@"name"]) [thePhase setName: [subDictionary objectForKey:@"name"]];
		if ([subDictionary objectForKey:@"description"])  [thePhase setDescription: [subDictionary objectForKey:@"description"]];
		if ([subDictionary objectForKey:@"currentDay"] ) [thePhase setCurrentDay: [ [subDictionary objectForKey:@"currentDay"] intValue]];
		
		[[self phases] addObject:thePhase];
		
	}
	
	
	return YES;  
	
}

-(NSDictionary *)makeCurrentInfoDictionary {
	
	NSLog(@"BarExpt: makeCurrentInfoDictionary");

	
	// make a dictionary from the expt parameters:
	
	NSArray *objectArray = [NSArray arrayWithObjects:
							currentPhaseName, 
							lastDailyDataPath,
							nil];
	
	NSArray *keyArray = [NSArray arrayWithObjects:
						 @"currentPhaseName", 
						 @"lastDailyData", 
						 nil];
	
	
	NSDictionary *currentInfoDictionary = [NSDictionary dictionaryWithObjects:objectArray forKeys:keyArray ];
	
	NSLog(@"BarExpt: made CurrentInfoDictionary");

	
	return currentInfoDictionary;
	
}


-(BOOL)unpackCurrentInfoDictionary:(NSDictionary *)dictionary {
	
	// extract the  expt parameters from the dictionary
	
	NSLog(@"BarExpt: Entered unpack currentInfo");
	
	if ([dictionary objectForKey:@"currentPhaseName"])
		[self setCurrentPhaseName:[dictionary objectForKey:@"currentPhaseName"]];	
	if ([dictionary objectForKey:@"lastDailyData"])
		[self setLastDailyDataPath:[dictionary objectForKey:@"lastDailyData"]];
	
			
	return YES;
	
}

-(NSDate *)last_data_update; {

    NSDate *last_data_update = NULL;
    for (NSUInteger d=0;d< [self numberOfDays]; d++ ) {

        DailyData *dailyData = [self dailyDataForDay:d];

        if (NULL == last_data_update) { last_data_update = [dailyData offTime]; }
        else if ([[dailyData offTime] compare:last_data_update] == NSOrderedDescending) {
            last_data_update = [dailyData offTime];
        }
    }
    return last_data_update;
}

@end
