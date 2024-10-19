//
//  BarExperiment.h
//  Bartender
//
//  Created by Tom Houpt on 09/6/14.
//  Copyright Behavioral Cybernetics 2009 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "BarObject.h"

@class BarItem;
@class BarGroup;
@class BarPhase;
@class DailyData;
@class DailyDataDocument;
@class BarSubject;

@interface BarExperiment : BarObject {
	
	// general expt info
		NSString *investigators;
		NSString *protocol;
		NSString *project_code;
        NSString *project_name;

        NSString *wiki;
    
		BOOL templateFlag; 
		// is this experiment used as a template, i.e. stored as AA.bartemplate
	
		unsigned long startTime;
		unsigned long endTime; // 0 == end-time not defined yet
	
		BOOL waitingForOff;
			// indicates if we are waiting for some bottles to be weighed off
	
		NSString *status;
			// waitingForOff status as a string "ON" or "OFF"
            // NOTE: don't need to copy?
	
		BOOL useGroups; 
			// flag to indicate if data should be divided
			//  into groups for analysis & summary
	
		
		BOOL hasPreference;
		NSUInteger prefItemIndex,baseItemIndex;
			// flag indicating that preference will be automatically calculated
			// preference = prefItem / (prefItem + baseItem)
	
		BOOL usePreferenceOverTotal;
			// preference can be pref / (pref+ref) or just pref/ref
	
		// NOTE may need an array of subjects some day; 
		// this array would keep track of what group each rat belonged to...
		// for the moment we can just keep track of the number of rats in the experiment
	
		NSMutableArray *subjects;		
				// list of subjects, which are bascially just wrappers for group assignments...
		
		NSMutableArray *items;	
				// list of ItemTypes as BarItems, e.g. "food", "water", "saccharin"
				// these will serve as columns...
	
		NSMutableArray *groups; 
				// list of BarGroups to which rats are assigned

		NSMutableArray *phases; 
				// list of phases which divide up the days of the experiment

        NSMutableArray *drugs;
            // list of drugs with name, code (= abbr), and description (=link to msds) 
	
		NSMutableArray *dataDays; 
		// list of daily data records
        // don't need to copy
	
		BOOL dailyDataNeedsUpdating; // flag to tell us that we need to update our dailydata
        // don't need to copy
	
		// keep track of these variables to inform the current daily data
		NSString *currentPhaseName; // phase of the last saved daily data
	   // NOTE: store current experimental phase by name of phase; so will break if user changes name

		NSString *lastDailyDataPath; // path the the last saved (weighed off) daily data
	
	//	NSString *backupSummaryPath; // path to summary file that is saved automatically after new weight info added
	

}
		
		

// **********************************************************************
// Experiment methods ---------------------------------------------------


- (id) init;
- (id) initFromPath:(NSString *)filePath;
- (void) setDefaults;
- (void) setNewExptDefaults;

- (void) updateWithOnWeights;
- (void) updateWithOffWeightsAtPath:(NSString *)path andPhaseName:(NSString *)phaseName andPhaseDay:(NSInteger)day; 
 -(void) saveBackupSummary; 

// **********************************************************************
// Setters --------------------------------------------------------------


// these setters make deep copies of the passed variables...
- (void) setInvestigators:(NSString *)newInvestigators;
- (void) setProtocol:(NSString *)newProtocol;
- (void) setWiki:(NSString *)newWiki;
- (void) setProjectCode:(NSString *)newCode;
- (void) setProjectName:(NSString *)newName;

- (void) setTemplateFlag:(BOOL)flag;

- (void) setStartTime:(unsigned long) s;
- (void) setEndTime:(unsigned long) e;

- (void) setWaitingForOff:(BOOL)wfo;
- (void) setUseGroups:(BOOL)newUseGroup;


// these setters only set the array ptr

- (void) setSubjects: (NSMutableArray *)nS;
- (void) setItems: (NSMutableArray *)nI;
- (void) setGroups: (NSMutableArray *)nG;
- (void) setPhases: (NSMutableArray *)nP;

// -(void) setBackupSummaryPath:(NSString *)newPath; 


// **********************************************************************
// Getters --------------------------------------------------------------


- (NSString *) getSummaryFileName;
- (NSString *) investigators;
- (NSString *) protocol;
- (NSString *) wiki;
- (NSString *) project_code;
- (NSString *) project_name;

- (BOOL) templateFlag;

- (unsigned long) startTime;
- (unsigned long) endTime;
- (NSDate *)last_data_update;

- (NSUInteger) prefItemIndex;
- (NSUInteger) baseItemIndex;

- (BOOL) waitingForOff;
- (NSString *) status;
- (BOOL) useGroups;

// - (NSString *) backupSummaryPath;

// **********************************************************************
// DailyData Methods -- 
- (NSString *) lastDailyDataPath; 
- (void) setLastDailyDataPath:(NSString *)path;
- (NSUInteger) numberOfDays;
- (DailyData *) dailyDataForDay:(NSUInteger)dayIndex;
- (NSUInteger) dayIndexOfDailyData:(DailyData *)dailyData; // return NSNotFound if daily data not indexed yet (i.e.  weighed on, weighing off still pending)
- (void) loadDailyData;
- (void) countDailyDataFilesInPath:(NSString *)path counter:(NSUInteger *)count;
- (void) readDailyDataFromPath:(NSString *)path;
- (BOOL) isDailyDataFile:(NSString *)path;
- (BOOL) onWeightsFileExists;
- (NSString *) getExptDailyDataDirectoryPath;
- (void) dailyDataNeedsUpdating;
//- (NSInteger) indexOfDailyData:(DailyData *)data;

// called by DailyData to notify experiment that new daily data has been saved 



// **********************************************************************
// Subject methods ------------------------------------------------------


- (NSMutableArray *) subjects;
- (void) setNumberOfSubjects:(NSUInteger)n;
- (NSUInteger) numberOfSubjects;
- (BarSubject *) subjectAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfSubject:(BarSubject *)subject;
- (NSUInteger) subjectIndexFromLabel:(NSString *)labelString;
	// given a label of format "[ExptAbbr][Subject Number][ItemCode]"
	// extract the number of the subject
	// NSNotFound if outside the range of subject numbers

- (NSString *) nameOfSubjectAtIndex:(NSUInteger)index;
- (BarGroup *) groupOfSubjectAtIndex:(NSUInteger)index;
- (NSString *) nameOfGroupOfSubjectAtIndex:(NSUInteger)index;
- (NSUInteger) indexOfGroupOfSubjectAtIndex:(NSUInteger)index;


// **********************************************************************
// Item methods ---------------------------------------------------------

- (NSMutableArray *) items;
- (NSUInteger) numberOfItems;
- (void) addNewItem;
- (void) deleteItem:(BarItem *)theItem;
- (void) deleteItemAtIndex:(NSUInteger)index;
- (BarItem *) itemAtIndex:(NSUInteger)index;
- (NSUInteger) indexOfItem:(BarItem *)theItem; 
	// NSNotFound if not in the array
- (BarItem *) itemWithCode:(NSString *)testCode;
- (BarItem *) itemWithName:(NSString *)itemNameString;

- (NSUInteger) itemIndexFromName:(NSString *)itemNameString;

- (NSUInteger) itemIndexFromLabel:(NSString *)labelString;
	// given a tag of format "[ExptAbbr][Subject Number][ItemCode]"
	// extract the itemcode, and thus the item index..
	// -1 if not recognized



// **********************************************************************
// Preference methods----------------------------------------------------

/** returns label for preference
 e.g. "Saccharin Preference"
 
*/
- (NSString *) preferenceTitleText;

/** returns label for total
 e.g. "Total Saccharin + Water"
 
 */
- (NSString *) totalTitleText; 

- (BOOL) hasPreference;
- (void) setHasPreference:(BOOL)newPreference;

- (void) getIndexOfPreferenceItem:(NSUInteger *)s overItem:(NSUInteger *)w;
- (void) setPreferenceIndexofItem:(NSUInteger)s overItem:(NSUInteger)w;

- (BOOL) usePreferenceOverTotal;
- (void) setUsePreferenceOverTotal:(BOOL)useTotal;





// **********************************************************************
// Group methods     ----------------------------------------------------

- (NSMutableArray *) groups;

- (void) addNewGroup;
- (void) deleteGroup:(BarGroup *)theGroup;
- (void) deleteGroupAtIndex:(NSUInteger)index;

- (NSUInteger) numberOfGroups;
- (BarGroup *) groupAtIndex:(NSUInteger)index;
- (NSUInteger) getGroupIndex:(BarGroup *)theGroup;	
- (void) setBlockGroups;
- (void) setAlternatingGroups;
- (NSString *) codeOfGroupAtIndex:(NSUInteger)index;
- (NSUInteger) indexOfGroupWithCode:(NSString *)groupCode;
- (NSString *) codeOfGroupOfSubjectAtIndex:(NSUInteger)index;


- (BarGroup *) unassignedGroup;


// **********************************************************************
// Phase methods     ----------------------------------------------------

- (NSMutableArray *) phases;

- (void) addNewPhase;
- (void) deletePhase:(BarPhase *)thePhase;
- (void) deletePhaseAtIndex:(NSUInteger)index;

- (NSUInteger) numberOfPhases;
- (BarPhase *) phaseAtIndex:(NSUInteger)index;
- (NSUInteger) getPhaseIndex:(BarPhase *)thePhase;	
- (NSString *) nameOfPhaseAtIndex:(NSUInteger)index;

- (void) addPhaseNamesToMenu:(NSMenu *)phaseMenu;

- (NSString *)currentPhaseName;
- (void) setCurrentPhaseName:(NSString *)phase;	

- (void) setCurrentPhaseDay:(NSInteger)day;
- (NSInteger) dayOfPhaseOfName:(NSString *)phaseName;
- (BarPhase *) phaseWithName:(NSString *)phaseName;

- (NSString *)nameOfPhaseOfDay:(NSUInteger)dayIndex;


// **********************************************************************
// Drug methods     ----------------------------------------------------

- (NSMutableArray *) drugs;

-(void)addNewDrug;
- (NSUInteger) numberOfDrugs;
- (BarPhase *) drugAtIndex:(NSUInteger)index;
- (NSUInteger) getDrugIndex:(BarPhase *)thePhase;
- (NSString *) nameOfDrugAtIndex:(NSUInteger)index;
- (void) deleteDrugAtIndex:(NSUInteger)index;

- (void) addDrugNamesToMenu:(NSMenu *)drugMenu;


// **********************************************************************
// Experiment File Methods ----------------------------------------------------

- (BOOL) archive; // move .barexpt and dailydata to /Archives
- (BOOL) trash; // move .barexpt and dailydata to trash
- (BOOL) save;
- (BOOL) saveAsTemplate:(NSString *)templateName;
- (BOOL) saveToPath:(NSString *)exptFilePath;
- (NSDictionary *) makeExptParametersDictionary;
- (NSDictionary *) makeSubjectDictionary;
- (NSDictionary *) makeGroupDictionary;
- (NSDictionary *) makeItemDictionary;
- (NSDictionary *) makePhaseDictionary;
- (NSDictionary *) makeCurrentInfoDictionary;

- (BOOL) loadFromPath:(NSString *)exptFilePath;
- (BOOL) loadFromTemplatePath:(NSString *)templateFilePath;
- (BOOL) unpackExptParametersDictionary:(NSDictionary *)dictionary;
- (BOOL) unpackSubjectDictionary:(NSDictionary *)dictionary;
- (BOOL) unpackGroupDictionary:(NSDictionary *)dictionary;
- (BOOL) unpackItemDictionary:(NSDictionary *)dictionary;
- (BOOL) unpackPhaseDictionary:(NSDictionary *) dictionary; 
- (BOOL) unpackCurrentInfoDictionary:(NSDictionary *)dictionary;


// **********************************************************************
// Cumulative File methods -----------------------------------------------
 
/*
- (void) createCumulativeFile;
- (void) replaceCumulFile;
- (void) appendCumulFileWithDailyData:(DailyData *)theDailyData;			
 */
					
@end
