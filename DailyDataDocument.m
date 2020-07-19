//
//  DailyDataDocument.m
//  Bartender
//
//  Created by Tom Houpt on 09/6/14.dailu
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import "DailyDataDocument.h"

#import "BarExperiment.h"
#import "BarItem.h"
#import "BCDailyDataWebView.h"
#import "BCAlert.h"
#import "BarBalance.h"
#import "FadeOutText.h"

#define kMaxNumWeightTries 20 // number of times to try and get a stable weight for scanned item
// if balance is checked every 0.1 s, this means trying for 2 seconds


@implementation DailyDataDocument


// ***************************************************************************************
// ***************************************************************************************
// NSDocument methods.... 
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------


-(NSString *)windowNibName {
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"DailyData";
}


-(void)windowControllerDidLoadNib:(NSWindowController *) aController {
    
    [super windowControllerDidLoadNib:aController];
    
    
    // Add any code here that needs to be executed once the windowController has loaded the document's window.

//	// assume we only have one controller and one window...
//	NSWindow myWindow = [ [ [ self windowControllers ] objectAtIndex:0 ] window ];
//	
//	if (kDataOnly == currentStatus) {
//		
//		// HIDE the window if we only need the daily data...
//		
//		[myWindow orderOut:self];
//		
//	}
//	else {
//		[myWindow makeKeyAndOrderFront:self]
//		
//	}
	
	
    lastWeight = -32000.0;

      
    // register for notifications
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(updateWeightDisplay:)
                               name:kBarBalanceReadingDidChangeNotification
                             object:nil];

    
	
}





-(NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.
	
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
	
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
	
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}


-(BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.
	
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}



- (void)printShowingPrintPanel:(BOOL)showPanels; {
    
//    If you want users to be able to print a document, you must override printOperationWithSettings: error:, possibly providing a modified NSPrintInfo object.
	
	// get page size from [self printInfo]
//	NSRect paperRect = NSMakeRect(0,0,[[self printInfo] paperSize].width, [[self printInfo] paperSize].height);
	
    // Obtain a custom view that will be printed
//    NSView *printView = [[BCDailyDataWebView alloc] initWithDailyData:dailyData andTable:dailyTableView];
	
	BCDailyDataWebView *myWebView = [[BCDailyDataWebView alloc] initWithDailyData:dailyData andTable:dailyTableView];
    
       
    NSView *printView = [[[myWebView mainFrame] frameView] documentView];
  

    // Construct the print operation and setup Print panel
//   NSPrintOperation *printOp = [NSPrintOperation
//               printOperationWithView:printView
//               printInfo:[self printInfo]];
    // don't pass NSDocument printInfo to printOp: printView will show up in printPanel preview but won't print
    // maybe because printView is not associated with an actual NSDocument
    
    NSPrintOperation *printOp = [NSPrintOperation printOperationWithView:printView];

    while ([myWebView isLoading]) {	[[NSRunLoop currentRunLoop] limitDateForMode:NSDefaultRunLoopMode];}

    [printOp runOperation];
    
    if (closeAfterPrinting) {
        [self removeFromBartender];
    }

    
// the rest of this is for modal print
//    
//    [printOp setShowsPrintPanel:showPanels];
//    
//    if (showPanels) {
//        // Add accessory view, if needed
//    }
//    
// 
//    
//    // Run operation, which shows the Print panel if showPanels was YES
//    
//    [self runModalPrintOperation:printOp
//                               delegate:self
//                         didRunSelector:@selector(documentDidRunModalPrintOperation:success:contextInfo:)
//                            contextInfo:NULL];
//    
   
}
//
//- (void)documentDidRunModalPrintOperation:(NSDocument *)document  success:(BOOL)success  contextInfo:(void *)contextInfo; {
//	
//	if (closeAfterPrinting) {
//        [self removeFromBartender];
//    }
//	
//}

// ***************************************************************************************
// ***************************************************************************************
// setters and getters 
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------


-(BarDocument *)bartender {return bartender;}

-(void)setBartender:(BarDocument *)bt { bartender = bt;}


-(BarExperiment *)theExperiment { return theExperiment; }


-(void)startWeighingInState:(int)weighingState WithTheExperiment: (BarExperiment *)newExpt; {
    
    currentState = weighingState;
    [self setTheExperiment:newExpt];

    
}

-(void)startEditingDailyDay:(NSInteger)dayIndex WithTheExperiment: (BarExperiment *)newExpt; {
    
    currentState = kUserEditing;
    editingDayIndex = dayIndex;
    [self setTheExperiment:newExpt];

}


- (void)setTheExperiment:(BarExperiment *)newExpt {
	// set the values in the new expt panel 
	// using the values in the given expt
		
	theExperiment = newExpt;
	
    // title window with expt code and "ON" or "OFF"
    // gets set even if theExperiment == nil
    [self updateWindowTitle];
    
	if (nil == theExperiment ) {
        return;
    }
		        
    // now that we have an experiment, 
    // we can load the onWeights/phase from disk (if weighing off bottles)
    // and set up all the columns for the items & other window elements in the experiment
    
     
    // DAILY DATA
    // 1. allocate daily data
    // 2. bind experiment
    // 3. load on weights or set current phase
    
    // set up our dailyData object
    if (nil == dailyData) { dailyData = [[DailyData alloc] init]; }
    
    [dailyData setTheExperiment:theExperiment]; // initializes the weight arrays too
    
    // set the weighing status appropriately...
    if ([theExperiment waitingForOff]) {
        [self setToOffWeights];
        // setToOffWeights read in previous on weights 
    }
    else if (currentState == kUserEditing){
        [self setToUserEditing];
        // setToOnWeights will set phase day appropriately
    }
    else {
        [self setToOnWeights];
        // setToOnWeights will set phase day appropriately        
    }
    
    // populate WINDOW ELEMENTS
    // 0. window title (updated above, even if theExperiment == nil)
    // 1. tableview with on/off weights
    // 2. experiment name label
    // 3. comment field
    // 4. onTimeLabel (if weighing off)
    // 5. phase menu & phase label

    
    // configure the window elements:
    // set up the table fields in our window
    [self setUpDailyTableViewColumns];
    
    // set the name of the experiment in the exptNameLabel
    [exptNameLabel setStringValue:[theExperiment codeName]];
    
    // set the text of the comment view...
	NSRange wholeRange  = NSMakeRange(0,[[commentView textStorage] length]);
	[[commentView textStorage] replaceCharactersInRange:wholeRange withString:[dailyData comment]];
	

    // set the onTimeLabel
    if (currentState == kWeighingOff) {
        [onTimeLabel setStringValue:[dailyData onTimeString]];
    }
    else if (currentState == kUserEditing) {
        [onTimeLabel setStringValue:[dailyData onTimeString]];
        [offTimeLabel setStringValue:[dailyData offTimeString]];        
    }
    
    // set up the expt phase menu...
    NSMenu *phaseMenu = [phasePopup menu];
    [theExperiment addPhaseNamesToMenu:phaseMenu];

    // update the phase menu and label
    [self updatePhaseMenuAndLabel];
    

}


-(void)setToOnWeights {
    
	currentState = kWeighingOn;
    
    [itemLabel setEnabled:YES];
    [itemWeight setEnabled:YES];

    // set the dailyData phase
    // if we are weighing on, then we should  set phase to the current phase of the experiment (and the currentPhaseDay + 1)
    

    // set the phase to the current phase of the experiment
    // get the last phase day recorded by the experiment
    // assuming we are now weighing this day, increment phase day by 1
    // note that if never collected data for this phase before, then dayOfPhaseOfName returns NSNotFound
        
    NSInteger exptPhaseDay = [theExperiment dayOfPhaseOfName:[theExperiment currentPhaseName]];
    
    if (nil != [theExperiment phaseWithName:[theExperiment currentPhaseName]]) {
        if (-1 == exptPhaseDay) { exptPhaseDay = 0; }
        else {  exptPhaseDay += 1 ; }
    }
    else {
        // if not a real phase (e.g. "<none>") then leave exptPhase day as NSNotFound
        exptPhaseDay = -1;
    }
    
    // update the daily data to reflect a new weighing on...
    if (nil != dailyData) {
        [dailyData setCurrentState: kWeighingOn];
        [dailyData setPhaseName:[theExperiment currentPhaseName]];
        [dailyData setPhaseDayIndex:exptPhaseDay];
    }
    

}


-(void)setToOffWeights {
	currentState = kWeighingOff;
    
    [itemLabel setEnabled:YES];
    [itemWeight setEnabled:YES];
    
	if (nil != dailyData) {
        
        [dailyData setCurrentState: kWeighingOff];
    
        //NOTE: LOAD ON WEIGHTS OF GIVEN EXPT NAME....
        // IF NO ON WEIGHTS and we're weighing OFF, post error...
        [dailyData readOnWeights];

          // set the dailyData phase
        // if we are weighing off, then we use the daily data phase and index loaded from the onweights file.

    }


}

-(void)setToUserEditing; {
	currentState = kUserEditing;
    
    [itemLabel setStringValue:@"editing mode"];
    [itemLabel setEnabled:NO];
    
    [itemWeight setStringValue:@"na"];
    [itemWeight setEnabled:NO];
    
    
    
	if (nil != dailyData) {
        
        dailyData = [theExperiment dailyDataForDay:(NSUInteger)editingDayIndex];
        
        [dailyData setCurrentState: kUserEditing];
              
    }
    
    
}

-(void)updateWindowTitle; {
	
	// assume the window is run by the first NSWindowController in the array of window controllers

    
	if ([self windowControllers]) {
		
		NSString *windowTitle;
		
		if (nil == theExperiment) {
		
			if (kWeighingOn == currentState) {
				windowTitle = @"Weighing ON";
			}
			else if (kWeighingOff == currentState) {
				windowTitle = @"Weighing OFF";
			}
            else if (kUserEditing == currentState) {
				windowTitle = @"Editing Daily Data";
			}

			else {
				windowTitle = @"Daily Data";
			}
		
		} // no expt
		
		else  {
			
			if (kWeighingOn == currentState) {
				windowTitle = [NSString stringWithFormat:@"%@ -- weighing ON", [theExperiment codeName]];
			}
			else if (kWeighingOff == currentState) {
				windowTitle = [NSString stringWithFormat:@"%@ -- weighing OFF", [theExperiment codeName]];
			}
            else if (kUserEditing == currentState) {
				windowTitle = [NSString stringWithFormat:@"%@ -- Editing", [theExperiment codeName]];
            }
			else {
				windowTitle = [theExperiment codeName];
				
			}
						
		} // expt specified
		
        NSWindowController *myWindowController;
		NSWindow *myWindow;
        
        myWindowController = (NSWindowController *)[[self windowControllers] objectAtIndex:0];
        myWindow = [myWindowController window];
		if (myWindow) { [myWindow setTitle:windowTitle]; }
		
	} // got window controllers
	

}


// ***************************************************************************************
// ***************************************************************************************
// override of NSDocument methods 
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------


-(void)saveDocument:(id)sender; {
	
	NSLog(@"method: saveDocument");
	
	[self save:sender];
	
}

//----------------------------------------------------------------------------------------

-(void)printDocument:(id)sender; {
	
	NSLog(@"method: printDocument");

	[self print:sender];
	
}

-(void)removeFromBartender; {
    
    if (nil != bartender) { [bartender removeDailyDataDocument:self]; }
}


// ***************************************************************************************
// ***************************************************************************************
// interface methods to handle toolbar button presses. 
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------


-(IBAction)open:(id)sender {  

}


-(IBAction)saveAndPrint:(id)sender {
	
	// pressing the save and Print button triggers closing...
	NSLog(@"method: saveAndPrint");
	
	
	// NOTE -- need to be called if the window is closed, or if "Quit" is selected...
	// disabled the close button, need to figure out quitting...
		
	// 1. check if there are still unweighed items
	// 2. give user option to continue weighing
	// 3. if OK to close, then save and print the dailyData
	// 4. call [self removeFromBartender] to let Bartender release the document, and call [NSDocument close]
	
	
	if (nil == theExperiment) { // nothing to save or print
		BCOneButtonAlert(	NSWarningAlertStyle,
					   @"Can't Save & Print: No experiment specified ",
					   @"Scan an item to start weighing", 
					   @"OK");		
		
		return; 
	}		

	// 1. check if there are still unweighed items
	// 2. give user option to continue weighing

	if ([dailyData numberOfUnweighedItems] != 0) {
		// some items have not yet be weighed
		
		// put up a dialog to confirm saving even though there are some unweighed items
		
       
        NSString *infoText = [[NSString alloc] initWithFormat:@"%ld items have not yet been weighed. Are you sure you want to save without weighing the remaining items?",[dailyData numberOfUnweighedItems]];
        

		NSInteger button = BCTwoButtonAlert(NSWarningAlertStyle,
									@"Save and Print Incomplete Weights?", 
									infoText, 
									@"Save and Print",
									@"Return to Weighing");
		
		if (button == NSAlertSecondButtonReturn) {
			// "Return to weighing" clicked, so go back to weighing without saving...
			return;
		}
		// else  (button == NSAlertFirstButtonReturn)
		// "Save and Print" clicked so continue with save
		
	} // check for unweighed items
	
	// 3. if OK to close, then save and print the dailyData
	
	[self save:self];
	
	closeAfterPrinting = YES;
	
	[self print:self];
	
	// 4. documentDidRunModalPrintOperation will call [self release the document..] to let Bartender handle the closing, and release the document..
		
}

-(IBAction)save:(id)sender {
	
	
	// save the weights into the Documents/Bartender/DailyData directory
	// On weights are stored in a file called "[ExptCode].onweights"
	// Off weights are stored in a file called "[ExptCode] year-month-day.weights", in which the date is the save date
	// i.e. if bottles in Expt TH were weighed on June 4, 2010 and weighed off June  5, 2010, 
	// then the weights are stored in the file "Documents/Bartender/DailyData/TH 2010-6-5.weights"
	// note that the format of both onweights and weights files are identical XML plists,
	// just that off weights in the .onweights file are set to NaN
	
	NSLog(@"DD Document method: save");
	
	if (nil == theExperiment) {
		
		BCOneButtonAlert(	NSWarningAlertStyle,
					   @"Can't Save: No experiment specified ",
					   @"Scan an item to start weighing", 
					   @"OK");		
		
		return; 
		
		
		
	}
	
	// be sure to extract the comment
    // retrieve the text of the comment view...
    [dailyData setComment:[NSString stringWithString:[[commentView textStorage] mutableString]]];
		
	[dailyData save];
	
	// tell ourselves that we have saved all changes
	
	[self updateChangeCount: NSChangeCleared];

}

-(IBAction)print:(id)sender {

	NSLog(@"method: print");
	if (nil == theExperiment) {
		
		BCOneButtonAlert(	NSWarningAlertStyle,
					   @"Can't Print: No experiment specified ",
					   @"Scan an item to start weighing", 
					   @"OK");		
		
		return; 
		
		
		
	}
	
	[self printShowingPrintPanel:YES];	
	
	
}

-(IBAction)setExptPhase:(id)sender; {
	
	// user has changed the phase...
	NSString * newPhaseName = [[phasePopup selectedItem] title];
	
	
	// check to make sure we changed phases?
	[dailyData setPhaseName : newPhaseName];
	
	if ([[dailyData phaseName] isEqualToString:@"<none>"]) {
		
		[dailyData setPhaseDayIndex:-1];
	}
	else {
		// get the last phase day recorded by the experiment
		// assuming we are now weighing this day, increment phase day by 1
		// note that if never collected data for this phase before, then dayOfPhaseOfName returns -1

		NSInteger exptPhaseDay = [theExperiment dayOfPhaseOfName:[dailyData phaseName]];
		if (-1 == exptPhaseDay) { exptPhaseDay = 0; }
	//	else {  exptPhaseDay += 1; } // don't need this!
		
		[dailyData setPhaseDayIndex:exptPhaseDay]; 
		
	}
	
	// set the  popup & phase day label to the current phase...
	
	[self updatePhaseMenuAndLabel];
		
}


-(void)updatePhaseMenuAndLabel; {
	
	// set the  popup & phase day label to the current phase...
	
	[phasePopup selectItemWithTitle: [dailyData phaseName]  ];

	if ([dailyData phaseDayIndex] > 0) {
		
		[phaseDayLabel setStringValue: [[NSString alloc] initWithFormat:@"Day %ld",[dailyData phaseDayIndex]+1]];
		// zero-indexed, so present as +1
		
	}
	else {
		[phaseDayLabel setStringValue: [[NSString alloc] initWithFormat:kNoDataCellText]];
	}
}


-(IBAction)abort:(id)sender {

	// end the weighing session without saving the data...
	// close and deallocate the NSDocument window...
	
	// put up a dialog to confirm the cancellation
	
	NSLog(@"DailyDocument: abort");
	
	// if we haven't been assigned an experiment, then we can cancel without checking
	
	if (nil != theExperiment) {
	
		NSInteger button = BCTwoButtonAlert(	NSWarningAlertStyle,
										@"Cancel weighing session?",
										@"Canceled weights will not be saved and cannot be restored.", 
										@"Return to Weighing",
										@"Abort without saving");		
		
		if (button == NSAlertFirstButtonReturn) {
			// "Return to weighing" clicked, so don't cancel
			
			return;

		}
		
		// "Abort without saving was clicked, so go ahead and close ourselves up
		
	}
    
    // tell oursevles that we have no changes to save because we canceled
    [self updateChangeCount: NSChangeCleared];
	
		
	//need to close and deallocate the NSDocument window...
	// have the NSDocument method handle this for us.
    NSLog(@"DailyDocument about to call close");

    [self removeFromBartender];

    NSLog(@"DailyDocument back from calling close");

}

-(IBAction)tare:(id)sender; {
	
	// toolbar button to tare the balance

	[[bartender balance] tare];

}

-(IBAction)carryOver:(id)sender; {
	
	// toolbar button to carry over yesterdays off weights to todays on weights
	
    if (kUserEditing == currentState) { return; }
        
	if (kWeighingOff == currentState) {
		
		BCOneButtonAlert(	NSWarningAlertStyle,
					   @"Can't Carry Over Data: Currently weighing off",
					   @"Can only carry over data when weighing data on", 
					   @"OK");		
		
		return; 

		
	}
	
	if (nil == theExperiment) {
		
		BCOneButtonAlert(	NSWarningAlertStyle,
					   @"Can't Carry Over Data: No experiment specified ",
					   @"Scan an item to start weighing on", 
					   @"OK");		
		
		return; 
		
	}
	
	DailyData *yesterdaysData = [theExperiment dailyDataForDay: ([theExperiment numberOfDays] - 1)];
	
	if (nil == yesterdaysData) {
		
		BCOneButtonAlert(	NSWarningAlertStyle,
									@"Can't Carry Over Data: No Prior Data",
									@"There are no previously collected data to carry over to today's weights", 
									@"OK");		
		
		return; 
		
	}

	
	NSUInteger itemIndex, ratIndex;
	double onWeight, offWeight,deltaWeight;
	
	NSUInteger numItems = [theExperiment numberOfItems];
	NSUInteger numRats = [theExperiment numberOfSubjects];
	
	for (itemIndex = 0; itemIndex < numItems; itemIndex++) {
		
		for (ratIndex = 0; ratIndex < numRats; ratIndex++) {
		
			if ([yesterdaysData getWeightsForRat:ratIndex andItem:itemIndex onWeight:&onWeight offWeight:&offWeight deltaWeight:&deltaWeight]) {

				// set today's onweights to yesterday's offweights
				[dailyData setOnWeightForRat:ratIndex andItem:itemIndex weight:offWeight];
				
			}
			
		} // next rat

	} // next item
	
	[dailyTableView reloadData];
	
	
}


// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
// interface methods for acquiring barcode and weight
///--------------------------------------------------------------------------------------------------

-(IBAction)labelStringEntered:(id)sender {
	
	NSUInteger ratIndex = 0, itemIndex = 0;
	
	
	NSLog(@"Label String Entered");
	
	// a string was entered into the itemLabelfield
	// parse the string to get expt code, rat number, and item type
	// then make a request for a weight from the balance...
	
	
	// the labelString is itemLabel's text...
	
	NSString *labelString = [itemLabel stringValue];
    
    if (nil == labelString || 0 == [labelString length]) {
        // no label entered, so just clear and return
 		// clear the itemLabel
		[itemLabel setStringValue:[NSString string]];
		return;
       
    }
	

	// parse the labelString
	// if this is the first item to be scanned, 
	// parseLabelString will try to match the experiment 
	// and setup the dailyData for that experiment
	if (![self parseLabelString:labelString getRatIndex:&ratIndex getItemIndex:&itemIndex ]) { 	
		
        // failed to parse, so just return
        
        // clear the item label...
        [itemLabel setStringValue:[NSString string]];
        // tell the label string to fade out...
 //       [itemLabel setAnimatedStringValue:[NSString string]];
//        [itemLabel setTextColor:[NSColor redColor]];
//        [itemLabel setNeedsDisplay];

        
		return;
	}

    // post a request to get the current weight on the scale
    scannedLabelString = [labelString copy];
    scannedRatIndex = ratIndex;
    scannedItemIndex = itemIndex;
    numWeightTries = 0;
    needWeightForItem = YES;
	
}

-(void) processWeightForScannedItem; {
    
    
	// check a number of times for weight, until weight is stable
	// if it fails to be stable within X number of tries, then post an alert that weight is not stable
    
    BOOL stable_weight_acquired = [[bartender balance] curr_weight_stable];
    
    if ( ! stable_weight_acquired) {
        
        numWeightTries++;
        if (kMaxNumWeightTries == numWeightTries) {
            // give up waiting for stable weight
            
            // clear the item label...
            [itemLabel setStringValue:[NSString string]];
            scannedLabelString = nil;
            needWeightForItem = NO;
            
            BCOneButtonAlert(	NSWarningAlertStyle,
                             @"Unstable Weight",
                             @"Balance could not read a stable weight. Please try item again.",
                             @"OK");
        }
        return;
    }
        
    // current weight is stable
    
    currentWeight = [[bartender balance]  curr_weight];
        
    // make a sound to notify the user that the weight was successfully read from balance
        
    NSBeep();
        
        
	// check for double entry or out of range weight
	[self checkWeightForLabel:scannedLabelString atItemIndex:scannedItemIndex];
	
    
	// set the appropriate weight
	if ([dailyData currentState] == kWeighingOn) {
		// currentWeight = 400 + (20 * itemIndex) + ratIndex;
		[dailyData setOnWeightForRat:scannedRatIndex andItem:scannedItemIndex weight:currentWeight];
	}
	
	else if ([dailyData currentState] == kWeighingOff) {
		// currentWeight = 400 + (20 * itemIndex) + ratIndex - (ratIndex * 2);
		[dailyData setOffWeightForRat:scannedRatIndex andItem:scannedItemIndex weight:currentWeight];
	}
    
	// NOTE: scroll to the right row in the table and highlite it...
	[self selectTableRowAtIndex:scannedRatIndex];
	
	
	// update the screen table with the new data...
	
	[dailyTableView reloadData];
	
	lastWeight = currentWeight;
	
    // set the last item label
    [lastItemLabel setStringValue:[[NSString alloc] initWithFormat:@"%@ %@", scannedLabelString, [[bartender balance] curr_weight_text]] ];
    
	// clear the item label...
	[itemLabel setStringValue:[NSString string]];
     
	
	// tell ourselves that a change has been made...
	[self updateChangeCount: NSChangeDone];
	
    // processing successful, so no longer waiting for a new weight
    scannedLabelString = nil;
    needWeightForItem = NO;
}

-(BOOL) parseLabelString:(NSString *)labelString getRatIndex:(NSUInteger *)ratIndex getItemIndex:(NSUInteger *)itemIndex  {
	
	//classic ProcessTag
	
	
	NSLog(@"method: parseLabelString");
	
	BarExperiment *matchExpt;	
	
	matchExpt = [bartender getExperimentFromLabel:labelString];
	
	
	// perform some checks on the experiment that matches the labels
	
//	1. is this a known experiment?
//	2. do we need to assign this experiment to the window (i.e. this is first label to be scanned)
//		2a. is this experiment already open in another window?
//		2b. are we trying to weigh on an experiment that has already been weighed on?
//		2c. are we trying to weigh off an experment that has not been weighed on?
//		2d. assign the matching experiment to this window
//	3. does the experiment match the currently assigned experiment?
	
		// classic MatchTag2Expt
	
	//	1. is this a known experiment?
	
	if (matchExpt == nil) {
		
		BCOneButtonAlert(	NSWarningAlertStyle,
										@"Unknown Experiment", 
										@"Did not recognize the experiment code within the label. Either the experiment has not been created yet, or the label is incorrect, or the label was not scanned properly.", 
										@"OK");		
		return NO;				
		
		
	}
	
	//	2. do we need to assign this experiment to the window (i.e. this is first label to be scanned)

	
	if ([self theExperiment] == nil ) {
		// then this is first label to be scanned...
		
		
		//	2a. is this experiment already open in another window?
		
		// NOTE: check if experiment already being weighed in another window...
		

		//	2b. are we trying to weigh on an experiment that has already been weighed on?

		
		// if weighing on, make sure there isn't already a ".onweights" file
		// if there is an ".onweights" file, ask if you want to overwrite it
		
		// if weighing off, make sure there IS a ".onweights" file
		
		BOOL onWeightsFileExists = [matchExpt onWeightsFileExists];
		
		if (kWeighingOn == currentState && onWeightsFileExists) {
			
			// trying to weigh bottles ON, but ".onweights" file already exists
			// so can't overwrite
						
			BCOneButtonAlert(NSWarningAlertStyle,
										@"Bottles already ON", 
										@"The bottles for this experiment have already been weighed ON", 
										@"OK");
			
			return NO;				
			
		}
		
		//	2c. are we trying to weigh off an experment that has not been weighed on?

		
		if (kWeighingOff == currentState && !onWeightsFileExists) {
			
			// trying to weigh bottles OFF, but ".onweights" file doesn't exist
			
			BCOneButtonAlert(NSWarningAlertStyle,
										@"Bottles can't be weighed OFF", 
										@"The bottles for this experiment have not been weighed ON, so they cannot be weighed OFF", 
										@"OK");
			
			return NO;				
			
		}
		
		
		//	2d. assign the matching experiment to this window

		
		// need to assign the experiment to use
		
		[self setTheExperiment:matchExpt];
		
		// setTheExperiment should set the currentStatus, which should cause old weights to be loaded...
        // and the proper phase to be set
  	
		
		
	}

	//	3. does the experiment match the currently assigned experiment?


	if ([self theExperiment] !=  matchExpt) {
		// we matched the label to an experiment, 
		// but its not the experiment we are currently assigned to

		BCOneButtonAlert(NSWarningAlertStyle,
									@"Mismatched Experiment", 
									@"The experiment code of the label does not match the experiment currently being weighed.", 
									@"OK");
		
		return NO;				

	}
	
	// if we got this far, then the expt matches our current experiment
	// go ahead and extract the ratIndex and itemIndex
	// we ask the experiment to parse these items, so that the experiment can do bounds checking on the values...
		
	if ([self theExperiment] == matchExpt) {
			
		// we've already set the experiment, 
		
		(*ratIndex) = [theExperiment subjectIndexFromLabel:labelString];
		if ( (*ratIndex) == NSNotFound) {
			// rat index is outside the range of rat numbers...
			
			
			BCOneButtonAlert(	NSWarningAlertStyle,
											@"Unknown Subject Number", 
											@"The number on the label is outside the range of subjects recognized by the experiment currently being weighed.", 
											@"OK");
						
			return NO;				
			
		}
	
		(*itemIndex) = [theExperiment itemIndexFromLabel:labelString];
		if ( (*itemIndex) == NSNotFound) {
			// item code is not recognized by the experiment..

			BCOneButtonAlert(NSWarningAlertStyle,
											@"Unknown Item Code", 
											@"The item code on the label is not recognized by the experiment currently being weighed.", 
											@"OK");
			return NO;				
			
		}
		
		// if we got this far, then matched the experiment code, rat index, and item code
							
		return YES;				

	}
	
	// just in case, default return is FALSE
	return NO;				
	
	
}

-(void) checkWeightForLabel:(NSString *)labelString atItemIndex:(NSUInteger)itemIndex; {
	
	BarItem *theItem = [theExperiment itemAtIndex:itemIndex];
	
	
	// warn if the weight was identical to to the last weight recorded
	if ( currentWeight == lastWeight) {
		
		NSString *alertText = [NSString stringWithFormat:@"Weight for %@ (%.2lf %@) is the same as preceding item: could be an erroneous double entry.", 
							   labelString,currentWeight,[theItem unit]];
		
		BCOneButtonAlert(NSWarningAlertStyle,@"Warning: Same Weight Recorded Twice", 
										alertText, 
										@"OK");
		
	}
	
	
	// make sure the weight is within the apropriate range...
	if (! ([theItem minWeight] <=  currentWeight
		&& currentWeight <= [theItem maxWeight]) ) {
		
		NSString *alertText = [NSString stringWithFormat:@"%@ items should be between %.2lf and %.2lf %@", 
							   [theItem name],[theItem minWeight],[theItem maxWeight],[theItem unit]];
		
		BCOneButtonAlert(NSWarningAlertStyle,
									@"Warning: Weight Outside Valid Range", 
										alertText, 
										@"OK");
		
	}
	
}

-(void)selectTableRowAtIndex:(NSUInteger)ratIndex {
		
	NSRange ratRange;
	
	ratRange.location = ratIndex;
	ratRange.length = 1;
	
	NSIndexSet* indexSet = [[NSIndexSet alloc ] initWithIndexesInRange:ratRange];
	
	[dailyTableView selectRowIndexes:indexSet byExtendingSelection:NO];
	
	[dailyTableView scrollRowToVisible:(NSInteger)ratIndex];
}




-(void)updateWeightDisplay:(NSNotification*) note; {
    
   // [note object] should be the BarBalance object...
    
    if (kUserEditing == currentState) { return; }
	
	// update the weight on display
	
//    NSString *weight_text = [[bartender balance] curr_weight_text];
//   [itemWeight setStringValue: weight_text];

    [itemWeight setStringValue: [[bartender balance] curr_weight_text]];
    
    if (needWeightForItem) {
        
        [self processWeightForScannedItem];
        
    }

}


// ***************************************************************************************
// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
/// Time Methods
///--------------------------------------------------------------------------------------------------


-(void)setOnTime:(NSDate *)date; {
	
	[dailyData setOnTime: date];
	
	if (nil != date) {
		[onTimeLabel setStringValue: [dailyData onTimeString]];
	}
	else { [onTimeLabel setStringValue:nil]; }

}

-(void)setOffTime:(NSDate *)date; {
	
	[dailyData setOffTime: date];
	
	if (nil != date) {
		[offTimeLabel setStringValue: [dailyData offTimeString]];
	}
	else { [offTimeLabel setStringValue:nil]; }
	
}



// ***************************************************************************************
// ***************************************************************************************
// Methods for getting Table Text for display in NSTableView dailyTableView
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------


-(NSString *) getItemNameFromTableHeader:(NSString *)header {
	
	// get array of strings from header, separated by space
	// first item in the array will be the itemName
	// second item in the array is the itemTerm string ("On", "Off", or "∆")
	
	NSArray *listItems = [header componentsSeparatedByString:@" "];
	
	// NOTE -- this will crash if there is a space in the name of the Item!!!!
	
	
	if ([listItems count] >= 2) return (NSString*)[listItems objectAtIndex:0];
	
	return nil;
}


-(NSUInteger) getItemTermFromTableHeader:(NSString *)header {
	
	NSString *itemTermString;
	
	NSArray *listItems = [header componentsSeparatedByString:@" "];
	
	if ([listItems count] >= 2) { itemTermString =  (NSString *)[listItems objectAtIndex:([listItems count] - 1)]; }
	
	
	
	if ([itemTermString compare:@"On"] == NSOrderedSame) {
		
		return kWeightOn;
		
	}
	else if ([itemTermString compare:@"Off"]== NSOrderedSame) {
		
		return kWeightOff;
		
	}
	else if ([itemTermString compare:@"∆"]== NSOrderedSame) {
		
		return kWeightDelta;
		
	}

	// didn't match any of the terms, so return unknown..
	return kWeightUnknownTerm;
	
	
}

// ***************************************************************************************
// ***************************************************************************************
// NSTableView datasource methods
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------

// In Bartender, the table columns are:
// "Subject" ID, e.g. "AP001"
// "Group" name, e.g. "control"
// a set of item columns, for e.g. "Saccharin", "Water", and "Food"
// for each item, there are 3 columns -- "Item On", "Item Off", "Item delta" 
// optionally there can be another 2 columns:
// "Preference"
// "Total"


-(NSTableView *)dailyTableView { return dailyTableView; }


-(void) addDailyTableViewColumnWithIdentifier:(NSString *)identifier editable:(BOOL)flag; {
	
	NSTableColumn *tableColumn;
	
#define DEFAULT_COLUMN_WIDTH 60
#define DEFAULT_SUBJECT_COLUMN_WIDTH 75
#define DEFAULT_GROUP_COLUMN_WIDTH 50
#define BLANK_COLUMN_WIDTH 10

	
	tableColumn = [[NSTableColumn alloc] initWithIdentifier:identifier];
	
	[[tableColumn headerCell] setStringValue:identifier];
	
	[tableColumn setHidden:NO];
	[tableColumn setWidth:DEFAULT_COLUMN_WIDTH];
	[tableColumn setEditable:flag];
	
	// add the table column to the dailyTableView
	[dailyTableView addTableColumn:tableColumn];
	
	
}

static int numBlankColumns=0;

-(void)addBlankColumnToDailyTableView; {
	
	NSTableColumn *tableColumn;
	
	tableColumn = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"Blank%d",numBlankColumns]];
	
	[[tableColumn headerCell] setStringValue:[NSString string]];
	
	[tableColumn setHidden:NO];
	[tableColumn setWidth:BLANK_COLUMN_WIDTH];
	[tableColumn setEditable:NO];
	
	// add the table column to the dailyTableView
	[dailyTableView addTableColumn:tableColumn];
	
	numBlankColumns++;
	
	
}


-(void) setUpDailyTableViewColumns {

	// set up the columns
	// In Bartender, the table columns are:
	// "Subject" ID, e.g. "AP001"
	// "Group" name, e.g. "control"	for (index = 1; index< [columns count]; index++) {
	

	// a set of item columns, for e.g. "Saccharin", "Water", and "Food"
	// for each item, there are 3 columns -- "Item On", "Item Off", "Item delta" 
	// optionally there can be another column:
	// "Preference"
	
	
	
	NSUInteger itemIndex;
	NSString *onIdentifier, *offIdentifier, *deltaIdentifier, *preferenceIdentifier, *totalIdentifier;
	NSString *itemName;
	NSTableColumn *tableColumn;
	
	
	if (theExperiment == nil) return;
	// don't set up table if experiment is not specified
	
	// the dailyTableView table, as created in the nib file, already has Subject and Group columns...
	
	// NOTE: make sure the subject and group columns have a width of 100
	
	tableColumn= [dailyTableView tableColumnWithIdentifier:@"Subject"];
	[tableColumn setWidth:DEFAULT_SUBJECT_COLUMN_WIDTH];
	[tableColumn setEditable:NO];
	tableColumn= [dailyTableView tableColumnWithIdentifier:@"Group"];
	[tableColumn setWidth:DEFAULT_GROUP_COLUMN_WIDTH];
	[tableColumn setEditable:NO];
	
	
	// create and add the total & preference column
	

	if (([dailyData currentState] == kWeighingOff || [dailyData currentState] == kUserEditing)  && [theExperiment hasPreference]) {
		
		[self addBlankColumnToDailyTableView]; // spacer column

		preferenceIdentifier = @"Pref";
		[self addDailyTableViewColumnWithIdentifier:preferenceIdentifier editable:NO];
        
        totalIdentifier = @"Total";
		[self addDailyTableViewColumnWithIdentifier:totalIdentifier editable:NO];

	}

	for (itemIndex = 0; itemIndex < [theExperiment numberOfItems]; itemIndex++) {
	
		// add  three columns for this item,
		// named "Item On", "Item Off", and "Item ∆" (option-J)
	
		itemName = [[theExperiment itemAtIndex:itemIndex] name];
		
		onIdentifier	=	[itemName stringByAppendingString:@" On"];
		offIdentifier	=	[itemName stringByAppendingString:@" Off"];
		deltaIdentifier =	[itemName stringByAppendingString:@" ∆"];
				
		
		// now that we have the names of the columns, 
		// create columns and add them to the table view
		
		[self addBlankColumnToDailyTableView]; // spacer column
			
		[self addDailyTableViewColumnWithIdentifier:onIdentifier editable:YES];
		
		if ([dailyData currentState] == kWeighingOff || [dailyData currentState] == kUserEditing)  {
			[self addDailyTableViewColumnWithIdentifier:offIdentifier editable:YES];
			[self addDailyTableViewColumnWithIdentifier:deltaIdentifier editable:NO];
		}
		
	} // next Item
		
	
	// adding columns means that the daily view needs to be updated...
	[dailyTableView reloadData];
	
}


// Getting Values for the table

-(NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	
		
	if (theExperiment == nil) return 0;
	
	NSInteger numberOfRows =  (NSInteger)[theExperiment numberOfSubjects];
	
	return numberOfRows;
	
	
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	
	// In Bartender, the table columns are:
	// "Subject" ID, e.g. "AP001"
	// "Group" name, e.g. "control"
	// a set of item columns, for e.g. "Saccharin", "Water", and "Food"
	// for each item, there are 3 columns -- "Item On", "Item Off", "Item delta" 
	// optionally there can be another column:
	// "Preference"
    
  //  NSLog(@"tableView objectValueForTableColumn:");
	
	NSString *identifier = [aTableColumn identifier];
	NSString *objectValue;
	
	if (theExperiment == nil) return nil;
	
	if ([identifier isEqualToString:@"Subject"]) {
		
		objectValue = [theExperiment nameOfSubjectAtIndex:(NSUInteger)rowIndex];
		return objectValue;
	}
	else if ([identifier isEqualToString:@"Group"]) {
		//return @"Group";
		
		// objectValue =  [theExperiment nameOfGroupOfSubjectAtIndex:rowIndex];
		objectValue =  [theExperiment codeOfGroupOfSubjectAtIndex:(NSUInteger)rowIndex];

		return objectValue;
	}
	else if ([identifier isEqualToString:@"Total"]) {
		objectValue =  [dailyData getTotalTextForRat:(NSUInteger)rowIndex];
		return objectValue;
	}
	else if ([identifier isEqualToString:@"Pref"]) {
		objectValue =  [dailyData getPreferenceScoreTextForRat:(NSUInteger)rowIndex];
		return objectValue;
	}
	else if ([identifier hasPrefix:@"Blank"]) {
		
		// ignore blank columns
		
	}
	else {
		
		// if it's not the subject or group name, it must be one of the item columns...
		// item columns are "ItemName On", "ItemName Off", "ItemName delta", or "Total" or "Preference"
		// From the identifier, we need to parse "ItemName" to get the item, 
		// and then determine if it's the column with the on, off, or delta terms.
		// NOTE: could do something fancy and put everything in the cell, e.g., "456 - 412 = 44g"
				
		NSString *itemName = [self getItemNameFromTableHeader:identifier];
		NSUInteger itemTerm =  [self getItemTermFromTableHeader:identifier];
		
		objectValue = [dailyData getTextForItem:itemName atTerm:itemTerm forRat:(NSUInteger)rowIndex];
		return objectValue;
	
	}
	
	return nil;
	
}


// Setting Values
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	
	
	// extract a new weight from the object value
	// row is the subject index
	// determine if its the on weight or off weight column
	// find the item with the given name from the identifier
	// set the item's on or off weight to that weight 
	
	
	// only thing that gets edited is the weight
	// but interpret "--" as a missing weight

	// NOTE: double check that anObject is a string...
	double weight;
	
	if ([anObject isEqualToString:kNoDataCellText]) { weight = MISSINGWGT; }
	
	else { weight = [anObject doubleValue];	}
	
	
	NSString *identifier = [aTableColumn identifier];
	
	if ( [identifier hasSuffix:@" On"]) {
				
		NSArray *subStrings = [identifier componentsSeparatedByString:@" On"];
		
		if (0 < [subStrings count]) {
			// don't want to think about a column name like "Saccharin On Cage On"
			
			NSString *itemName = [subStrings objectAtIndex:0];
			
			NSUInteger itemIndex = [theExperiment itemIndexFromName:itemName];
			
			[dailyData setOnWeightForRat:(NSUInteger)rowIndex andItem:itemIndex weight:weight];

		}
	}
	
	else if  ( [identifier hasSuffix:@" Off"]) {
		
		NSArray *subStrings = [identifier componentsSeparatedByString:@" Off"];
		
		if (0 < [subStrings count]) {
			// don't want to think about a column name line "Saccharin Off Cage Off"
			
			NSString *itemName = [subStrings objectAtIndex:0];
			
			NSUInteger itemIndex = [theExperiment itemIndexFromName:itemName];
			
			[dailyData setOffWeightForRat:(NSUInteger)rowIndex andItem:itemIndex weight:weight];
			
		}
		
	}
	
}


//Dragging
//– tableView:acceptDrop:row:dropOperation:  
//– tableView:namesOfPromisedFilesDroppedAtDestination:forDraggedRowsWithIndexes:  
//– tableView:validateDrop:proposedRow:proposedDropOperation:  
//– tableView:writeRowsWithIndexes:toPasteboard:

// Sorting
//– tableView:sortDescriptorsDidChange:  




@end

