#import "ExptInfoController.h"
#import "BarExperiment.h"
#import "DailyData.h"
#import "BarDocument.h"
#import	"BarSubject.h"
#import	"BarItem.h"
#import "BarGroup.h"
#import "BarDrug.h"
#import	"BarPhase.h"
#import "BarDirectories.h"
#import "DailyDataDocument.h"

#import "BCBarcodeLabelsWebView.h"
#import "Bartender_Constants.h"

@implementation ExptInfoController

-(id)init {
    self = [super initWithWindowNibName:@"ExptInfoWindow"];
    if (self) {
		
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		[exptNameView setStringValue:@"Untitled"];
		[exptCodeView setStringValue:@"AA"]; 
		
		NSLog(@"ExptInfoController initialized");
    }
    return self;
}

-(void)awakeFromNib {
    [dailyDataTableView setTarget:self];
    [dailyDataTableView setDoubleAction:@selector(handleDailyDataDoubleClick:)];
}

-(void)setBartender:(BarDocument *)newBartender {
	
	// we are created and destroyed by a BarDocument
	
	bartender = newBartender;
	NSLog(@"bartender set");
	
}


- (IBAction)cancelButtonPressed:(id)sender {
	
	// NOTE -- need to implement this as a real cancel button...
	
		// user cancelled, so just close the window without creating a new expt
    
        // user cancelled, so do NOT copy edited fields back into originalExperiment
        // instead, just let theExperiment get released when we're closed...
        originalExperiment = nil;
        theExperiment = nil;
	
		NSLog(@"ExptInfo Cancel Button pressed");
		
		[[self window] performClose:self];
	
		// as a window controller, we need to be closed by our owner...
	
		[bartender closeExptInfo:self andSaveExpt:NO];
	

	}
	


// global buttons
- (IBAction)saveButtonPressed:(id)sender {
	
	NSLog(@" ExptInfo Save Button pressed");
    
    // replace the data of original experiment with the edited fields of theExperiment
    
//    [originalExperiment resetToExperiment:theExperiment];
//    theExperiment = nil;

	
	// NOTE: post warning if new experiment of same name?
	// NOTE: check for required attributes of experiment? i.e. CODE, at least 1 item?
	
	[[self window] performClose:self];
	
	// as a window controller, we need to be closed by our owner...
	
	[bartender closeExptInfo:self andSaveExpt:YES];
		


}

- (IBAction)saveTemplateButtonPressed:(id)sender {
	
	NSLog(@" ExptInfo Save Template Button pressed");
	

	NSSavePanel *savePanel;
	NSInteger result;
	
	/* create or get the shared instance of NSSavePanel */
	savePanel = [NSSavePanel savePanel];
	
	/* set up new attributes */
	[savePanel setAllowedFileTypes:[NSArray arrayWithObjects:@"bartemplate",nil]];
	
	// set to the template directory
	
	NSString *templateDirectoryPath = GetTemplateDirectoryPath();
	
	// NSString *templateFilePath = [[templateDirectoryPath stringByAppendingPathComponent:templateName] stringByAppendingPathExtension:@"bartemplate"];
	
	NSURL * templateDirectoryURL = [NSURL fileURLWithPath:templateDirectoryPath] ;
	[savePanel setDirectoryURL:templateDirectoryURL ];
	
	
	/*prompt */
	[savePanel setPrompt:@"Save Bartender Template As:"];
	
	/* set the suggested file name */
	NSString *fileName = [NSString stringWithFormat:@"%@ Template.bartemplate",[theExperiment code]];
	
	[savePanel setNameFieldStringValue:fileName];
	
	/* display the NSSavePanel */
	result = [savePanel runModal];
	
    if (result == NSModalResponseOK) {
	
		NSString *myFilePath = [[savePanel filename] copy];
			
		// update the experiment from the expt info window
		[self getExperiment];
			
		// save the experiment, but as a template...	
		[theExperiment saveToPath:myFilePath];
		
		
		[[self window] performClose:self];
		
		// as a window controller, we need to be closed by our owner...
		
		[bartender closeExptInfo:self andSaveExpt:NO];
		
		NSLog(@"Should have called closeExptInfo");
	}
	
	
}

- (IBAction)applyTemplateButtonPressed:(id)sender {
	
	// apply template to the experiment being edited...

	NSInteger result;
	
	
	NSLog(@" ExptInfo Apply Template Button pressed");
	
	// choose a template
		
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setPrompt:@"Select Bartender Template:"];
	
	// set to the template directory

	NSString *templateDirectoryPath = GetTemplateDirectoryPath();
	
	NSURL * templateDirectoryURL = [NSURL fileURLWithPath:templateDirectoryPath] ;
	
	[openPanel setDirectoryURL: templateDirectoryURL];
		
	[openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"bartemplate",nil]];
			
	[openPanel setAllowsMultipleSelection:NO];
	
	result = [openPanel runModal];
			  
    if (result == NSModalResponseOK) {
		
		// load & apply the template experiment to current experiment
		
		NSString *templateFilePath = [[openPanel filenames] objectAtIndex:0];
		
		[theExperiment loadFromTemplatePath:templateFilePath];
		
		// reset the exptInfo window
		
		[self loadTheExpt];
		
	}
	
}


- (void)setTheExperiment:(BarExperiment *)newExpt {
	// set the values in the new expt panel 
	// using the values in the given expt
	
    originalExperiment = newExpt;
//    theExperiment = [originalExperiment copy];
    
	theExperiment = newExpt;
    
	[self loadTheExpt];
 
        numDataDays = [theExperiment numberOfDays];
         // load all daily data into memory
        dailyDataArray = [NSMutableArray arrayWithCapacity: numDataDays];
        for (NSUInteger d=0;d< numDataDays; d++ )  {
            [dailyDataArray addObject: [theExperiment dailyDataForDay:d]];
        }
   
			
}


-(void) windowDidLoad {
	
	
	[self loadTheExpt];
	
	
}

-(void) loadTheExpt {

	// populate the info tab view
	[exptNameView setStringValue:[theExperiment name]];
	[exptCodeView setStringValue: [theExperiment code]];
	[exptInvestigatorsView setStringValue: [theExperiment investigators]];
	[exptProtocolView setStringValue: [theExperiment protocol]];
    [exptWikiView setStringValue: [theExperiment wiki]];

	[exptProjCodeView setStringValue: [theExperiment project_code]];
    [exptProjNameView setStringValue: [theExperiment project_name]];

	[exptSubjectsView setIntegerValue: (NSInteger)[theExperiment numberOfSubjects]];

	
	// set the text of the description view...	 
	NSRange wholeRange  = NSMakeRange(0,[[exptSummaryView textStorage] length]);
	[[exptSummaryView textStorage] replaceCharactersInRange:wholeRange withString:[theExperiment description]];
	
	
	// populate the info tab view
	
	// set the preference values...
	
	[calcPreference setState:[theExperiment hasPreference]];
	[self setItemPopupMenus];
	[prefTypes selectCellAtRow:[theExperiment usePreferenceOverTotal] column:0];
	
	[self setGroupPopupMenu];
	[self setPhasePopupMenu];

	[itemsTableView reloadData];
	[groupsTableView reloadData];
    [drugsTableView reloadData];
	[phasesTableView reloadData];
	[subjectsTableView reloadData];
	[dailyDataTableView reloadData];
    
	// set the back up data path
 
     NSString *backupSummaryPath = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderLocalBackupDirectoryKey];
    
	
    [backupSummaryPathView setStringValue:backupSummaryPath];

}

-(void)addItemsToMenu:(NSMenu *)itemMenu; {
	
	
	
	BarItem *theItem;
	NSString *itemName;
	NSMenuItem *itemNameItem;
	
	NSArray *itemsForMenu = [theExperiment items];	
	
	// clear out the menu
	[itemMenu removeAllItems];
	
	
	if (0 == [itemsForMenu count]) {
		
		itemNameItem = [[NSMenuItem alloc] initWithTitle:@"<none>" action:NULL keyEquivalent:[NSString string]];
		// default "no-item" menu item with default action & no key equivalent
		
		// add the menu item to  the menu
		[itemMenu addItem:itemNameItem];
	}
	
	else {
		
		for (theItem in itemsForMenu) {
			
			// only include item if it is one of the desired types of item, based on flags...
			itemName = [[NSString alloc] initWithString:[theItem name]];
			
			itemNameItem = [[NSMenuItem alloc] initWithTitle:itemName action:NULL keyEquivalent:[NSString string]];
			// menu item with default action & no key equivalent
			
			// add the menu item to  the menu
			[itemMenu addItem:itemNameItem];
			
			
		} // added all the items
		
	}
	
	// all the items have been added, now we can return 
}


-(void)setItemPopupMenus; {
	
	if ( prefItemPopupMenu != nil && refItemPopupMenu != nil) {
		
		NSMenu *itemMenu;
		
		itemMenu = [prefItemPopupMenu menu];
		[self addItemsToMenu:itemMenu];
		
		itemMenu = [refItemPopupMenu menu];
		[self addItemsToMenu:itemMenu];
				
		if ([theExperiment numberOfItems] > 0) {
			
			if ([theExperiment prefItemIndex ] <= [theExperiment numberOfItems]) {
				[prefItemPopupMenu selectItemAtIndex:(NSInteger)[theExperiment prefItemIndex ]];
			}
			else {[prefItemPopupMenu selectItemAtIndex:0]; }
			
			if ([theExperiment baseItemIndex ] <= [theExperiment numberOfItems]) {
				[refItemPopupMenu selectItemAtIndex:(NSInteger)[theExperiment baseItemIndex ]];
			}
			else { [refItemPopupMenu selectItemAtIndex:0]; }
			
		}
	}
	
	
}

-(void)setGroupPopupMenu; {

    groupPopupMenu = [[NSPopUpButtonCell alloc] initTextCell:@"" pullsDown:NO];
    // make sure to specify pullsDown:NO for use in a NSTableView!!!
    [groupPopupMenu setBordered:NO];
    [groupPopupMenu setEditable:YES];
    [groupPopupMenu setTarget:self];
    [groupPopupMenu setAutoenablesItems:YES];
 //   [groupPopupMenu setAltersStateOfSelectedItem: NO];
    
    NSMutableArray *groupNames = [[NSMutableArray alloc] init];
   
    for (BarGroup *theGroup in [theExperiment groups]) {
        NSLog(@"Adding group name: %@",[theGroup name]);
        [groupNames addObject: [theGroup name]];
    }

    [groupPopupMenu addItemsWithTitles:groupNames];
    
//    for (NSString *name in groupNames) {
//        NSMenuItem *theItem = [groupPopupMenu itemWithTitle:name];
//        [theItem setHidden:NO];
//        [theItem setEnabled:YES];
//    }
    
    [[subjectsTableView tableColumnWithIdentifier:@"groupName"] setDataCell:groupPopupMenu];

    [subjectsTableView reloadData];

}
-(void)setPhasePopupMenu; {
    
    phasePopupMenu = [[NSPopUpButtonCell alloc] initTextCell:@"" pullsDown:NO];
    // make sure to specify pullsDown:NO for use in a NSTableView!!!
    [phasePopupMenu setBordered:NO];
    [phasePopupMenu setEditable:YES];
    [phasePopupMenu setTarget:self];
    [phasePopupMenu setAutoenablesItems:YES];
    //   [phasePopupMenu setAltersStateOfSelectedItem: NO];
    
    NSMutableArray *phaseNames = [[NSMutableArray alloc] init];
    
    for (BarPhase *thePhase in [theExperiment phases]) {
        NSLog(@"Adding phase name: %@",[thePhase name]);
        [phaseNames addObject: [thePhase name]];
    }
    
    [phasePopupMenu addItemsWithTitles:phaseNames];
    
    [[dailyDataTableView tableColumnWithIdentifier:@"phaseName"] setDataCell:phasePopupMenu];
    
    [dailyDataTableView reloadData];
    
}

 - (BarExperiment *)getExperiment {
	 
	 // set up the experiment using the  values in the new expt panel and 

	 [theExperiment setName:[exptNameView stringValue]];
	 [theExperiment setCode:[exptCodeView stringValue]];
	 [theExperiment setInvestigators:[exptInvestigatorsView stringValue]];
	 [theExperiment setProtocol:[exptProtocolView stringValue]];
     [theExperiment setWiki:[exptWikiView stringValue]];

	 [theExperiment setProjectCode:[exptProjCodeView stringValue]];
     [theExperiment setProjectName:[exptProjNameView stringValue]];

	 [theExperiment setNumberOfSubjects: (NSUInteger)[exptSubjectsView integerValue]];

	 
	 // retrieve the text of the description view...	 
	 [theExperiment setDescription:[NSString stringWithString:[[exptSummaryView textStorage] mutableString]]];
	 
	 	 
	 // item view
	 
	 // get preferences...
	 [theExperiment setHasPreference: (BOOL)[calcPreference state]];

	 [theExperiment setPreferenceIndexofItem:(NSUInteger)[prefItemPopupMenu indexOfSelectedItem]
									overItem:(NSUInteger)[refItemPopupMenu indexOfSelectedItem]];
	 
	 [theExperiment setUsePreferenceOverTotal: (BOOL)[prefTypes selectedRow] ];
	 
  //    [theExperiment setBackupSummaryPath:[backupSummaryPathView stringValue]];
	 
	 
	 return theExperiment;
		
 }


// tab specific buttons

// expt code

-(IBAction)exptCodeEdited:(id)sender; {
	
	[theExperiment setCode:[exptCodeView stringValue]];
	[subjectsTableView reloadData];
	
}


// items

- (IBAction)addItem:(id)sender {
	NSLog(@" ExptInfo Add Item Button pressed");
	
	[theExperiment addNewItem];
	[itemsTableView reloadData];
	
	[self setItemPopupMenus];
	

}

- (IBAction)deleteItem:(id)sender {
	NSLog(@" ExptInfo Delete Item  pressed");

	NSInteger selectedItemIndex = [itemsTableView selectedRow];
	if (selectedItemIndex == -1) return; // no selection
	//otherwise last row selected
	
	[theExperiment deleteItemAtIndex:(NSUInteger)selectedItemIndex];
	[itemsTableView reloadData];
	
	[self setItemPopupMenus];

}


- (IBAction)addGroup:(id)sender {
	NSLog(@" ExptInfo Add Group Button pressed");
	
	[theExperiment addNewGroup];
	[groupsTableView reloadData];
    
    //have to update group listings in subject table too
    [self setGroupPopupMenu];
	[subjectsTableView reloadData];
	

}

- (IBAction)deleteGroup:(id)sender {
	NSLog(@" ExptInfo Delete Group  pressed");
	
	
	NSInteger selectedGroupIndex = [groupsTableView selectedRow];
	if (selectedGroupIndex == -1) return; // no selection
	//otherwise last row selected
	
	[theExperiment deleteGroupAtIndex:(NSUInteger)selectedGroupIndex];
	[groupsTableView reloadData];
	
    //have to update group listings in subject table too
    [self setGroupPopupMenu];
	[subjectsTableView reloadData];


}

- (IBAction)addDrug:(id)sender {
    NSLog(@" ExptInfo Add Drug Button pressed");

    [theExperiment addNewDrug];
    [drugsTableView reloadData];

}

- (IBAction)deleteDrug:(id)sender {
    NSLog(@" ExptInfo Delete Drug  pressed");


    NSInteger selectedDrugIndex = [drugsTableView selectedRow];
    if (selectedDrugIndex == -1) return; // no selection
    //otherwise last row selected

    [theExperiment deleteDrugAtIndex:(NSUInteger)selectedDrugIndex];
    [drugsTableView reloadData];



}
// SUBJECTS *********************************************************************

-(IBAction)numberOfSubjectsChanged:(id)sender {
	
	NSLog(@" number of Subjects Changed...");
	
	[theExperiment setNumberOfSubjects: (NSUInteger)[exptSubjectsView integerValue]];
	[subjectsTableView reloadData];
	
}



- (IBAction)assignGroupsAlternating:(id)sender {
	
	NSLog(@" assign Groups Alternating Button pressed");
	
	[theExperiment setAlternatingGroups];
	[subjectsTableView reloadData];
	
}

- (IBAction)assignGroupsBlocks:(id)sender {
	
	NSLog(@" assign Groups Blocks Button pressed");
	
	[theExperiment setBlockGroups];
	[subjectsTableView reloadData];


}

- (IBAction)printBarcodeLabels:(id)sender; {
            
        //   If you want users to be able to print a document, you must override printOperationWithSettings: error:, possibly providing a modified NSPrintInfo object.
        
        // get page size from [self printInfo]
        //	NSRect paperRect = NSMakeRect(0,0,[[self printInfo] paperSize].width, [[self printInfo] paperSize].height);
        
        // Obtain a custom view that will be printed
        //    NSView *printView = [[BCDailyDataWebView alloc] initWithDailyData:dailyData andTable:dailyTableView];
    
    // put all the item codes into an array
    NSMutableArray *itemCodes = [[NSMutableArray alloc] init];
    
    for (BarItem *theItem in [theExperiment items]) {
        
        [itemCodes addObject:[theItem code]];
        
    }

    BCBarcodeLabelsWebView *myWebView = [[BCBarcodeLabelsWebView alloc]
                                         initWithExptCode:[theExperiment code]
                                         andItemCodes:itemCodes
                                         forSubjectsCount:[theExperiment numberOfSubjects]];
    
        
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

// PHASES *********************************************************************


- (IBAction)addPhase:(id)sender {
	
	NSLog(@" ExptInfo Add Phase Button pressed");

	[theExperiment addNewPhase];
	[phasesTableView reloadData];
	
}

- (IBAction)deletePhase:(id)sender {
	NSLog(@" ExptInfo Delete Phase  pressed");
	
	
	NSInteger selectedPhaseIndex = [phasesTableView selectedRow];
	if (selectedPhaseIndex == -1) return; // no selection
	//otherwise last row selected
	
	[theExperiment deletePhaseAtIndex:(NSUInteger)selectedPhaseIndex];
	[phasesTableView reloadData];
	

}


// ***************************************************************************************
// ***************************************************************************************
// Methods for getting Table Text for display in NSTableView dailyView
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------


// Getting Values for the table

-(NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	
	if (theExperiment == nil) return 0;
	
	if (aTableView == itemsTableView) return( (NSInteger)[theExperiment numberOfItems] );
	else if (aTableView == groupsTableView) return( (NSInteger)[theExperiment numberOfGroups] );
    else if (aTableView == drugsTableView) return( (NSInteger)[theExperiment numberOfDrugs] );

	else if (aTableView == phasesTableView) return( (NSInteger)[theExperiment numberOfPhases] );
	else if (aTableView == subjectsTableView)	return( (NSInteger)[theExperiment numberOfSubjects] );
	else if (aTableView == dailyDataTableView)	return( (NSInteger)[theExperiment numberOfDays] );
	
	return 0;
	
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	
	// should be able to use the identifier to get the value pretty directly...
	
	NSObject *objectAtIndex = nil;
	NSString *identifier = [aTableColumn identifier];
	
	
	if (theExperiment == nil) return nil;
	
	if (aTableView == subjectsTableView)	{
		
  	}
    else if (aTableView == dailyDataTableView)	{
        
        DailyData *theDay = [dailyDataArray objectAtIndex:(NSUInteger)rowIndex];

        if ([identifier compare:@"dayIndex"] == NSOrderedSame) {
             return [NSNumber numberWithLong:(rowIndex+1)];
        }
        else if ([identifier compare:@"onTime"] == NSOrderedSame) {
            return [theDay shortTimeStringFromDate:[theDay onTime]];
        }
        else if ([identifier compare:@"offTime"] == NSOrderedSame) {
            return [theDay shortTimeStringFromDate:[theDay offTime]];
        }
        else if ([identifier isEqualToString:@"phaseName"]) {
             
            // return the  menu index of the daily data's phase
            NSString *phaseName = [theDay phaseName];
            NSInteger itemIndex = [[aTableColumn dataCell] indexOfItemWithTitle:phaseName];
            
            return [NSNumber numberWithLong:itemIndex];
            
            // try returning the pop menu
            // [groupPopupMenu selectItemAtIndex:[theExperiment indexOfGroupOfSubjectAtIndex:rowIndex]];
            //  return groupPopupMenu;
            
        }
        else if ([identifier compare:@"phaseDay"] == NSOrderedSame) {
            return [NSNumber numberWithLong:[theDay phaseDayIndex]];
        }
        else if ([identifier compare:@"comment"] == NSOrderedSame) {
            return [theDay comment];
        }
    }

	else {
		
		if	(aTableView == itemsTableView)	{
			objectAtIndex =  (NSObject *)[theExperiment itemAtIndex:(NSUInteger)rowIndex];
		}
		else if (aTableView == groupsTableView)	{ 
			objectAtIndex =  (NSObject *)[theExperiment groupAtIndex:(NSUInteger)rowIndex];
		}
        else if (aTableView == drugsTableView)    {
            objectAtIndex =  (NSObject *)[theExperiment drugAtIndex:(NSUInteger)rowIndex];
        }
		else if (aTableView == phasesTableView)	{ 
			objectAtIndex =  (NSObject *)[theExperiment phaseAtIndex:(NSUInteger)rowIndex];
		}		
		
		return [objectAtIndex valueForKey:identifier];
	
	}
	
	return nil;
	
	
}


// Setting Values

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {

	// should be able to use the identifier to get the value pretty directly...
	
	NSObject *barObjectAtIndex = nil;
	NSString *identifier = [aTableColumn identifier];
		
	// just assume that only strings are being set by the table...	
	if (theExperiment == nil) { return; }
	if (aTableView == itemsTableView) {
        
        barObjectAtIndex =  (BarObject *)[theExperiment itemAtIndex:(NSUInteger)rowIndex];
        [barObjectAtIndex setValue:anObject forKey:identifier];

    }
	else if (aTableView == groupsTableView)	{
        
        barObjectAtIndex =  (BarObject *)[theExperiment groupAtIndex:(NSUInteger)rowIndex];
    	[barObjectAtIndex setValue:anObject forKey:identifier];
        
        //have to update group listings in subject table too
        [self setGroupPopupMenu];
        [subjectsTableView reloadData];


    }
    else if (aTableView == drugsTableView)    {

        barObjectAtIndex =  (BarObject *)[theExperiment drugAtIndex:(NSUInteger)rowIndex];
        [barObjectAtIndex setValue:anObject forKey:identifier];


    }
    else if (aTableView == phasesTableView)	{
        
        barObjectAtIndex =  (BarObject *)[theExperiment phaseAtIndex:(NSUInteger)rowIndex];
    	[barObjectAtIndex setValue:anObject forKey:identifier];

    }
	else if (aTableView == subjectsTableView)	{
           // barObjectAtIndex =  (BarObject *)[theExperiment subjectAtIndex:rowIndex];
        if ([identifier isEqualToString:@"groupName"]) {
            
            // the objects intValue is the index of the selected pop-up menu item
            int groupIndexFromObject = [anObject intValue];
            
            if (0 <= groupIndexFromObject  && groupIndexFromObject < (NSInteger)[theExperiment numberOfGroups]) {
                [[theExperiment subjectAtIndex:(NSUInteger)rowIndex] setGroupIndex:(NSUInteger)groupIndexFromObject];
//                NSPopUpButtonCell *popupCell = [aTableColumn dataCell];
//                [popupCell selectItemAtIndex:groupIndexFromObject];
//                [subjectsTableView reloadData];
            }

        }
      }
	else if (aTableView == dailyDataTableView)	{
        // barObjectAtIndex =  (BarObject *)[theExperiment subjectAtIndex:rowIndex];
        if ([identifier isEqualToString:@"phaseName"]) {
            
            // the objects intValue is the index of the selected pop-up menu item
            int phaseIndexFromObject = [anObject intValue];
            
            if (0 <= phaseIndexFromObject  && phaseIndexFromObject < (NSInteger)[theExperiment numberOfPhases]) {
                [[dailyDataArray objectAtIndex:(NSUInteger)rowIndex] setPhaseName:[theExperiment nameOfPhaseAtIndex:(NSUInteger)phaseIndexFromObject]];
                [[dailyDataArray objectAtIndex:(NSUInteger)rowIndex] setCurrentState:kUserEditing];
                [[dailyDataArray objectAtIndex:(NSUInteger)rowIndex] setPhaseDayIndex:0];
                [(DailyData *)[dailyDataArray objectAtIndex:(NSUInteger)rowIndex] save];
                // tell the daily data to save itself
            }
            
        }
    }
	
         

	
	
}

// display the cell (used to display pop-up menu item for group assignment in subjectsTableView
-(void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    
    if (aTableView == subjectsTableView) {
        if ([[aTableColumn identifier] isEqualToString:@"groupName"]) {
            if ([aCell isKindOfClass:[NSPopUpButtonCell class]]) {
                NSString *title = [theExperiment nameOfGroupOfSubjectAtIndex:(NSUInteger)rowIndex];
                [aCell setTitle:title];
            }
        }
        else if ([[aTableColumn identifier] isEqualToString:@"subjectName"]) {
            
                NSString *title = [theExperiment nameOfSubjectAtIndex:(NSUInteger)rowIndex];
                [aCell setTitle:title];
            
        }
    }
    if (aTableView == dailyDataTableView) {
        if ([[aTableColumn identifier] isEqualToString:@"phaseName"]) {
            if ([aCell isKindOfClass:[NSPopUpButtonCell class]]) {
                NSString *title = [theExperiment nameOfPhaseOfDay:(NSUInteger)rowIndex];
                [aCell setTitle:title];
                
            }
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


// data view
// -(IBAction)selectPath:(id)sender; {
//	 
//	 NSLog(@" ExptInfo selectPath Button pressed");
//	 
//	 
//	 NSOpenPanel *openPanel;
//	 NSInteger result;
//	 
//	 /* create or get the shared instance of NSSavePanel */
//	 openPanel = [NSOpenPanel openPanel];
//	 
//	 /* set up new attributes */
//	 [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"txt",nil]];
//	 
//	 // set to the document directory
//
//	 NSString *docDirectoryPath = GetDocDirectoryPath();
//	 
//	 NSURL * docDirectoryURL = [NSURL fileURLWithPath:docDirectoryPath] ;
//	 [openPanel setDirectoryURL:docDirectoryURL ];
//	 
//	 // just select a directory
//	 [openPanel setCanChooseFiles:NO];
//	 [openPanel setCanChooseDirectories:YES];
//	 [openPanel setCanCreateDirectories:YES];
//	 
//	 
//	 /*prompt */
//	 [openPanel setPrompt:@"Location for Summary Data Backup"];
//	 	 
//	 /* display the NSSavePanel */
//	 result = [openPanel runModal];
//	 
//	 if (result == NSOKButton) {
//		 
//		 NSString *myFilePath = [[openPanel filename] copy];
//		 
//		 // save the experiment, but as a template...	
////		 [backupSummaryPathView setStringValue:myFilePath];
//		 
//	}
//	 
//	 
// }


-(void)handleDailyDataDoubleClick:(id)sender; {
    
    // what is the currently selected row of the table view?
	NSInteger selectedRowIndex = [dailyDataTableView selectedRow];
	if (selectedRowIndex == -1) return; // no row is currently selected

    
    // create a new DailyData Document for ON weights with window, etc..
	DailyDataDocument *theDailyDataDoc = [bartender openDailyData];
    
    [theDailyDataDoc startEditingDailyDay:selectedRowIndex WithTheExperiment: theExperiment];
    
}


@end

//
//
//- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
//{
//    if ([[aTableColumn identifier] isEqualToString:LXDetailItemDataType])
//    {
//        NSMutableDictionary *rowDictionary = [tableContents objectAtIndex:rowIndex];
//        NSString *title = [rowDictionary objectForKey:LXDetailItemDataType];
//        
//        NSLog(@"objectValueForTableColumn: %@", title); //DEBUG
//        
//        return [NSNumber numberWithInt:[[aTableColumn dataCell] indexOfItemWithTitle:title]];
//    }
//    else if ([[aTableColumn identifier] isEqualToString:LXDetailItemDevice])
//    {
//        NSMutableDictionary *rowDictionary = [tableContents objectAtIndex:rowIndex];
//        NSString *title = [rowDictionary objectForKey:LXDetailItemDevice];
//        
//        NSLog(@"objectValueForTableColumn: %@", title); //DEBUG
//        
//        return [NSNumber numberWithInt:[[aTableColumn dataCell] indexOfItemWithTitle:title]];
//    }
//    else
//    {
//        NSMutableDictionary *rowDictionary = [tableContents objectAtIndex:rowIndex];
//        return [rowDictionary objectForKey:[aTableColumn identifier]];
//    }
//}
//
//
//- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
//{
//    if ([[aTableColumn identifier] isEqualToString:LXDetailItemDataType])
//    {
//        NSMenuItem *menuItem = [[aTableColumn dataCell] itemAtIndex:[anObject integerValue]];
//        
//        NSMutableDictionary *rowDictionary = [tableContents objectAtIndex:rowIndex];
//        
//        NSLog(@"%@", [menuItem title]); //DEBUG
//        
//        //Update the object value at the column index
//        [rowDictionary setObject:[menuItem title] forKey:LXDetailItemDataType];
//    }
//    else if ([[aTableColumn identifier] isEqualToString:LXDetailItemDevice])
//    {
//        NSMenuItem *menuItem = [[aTableColumn dataCell] itemAtIndex:[anObject integerValue]];
//        
//        NSMutableDictionary *rowDictionary = [tableContents objectAtIndex:rowIndex];
//        
//        NSLog(@"%@", [menuItem title]); //DEBUG
//        
//        //Update the object value at the column index
//        [rowDictionary setObject:[menuItem title] forKey:LXDetailItemDevice];
//    }
//    else
//    {
//        //Get the row
//        NSMutableDictionary *rowDictionary = [tableContents objectAtIndex:rowIndex];
//        
//        //Update the object value at the column index
//        [rowDictionary setObject:anObject forKey:[aTableColumn identifier]];
//    }
//}
