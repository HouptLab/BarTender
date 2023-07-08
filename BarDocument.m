//
//  BarDocument.m
//  Bartender
//
//  Created by Tom Houpt on 09/7/6.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import "BarDocument.h"
#import "DailyDataDocument.h"
#import	"ExptInfoController.h"
#import "BarSummaryData.h"
#import "BarBalance.h"
#import "BCAlert.h"
#import "BarDirectories.h"

#import "BarUtilities.h"
#import "SettingsController.h"

@implementation BarDocument

// ***************************************************************************************
// ***************************************************************************************
// NSDocument methods.... 
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------

-(id)init {
    self = [super init];
    if (self) {
		
		// Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		
        currentExpts = [[NSMutableArray alloc] init];
		[self loadActiveExperiments];
		
		balance = [[BarBalance alloc] init];
        
        currentDailyDataDocuments = [[NSMutableArray alloc] init];
				
    }
    return self;
}

- (NSString *)windowNibName {
    // Implement this to return a nib to load OR implement -makeWindowControllers to manually create your controllers.
    return @"BarDocument";
}

-(void)awakeFromNib {
    [exptTableView setTarget:self];
    [exptTableView setDoubleAction:@selector(handleDoubleClick:)];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    return YES;
}

// ***************************************************************************************
// ***************************************************************************************
// DailyDataDocument Interface 
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------


-(void)addDailyDataDocument:(DailyDataDocument*) ddd; {
    
    if (NSNotFound == [currentDailyDataDocuments indexOfObject:ddd]) {
        [currentDailyDataDocuments addObject:ddd];
    }
    
}
-(void)removeDailyDataDocument:(DailyDataDocument*) ddd; {
    
    [currentDailyDataDocuments removeObject:ddd];
    [ddd close];
    
}


-(DailyDataDocument *)openDailyData; {
	
	// create a new DailyData Document with window, etc..	
	//	theDailyDataDocument = [[DailyDataDocument alloc] init];
	// just a plain alloc init doesn't work?
	
	// because its a document, it needs to be initialized with type, etc?
	
	NSString *dailyDataType = @"New Daily Data";
	NSError *errorCode;
	
	DailyDataDocument *theDailyData = [[DailyDataDocument alloc] initWithType:dailyDataType error:&errorCode];
	
//	[theDailyData setTheExperiment:nil];
    
    [self addDailyDataDocument:theDailyData];
    
	[theDailyData setBartender:self];
	
	// tell the DailyData Document (when the nib is loaded) that it was created by a New... call
	//[theDailyData launchedFromNew];
	
	[theDailyData makeWindowControllers];
	
	[theDailyData showWindows];
	
	return theDailyData;
	
}


-(IBAction)weighBottlesOn:(id)sender {
	
	NSLog(@"Weigh Bottles On Pressed\n");
	
	BarExperiment *theExperiment = nil;
	
	// is there an experiment currently selected?
	if (nil != [self selectedExpt] ) {
		
		// check if we can weigh the bottles on?
		if ([[self selectedExpt] waitingForOff]) {
			// can't weigh off if we haven't weighed on yet
			NSString *infoText = [NSString stringWithFormat:@"Waiting to weigh OFF items for Experiment \"%@\".", [[self selectedExpt] codeName]];
			BCOneButtonAlert(	NSWarningAlertStyle, @"Can't Weigh Items ON",  infoText,  @"OK");	
			return;
		}
		
		// use this as the current experiment
		theExperiment = [self selectedExpt];
		
	}
	
	// create a new DailyData Document for ON weights with window, etc..	
	DailyDataDocument *theDailyDataDoc = [self openDailyData];
    
    [theDailyDataDoc startWeighingInState:kWeighingOn WithTheExperiment: theExperiment];

}

-(IBAction)weighBottlesOff:(id)sender {
	
	NSLog(@"Weigh Bottles Off Pressed\n");
	
	BarExperiment *theExperiment = nil;
	
	// is there an experiment currently selected?
	if (nil != [self selectedExpt] ) {
		
		// check if we can weigh the bottles on?
		
		if (![[self selectedExpt] waitingForOff]) {
			
			// can't weigh off if we haven't weighed on yet
			
			NSString *infoText = [NSString stringWithFormat:@"Items for Experiment \"%@\" have not been weighed ON.", [[self selectedExpt] codeName]];
			
			BCOneButtonAlert(	NSWarningAlertStyle,
						   @"Can't Weigh Items OFF", 
						   infoText, 
						   @"OK");	
			
			return;
			
		}
		
		// use this as the current experiment

		theExperiment = [self selectedExpt];
				
	}
		
	// create a new DailyData Document for OFF weights with window, etc..	
	DailyDataDocument *theDailyDataDoc = [self openDailyData];

	[theDailyDataDoc startWeighingInState:kWeighingOff WithTheExperiment: theExperiment];

}

// ***************************************************************************************
// ***************************************************************************************
// Experiment Managment 
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------



-(void)createExptInfoController; {
	
	// if first time through we need to instantiate the exptInfoController
	if (exptInfoController == nil) {
		
		exptInfoController = [[ExptInfoController alloc] init];
		
		[exptInfoController setBartender:self];
		NSLog(@" ExptInfoController's Bartender was set by BarDocument");
		
	}
	
}


-(IBAction)newExperiment:(id)sender {
	
	NSLog(@"New Experiment Pressed\n");
		
	
	// make sure the exptInfoController has been instantiated...
	[self createExptInfoController];
	
	
	// create a new experiment and pass it to the experiment controller...
	BarExperiment *newExpt = [[BarExperiment alloc] init];
	
	[exptInfoController setTheExperiment:newExpt];

	// make the exptInfoController visible
	[exptInfoController showWindow:self];

	
}

-(void)handleDoubleClick:(id)sender; {
    
    [self editExperiment:sender];
}
-(IBAction)editExperiment:(id)sender {
	
	NSLog(@"edit Experiment Pressed\n");
	
	
	if (nil == [self selectedExpt] ) return;
	
	// make sure the exptInfoController has been instantiated...
	[self createExptInfoController];

	
	// set the exptInfoController to edit the selected experiment..
	[exptInfoController setTheExperiment:[self selectedExpt]];

	
	// make the exptInfoController visible
	[exptInfoController showWindow:self];

		
}

-(IBAction)duplicateExperiment:(id)sender; {
	
	NSLog(@"Duplicate Expt  called");
		
	if (nil == [self selectedExpt]) return;

	// get a copy of the selected experiment
	BarExperiment *duplicateExpt = [[self selectedExpt] copy];
	
	// rename it as a copy
	[duplicateExpt setName:[NSString stringWithFormat:@"copy of %@",[[self selectedExpt] name]]];
	[duplicateExpt setCode:[NSString stringWithFormat:@"%@cc",[[self selectedExpt] code]]];
	
	// save the duplicate
	[duplicateExpt save];
	 
	// add duplicate expt to our list of experiments
	[currentExpts addObject:duplicateExpt];
	
	// update the table of experiments
	[exptTableView reloadData];
	
}


-(IBAction)graphExperiment:(id)sender {
		
	NSLog(@"Graph Expt Info called");
	
	NSLog(@"Graph Expt needs to be implemented");
	
	if (nil == [self selectedExpt]) return;
	
	// NOTE: pass the experiment info off to Xynk?
	
	
	BCOneButtonAlert(NSInformationalAlertStyle,@"Graph Expt", @"This feature is not yet implemented.",@"OK");

}

-(IBAction)saveExperimentSummary:(id)sender {
	
	NSLog(@"saveExptSummary Info called");
	
	if (nil == [self selectedExpt]) return;
	
	// ask user where they want to save the summary data?
	
	NSSavePanel *sp;
	NSInteger runResult;
	
	/* create or get the shared instance of NSSavePanel */
	sp = [NSSavePanel savePanel];
	
	/* set up new attributes */
	[sp setRequiredFileType:@"txt"];
	
	/* set the suggest file name */
	BarExperiment *theExperiment = [self selectedExpt];
	NSString *fileName = [theExperiment getSummaryFileName];
	
	[sp setNameFieldStringValue:fileName];
	
	/* display the NSSavePanel */
	runResult = [sp runModal];
	
	if (runResult != NSOKButton) return;
	
	NSString *myFilePath = [[sp filename] copy];
		
	/* if successful, save file under designated name */
	
	
	/*
	 
	 To write out a BarExperiment summary data to a delimited file
	 
	 1. initialize a BarSummaryData object with the experiment
	 
	 2. call [BarSummaryData update] to put the summary data to the summaryDataString
	 
	 3. write the summary data out to the file with [BarSummaryData writeToFileAtPath:]
	 
	 */
	
	
	BarSummaryData *summary = [[BarSummaryData alloc] initWithExperiment:[self selectedExpt]];
	
	[summary update];
	
	[summary writeToFileAtPath:myFilePath];
		 
}

-(IBAction)saveExperimentToXynkImport:(id)sender; {

    NSLog(@"saveExptSummary Info called");

    if (nil == [self selectedExpt]) return;

    // ask user where they want to save the summary data?

    NSSavePanel *sp;
    NSInteger runResult;

    /* create or get the shared instance of NSSavePanel */
    sp = [NSSavePanel savePanel];

    /* set up new attributes */
    [sp setRequiredFileType:@"txt"];

    /* set the suggest file name */
    BarExperiment *theExperiment = [self selectedExpt];
    NSString *fileName = [theExperiment getSummaryFileName];

    [sp setNameFieldStringValue:fileName];

    /* display the NSSavePanel */
    runResult = [sp runModal];

    if (runResult != NSOKButton) return;

    NSString *myFilePath = [[sp filename] copy];

    /* if successful, save file under designated name */


    /*

     To write out a BarExperiment summary data to a delimited file

     1. initialize a BarSummaryData object with the experiment

     2. call [BarSummaryData update] to put the summary data to the summaryDataString

     3. write the summary data out to the file with [BarSummaryData writeToFileAtPath:]

     */


    BarSummaryData *summary = [[BarSummaryData alloc] initWithExperiment:[self selectedExpt]];

    [summary update];

    [summary writeToFileAtPath:myFilePath];

}

-(IBAction)saveExperimentToFirebase:(id)sender; {

    NSLog(@"saveExpt to Firebase  called");

    if (nil == [self selectedExpt]) return;

    // ask user where they want to save the summary data?    

    BarSummaryData *summary = [[BarSummaryData alloc] initWithExperiment:[self selectedExpt]];

   // [summary update];

    [summary writeToFirebase];

}




-(IBAction)removeExperiment:(id)sender {
	
	BOOL removed = NO;
	
	NSLog(@"Remove Expt  called");
	
	if (nil == [self selectedExpt]) return;
	
	NSString *titleString = [NSString stringWithFormat:@"Remove Expt %@", [[self selectedExpt] code]];
	
	// NOTE: check for experiment still waiting to weigh bottles off?
	
	NSInteger flag = BCThreeButtonAlert(NSWarningAlertStyle,titleString, @"How do you want to remove this experiment?\n\n'Archive' will move expt and data files into archival folder.\n\n'Delete' will permanently delete expt and all of its data.\n\n",@"Archive",@"Delete", @"Cancel");
	
	if (NSAlertThirdButtonReturn == flag) return; //cancelled
	
	if (NSAlertFirstButtonReturn == flag) {
		
		// archived
		
		[[self selectedExpt] archive];
		
		removed = YES;
		
	}
	else {
		
		// delete

		// check that user really wants to delete?
		flag = BCTwoButtonAlert(NSWarningAlertStyle,titleString, @"Are you really sure you want to trash this experiment and all its data?",@"Delete", @"Cancel");
		if (NSAlertSecondButtonReturn == flag)  return;
		
		flag = BCTwoButtonAlert(NSWarningAlertStyle,titleString, @"Deletion cannot be undone\nbut files will be in the Trash",@"Delete", @"Cancel");
		if (NSAlertSecondButtonReturn == flag)  return;
		
		// move all the expt files into the trash....
		
		[[self selectedExpt] trash];
		
		removed = YES;
				

	}
	
	if (removed) {
		// remove the archived experiment from the list of experiments...
		[currentExpts removeObject:[self selectedExpt]];
		
		// update the table of experiments
		[exptTableView reloadData];
	
		if (NSAlertFirstButtonReturn) {
			BCOneButtonAlert(NSInformationalAlertStyle,titleString, @"The expt and its files have been moved to the Archives folder.",@"OK");
		}
		else {
			BCOneButtonAlert(NSInformationalAlertStyle,titleString, @"The expt and its files have been moved to the Trash.",@"OK");

		}
		
	}
	
	// UNDOABLE -- archiving, not deletion

}


-(IBAction)weighOnExperiment:(id)sender; {
	
	NSLog(@"Weigh On Experiment Pressed\n");
	
	if (nil == [self selectedExpt]) return;
	
	// NOTE: check if waiting to weigh OFF 
	// -- prompt to override current weights?
	//	-- prompt to save current on weights (w/o off) and start new weigh on?
	
	// create a new DailyData Document with window, etc..	
	DailyDataDocument *theDailyData = [self openDailyData];
	
	[theDailyData setToOnWeights];
	
	[theDailyData setTheExperiment:[self selectedExpt]];	
	
}


-(IBAction)weighOffExperiment:(id)sender; {
	
	NSLog(@"Weigh Off Experiment\n");
	
	if (nil == [self selectedExpt]) return;
	
	// NOTE: check if waiting to weigh ON 
	//	-- prompt to start current off weights (w/o off) without on weights?
	

	// create a new DailyData Document with window, etc..	
	DailyDataDocument *theDailyData = [self openDailyData];

	[theDailyData setToOffWeights];
	
	[theDailyData setTheExperiment:[self selectedExpt]];	

}


-(BOOL)validateMenuItem:(NSMenuItem *)anItem; {

    return [anItem isEnabled];

}

-(void)closeExptInfo:(id)sender andSaveExpt:(BOOL)saveFlag; {
	
	NSLog(@"Close Expt Info called");

	if (exptInfoController != nil && exptInfoController == sender) {
		
		// retrieve the edited Experiment from the exptInfo Controller, and
		// make sure it is in our list of experiments
		BarExperiment *editedExperiment = [exptInfoController getExperiment];
  
        if (nil != editedExperiment){     
        
            if (![currentExpts containsObject:editedExperiment]) {
                    [currentExpts addObject:editedExperiment];
            }
            
                    // save the edited experiment to disk...
            if (saveFlag) { [editedExperiment save]; }
        }
		// update the table of experiments
		[exptTableView reloadData];
	}

	
	/* 
	 NOTE: put this is BarDocument release?
	 in case we need to get rid of the exptInfoController:
	 
	 [exptInfoController release];
	 NSLog(@"ExptInfoController released by BarDocument");
	 exptInfoController = nil;
	 
	 */
}




-(BarExperiment *)experimentWithCode:(NSString *)code {
	
	BarExperiment *expt;
	unsigned long i;
	
	for (i=0; i < [currentExpts count]; i++) {
	
		expt = (BarExperiment *)[currentExpts objectAtIndex:i];
	
        if ([[expt code] caseInsensitiveCompare:code] == NSOrderedSame) { return expt; }
	
	}

	return nil;

}



-(BarExperiment *)getExperimentFromLabel:(NSString *)labelString {
	
	// gets the first set of characters from the string (terminated by non-alpha character)
	// and match it with the code for one of the global experiments
	// i.e. in "EX005F", "EX" is the experiment code

    NSArray *label_codes = [labelString parseAsBarTenderLabel];

    if (nil == label_codes) { return nil; }

    return [self experimentWithCode:label_codes[kParseIndexExptCode]];

	
}


-(void)loadActiveExperiments {
	
	NSError *fileManagerError;
	BOOL isDirectory;
		
	NSString *exptDirectoryPath = GetExptDirectoryPath();
	
	NSFileManager *defaultFileManager = [NSFileManager defaultManager];

	// does exptDirectory exist?
	if ( ![defaultFileManager fileExistsAtPath:exptDirectoryPath isDirectory:&isDirectory] ) return;
			// couldn't find the expt Directoy 
	if (!isDirectory) return;
		// it wasn't a directory...
	
	
	NSArray *array = [[NSFileManager defaultManager] 
					  contentsOfDirectoryAtPath:exptDirectoryPath error:&fileManagerError]; 
	if (array == nil) { 
		// Handle the error 
		
	} 
	
	unsigned long i;
	// iterate through the array of file names, and load those with a ".barexpt" extension
	for (i= 0; i < [array count]; i++) {
		
		NSString *fileName = (NSString *)[array objectAtIndex:i];
		
		if ( [fileName hasSuffix:@".barexpt"] ) {
			// then we want to load the experiment
			
			NSString *filePath = [exptDirectoryPath stringByAppendingPathComponent:fileName];
			
			BarExperiment *theExpt = [[BarExperiment alloc] initFromPath:filePath];
			
			// check if experiment has an active ".onweights" file
			if ([theExpt onWeightsFileExists]) { [theExpt setWaitingForOff:YES]; }
			
			[currentExpts addObject:theExpt];
			
		}
		
	}
	
	// update the table of experiments..
	[exptTableView reloadData];	

}


-(BarExperiment *)selectedExpt; {
// return the currently selected experiment on the exptTableView
// returns nil if no expt is currently selected
	
	// what is the currently selected row of the table view?
	NSInteger selectedRowIndex = [exptTableView selectedRow];
	if (selectedRowIndex == -1) return nil; // no row is currently selected
	
	// get the experiment corresponding to the selected row...	
	BarExperiment *selectedExpt = (BarExperiment *) [currentExpts objectAtIndex:(NSUInteger)selectedRowIndex];
	
	return selectedExpt;
	
}


-(BarBalance *)balance;  { return balance; }




-(IBAction)toggleFakeReading:(id)sender; {
    [balance toggleFakeReading];
}

// get the interface for the balance


// ***************************************************************************************
// ***************************************************************************************
// Methods for getting Table Text for display in NSTableView exptTableView
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------


// Getting Values for the table

-(NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	
	if (currentExpts == nil) return 0;
	
	if (aTableView == exptTableView) return( (NSInteger)[currentExpts count] );
	return 0;
	
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	
	// should be able to use the identifier to get the value pretty directly...
	
	NSObject *objectAtIndex = nil;
	NSString *identifier = [aTableColumn identifier];
	
	
	if (currentExpts == nil) return nil;
	
	if (aTableView == exptTableView)	{
		objectAtIndex =  (NSObject *)[currentExpts objectAtIndex:(NSUInteger)rowIndex];
		return [objectAtIndex valueForKey:identifier];
	
	}
	
	return nil;
	
}


// Setting Values

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	
	// should be able to use the identifier to set the value pretty directly...
	// in BarDocument cannot edit the values, just view them...
	/*
	NSObject *objectAtIndex = nil;
	NSString *identifier = [aTableColumn identifier];
	
	// just assume that only strings are being set by the table...	
	if (currentExpts == nil) return;
	if (aTableView == exptTableView) {
		objectAtIndex =  [currentExpts itemAtIndex:rowIndex];
		[objectAtIndex setValue:anObject forKey:identifier];
	}
	 */
	
}

//Dragging
//– tableView:acceptDrop:row:dropOperation:  
//– tableView:namesOfPromisedFilesDroppedAtDestination:forDraggedRowsWithIndexes:  
//– tableView:validateDrop:proposedRow:proposedDropOperation:  
//– tableView:writeRowsWithIndexes:toPasteboard:

// Sorting
//– tableView:sortDescriptorsDidChange:  


@end
