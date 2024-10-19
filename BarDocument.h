//
//  BarDocument.h
//  Bartender
//
//  Created by Tom Houpt on 09/7/6.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class BarExperiment;
@class DailyDataDocument;
@class ExptInfoController;
@class BarBalance;



@interface BarDocument : NSDocument {
	
	IBOutlet NSTextField *experiments_waiting;
	
	IBOutlet NSTableView *exptTableView;

	ExptInfoController *exptInfoController;
	
	NSMutableArray *currentExpts;
    
    NSMutableArray *currentDailyDataDocuments;
	
	BarBalance *balance;
	

}

// buttons & menu items on the BarDocument window

-(IBAction)weighBottlesOn:(id)sender;
-(IBAction)weighBottlesOff:(id)sender;

-(void)createExptInfoController;
-(IBAction)newExperiment:(id)sender;
-(void)handleDoubleClick:(id)sender; 
-(IBAction)editExperiment:(id)sender;
-(IBAction)duplicateExperiment:(id)sender;

-(IBAction)graphExperiment:(id)sender;
-(IBAction)wikiExperiment:(id)sender;
-(IBAction)saveExperimentSummary:(id)sender;
-(IBAction)removeExperiment:(id)sender;
-(IBAction)weighOnExperiment:(id)sender;
-(IBAction)weighOffExperiment:(id)sender;

-(IBAction)saveExperimentToFirebase:(id)sender;
-(IBAction)saveExperimentToXynkImport:(id)sender;

-(IBAction)toggleFakeReading:(id)sender;

-(BOOL)validateMenuItem:(NSMenuItem *)anItem; 

-(void)closeExptInfo:(id)sender andSaveExpt:(BOOL)saveFlag;

-(BarExperiment *)experimentWithCode:(NSString *)code;
-(BarExperiment *)getExperimentFromLabel:(NSString *)labelString;

-(void)loadActiveExperiments;
	// read in all the files ending in ".barexpt" from the directory "/Documents/Bartenders/Experiments/"

-(BarExperiment *)selectedExpt;
	// return the currently selected experiment on the exptTableView

-(BarBalance *)balance; 
	// get the interface for the balance

-(DailyDataDocument *)openDailyData; 
-(void)addDailyDataDocument:(DailyDataDocument*) ddd;
-(void)removeDailyDataDocument:(DailyDataDocument*) ddd;


@end

