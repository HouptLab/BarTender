//
//  DailyDataDocument.h
//  Bartender
//
//  Created by Tom Houpt on 09/6/14.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BarExperiment.h"
#import "BarDocument.h"
#import "DailyData.h"

// DailyDataDocument is the document window to handle input and printing of DailyData
// a DailyData object is the collection of on and off weight pairings
// for all the subjects for a single day (or weigh-on/weigh-off cycle)


@interface DailyDataDocument : NSDocument {
		
	BarDocument * bartender;

	BarExperiment  * theExperiment;
	
	DailyData *dailyData; // holds the on/off weight data for this day
	
    
	BOOL closeAfterPrinting; // flag to ask documentDidRunModalPrintOperation to close document after printing
	
	int currentState; // we are either weighing on, or weighing off some weights, or displaying some old data
    NSInteger editingDayIndex;

	double currentWeight; // the weight currently recorded
	double lastWeight; // the last weight recorded
    NSString *scannedLabelString;
    NSUInteger scannedRatIndex, scannedItemIndex; // derived from last scanned label
    BOOL needWeightForItem; // flag to indicate that we scanned an item label, now we're looking for a weight
    NSUInteger numWeightTries;

//	NSTimer *weightTimer; // timer that goes off so that we periodically update the weight on the display

	
	// interface stuff for input/output of daily data
	
	IBOutlet NSView *dailyDataContentView;
	IBOutlet NSTableView *dailyTableView;
	IBOutlet NSTextField *itemLabel;
    IBOutlet NSTextField *lastItemLabel;
	IBOutlet NSTextField *itemWeight;
	IBOutlet NSTextField *exptNameLabel;
	IBOutlet NSTextField *phaseLabel;
	IBOutlet NSTextField *onTimeLabel;
	IBOutlet NSTextField *offTimeLabel;
	IBOutlet NSTextView *commentView;

	IBOutlet NSPopUpButton *phasePopup;
	IBOutlet NSTextField *phaseDayLabel;

	NSInteger fontSize;
 
    NSSpeechSynthesizer *speech ;  
	
}

// @property (nonatomic, retain) NSTimer *weightTimer;


// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
/// Setters and getters
///--------------------------------------------------------------------------------------------------


-(BarDocument *) bartender;
-(void) setBartender:(BarDocument *)bt; 

-(void)startWeighingInState:(int)weighingState WithTheExperiment: (BarExperiment *)newExpt;

-(void)startEditingDailyDay:(NSInteger)dayIndex WithTheExperiment: (BarExperiment *)newExpt;


-(void) setTheExperiment:(BarExperiment *)newExpt;
-(BarExperiment *) theExperiment;



-(void)setToOnWeights;
-(void)setToOffWeights;
-(void)setToUserEditing;

-(void)updateWindowTitle;

// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
/// overide NSDocument methods
///--------------------------------------------------------------------------------------------------

//-(void)cleanUpAndClose;
//-(void)close; 
//- (void) document:(NSDocument*)doc shouldClose:(BOOL)shouldClose contextInfo:(void*)contextInfo;
//- (void)canCloseDocumentWithDelegate: (id)delegate shouldCloseSelector: (SEL)shouldCloseSelector contextInfo: (void*)contextInfo;

-(void) saveDocument:(id)sender;

-(void) printDocument:(id)sender;

-(void) removeFromBartender; // tell bartender to remove us from list of open daily documents, then super close

// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
/// INTERFACE methods to handle toolbar button and menu item presses
///--------------------------------------------------------------------------------------------------

-(IBAction) open:(id)sender;

-(IBAction) save:(id)sender;

-(IBAction) print:(id)sender;

-(IBAction) saveAndPrint:(id)sender;		// this is also linked to the "Save and Print" button

-(void) printShowingPrintPanel:(BOOL)showPanels;

//- (void)documentDidRunModalPrintOperation:(NSDocument *)document  success:(BOOL)success  contextInfo:(void *)contextInfo;

-(IBAction) setExptPhase:(id)sender;

-(void) updatePhaseMenuAndLabel;

-(IBAction) abort:(id)sender;		//  closes window without saving and printing...

-(IBAction) tare:(id)sender; // toolbar button to tare the balance

-(IBAction) carryOver:(id)sender; 	// carry over yesterdays off weights to todays on weights


// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
// interface methods for acquiring barcode and weight
///--------------------------------------------------------------------------------------------------


-(IBAction) labelStringEntered:(id)sender;

-(BOOL) parseLabelString:(NSString *)labelString getRatIndex:(NSUInteger *)ratIndex getItemIndex:(NSUInteger *)itemIndex;

-(void) processWeightForScannedItem;

-(void) checkWeightForLabel:(NSString *)labelString atItemIndex:(NSUInteger)itemIndex;

-(void) selectTableRowAtIndex:(NSUInteger)ratIndex;

// -(void)setWeightTimer;

// -(void) updateWeightDisplay:(NSTimer *)timer; // update the weight on display
// -(void) updateWeightDisplay; // update the weight on display

-(void)updateWeightDisplay:(NSNotification*) note; 


// ***************************************************************************************
// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
/// Time Methods
///--------------------------------------------------------------------------------------------------


-(void)setOnTime:(NSDate *)date; 

-(void)setOffTime:(NSDate *)date;

 
// ***************************************************************************************
// ***************************************************************************************
/// Methods for getting Table Text for display in NSTableView dailyTableView
///----------------------------------------------------------------------------------------
///----------------------------------------------------------------------------------------


-(NSString *) getItemNameFromTableHeader:(NSString *)header;

-(NSUInteger) getItemTermFromTableHeader:(NSString *)header;


// ***************************************************************************************
// ***************************************************************************************
///----------------------------------------------------------------------------------------
/// NSTableView datasource methods
///----------------------------------------------------------------------------------------

-(NSTableView *) dailyTableView;

// initializing the table view columns

-(void) addDailyTableViewColumnWithIdentifier:(NSString *)identifier  editable:(BOOL)flag;

-(void) addBlankColumnToDailyTableView;

-(void) setUpDailyTableViewColumns;

// Getting Values for the table

-(NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView;

-(id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;


@end
