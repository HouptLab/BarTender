//
//  DailyData.h
//  Bartender
//
//  Created by Tom Houpt on 12/7/10.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BCMeanValue.h"

@class BarExperiment;

// a DailyData object is the collection of on and off weight pairings
// for all the subjects for a single day (or weigh-on/weigh-off cycle)

enum kBarWeighingState {kWeighingOn, kWeighingOff, kDisplayOnly, kDataOnly,kUserEditing};

enum kBarTerm  {kWeightUnknownTerm = 0, kWeightOn, kWeightOff, kWeightDelta};	

#define MISSINGWGT -32000.0
#define kNoDataCellText @"--"



@interface DailyData : NSObject {
	
	BarExperiment *theExperiment;
	
	NSDate *onTime; // time when the items were weighed on
	NSDate *offTime; // time when the items were weighed off
	NSDate *modificationDate; // last time the dailydata was edited
    
	double *onWeight;	// an array of the on weights
	double *offWeight; // an array of the off weights
	
	NSString *phaseName; // the name of the current experimental phase, set by pop-up menu
	NSInteger phaseDayIndex; // day of the phase we are currently in (e.g., "Extiction Day 5")
	NSInteger currentState; // we are either weighing on, or weighing off some weights, or displaying some old data
	
	NSString *comment;
	
	NSString *UUID;
	

}


// ***************************************************************************************
// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
/// INITIALIZATION
///--------------------------------------------------------------------------------------------------

-(id)init;
-(id)initFromPath:(NSString *)path withExperiment:(BarExperiment *)theExpt;
-(id)initWithExperiment:(BarExperiment *)theExpt; 
-(void)dealloc; // dealloc override so we can free weight arrays

-(void)setDefaults;

// ***************************************************************************************
// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
/// GETTERS AND SETTERS
///--------------------------------------------------------------------------------------------------

-(BarExperiment *)theExperiment;
-(void) setTheExperiment:(BarExperiment *)newExpt;

-(NSInteger) currentState;
-(void) setCurrentState:(NSInteger)newState;

-(NSString *) phaseName;
-(void)setPhaseName:(NSString *)pName;


-(NSUInteger) exptDayIndex;


-(NSInteger) phaseDayIndex;
-(void)setPhaseDayIndex:(NSInteger)pdi;

-(NSString *)comment;
-(void)setComment:(NSString *)c;

-(NSString *)UUID;

-(NSDate *)onTime;
-(void)setOnTime:(NSDate *)date;

-(NSDate *)offTime;
-(void)setOffTime:(NSDate *)date;

-(NSDate *)modificationDate; 
-(void)setModificationDate:(NSDate *)date; 



// ***************************************************************************************
// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
/// FILE Methods
///--------------------------------------------------------------------------------------------------

-(void)save;

-(void)saveOnWeights;

-(void)backupOnWeights; // rename on ".onweights" file as ".onweights.BAK"

-(void)backupOffWeights; // rename off ".weights" file as ".weights.BAK"

-(void)saveOffWeights;

-(void)saveEdits;

-(void)saveToPath:(NSString *)filePath;

-(NSMutableArray *)makeSubjectsDictionaryArray; 

-(void)unpackSubjectDictionary:(NSDictionary *)subjectDictionary;

-(NSMutableDictionary *)dictionaryForSubjectIndex:(NSUInteger)ratIndex;

-(void)readFromPath:(NSString *)filePath; 

-(BOOL)readOnWeights;

-(NSString *)dateStringForFile:(NSDate *)myDate; 
// return the start date&time in string format, 
	// i.e. if weighed on June 15, 2009 at 215pm return "2009-6-15 1415" as an NSString
	// added to end of weights-off file name, e.g. "TQ 2009-6-15 1415"


// ***************************************************************************************
// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
/// Preference related methods...
///--------------------------------------------------------------------------------------------------


-(BOOL) getPreferenceForRat:(NSUInteger)ratIndex preference:(double *)preference total:(double *)total;



// ***************************************************************************************
// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
/// Weight Methods
///--------------------------------------------------------------------------------------------------

-(void)setToOnWeights;

-(void)setToOffWeights;

-(void) initWeights;

-(BOOL) validateRatIndex:(NSUInteger)ratIndex andItemIndex:(NSUInteger)itemIndex;

-(BOOL) getWeightsForRat:(NSUInteger)ratIndex andItem:(NSUInteger)itemIndex onWeight:(double *)onwgt offWeight:(double *)offwgt deltaWeight:(double *)deltawgt;

-(BOOL) setWeightsForRat:(NSUInteger)ratIndex andItem:(NSUInteger)itemIndex onWeight:(double)onwgt offWeight:(double)offwgt;

-(BOOL) setOnWeightForRat:(NSUInteger)ratIndex andItem:(NSUInteger)itemIndex weight:(double)wgt;

-(BOOL) setOffWeightForRat:(NSUInteger)ratIndex andItem:(NSUInteger)itemIndex weight:(double)wgt;

-(void) clearOnWeights;

-(void) clearOffWeights;

-(NSUInteger) numberOfUnweighedOnItems;

-(NSUInteger) numberOfUnweighedOffItems;

-(NSUInteger) numberOfUnweighedItems; // return unweigh OnItems or OffItems, depending on current state

-(void)	carryOverOffWeightsToOnWeights;
	//NOTE this will require referencing the last daily data, on disk?



// ***************************************************************************************
// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
/// Text Methods
///--------------------------------------------------------------------------------------------------

// Methods for getting  Text for display in NSTableView dailyView

-(NSString *) getTextForItem:(NSString *)itemName atTerm:(NSUInteger)itemTerm forRat:(NSUInteger)ratIndex;

-(NSString *) weightAsNSString:(double)wgt;

-(NSString *) getPreferenceScoreTextForRat:(NSUInteger)ratIndex;

-(NSString *) getTotalTextForRat:(NSUInteger)ratIndex;


// ***************************************************************************************
// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
/// Time Methods
///--------------------------------------------------------------------------------------------------


/** return weighed-on time as a string
 
 same as [onTime description]

 
 @return NSString with the weighed on time in international string representation format (yyyy-MM-DD HH:MM:SS ±HHMM)
 
 */

-(NSString *)onTimeString;

/** return weighed-off time as a string
 
 same as [offTime description]
 
 @return NSString with the weighed off time in international string representation format (yyyy-MM-DD HH:MM:SS ±HHMM)
 
 */

-(NSString *)offTimeString;

-(NSString *)onTimeDescription;
-(NSString *)offTimeDescription;

-(NSString *)modificationDateDescription; 

/** takes a international format time string, converts it to an NSDate
 if string is nil or "na", then NSDate is set to nil
 
 @param NSString with the time in international string representation format (yyyy-MM-DD HH:MM:SS ±HHMM)
 @return NSDate derived from string, or nil if date can't be parsed
 */

-(NSDate *)dateFromTimeString:(NSString *)timeString;
-(NSString *)shortTimeStringFromDate:(NSDate *)date;

// ***************************************************************************************
// ***************************************************************************************
///--------------------------------------------------------------------------------------------------
/// Group Average Methods
///--------------------------------------------------------------------------------------------------

-(NSArray *)itemLabels;
// an array of NSStrings containing labels for the daily data labels
// e.g. "Saccharin", "Water", "Total", "Pref",

-(NSArray *)groupLabels;
// an array of NSStrings containing names of the expt groups
// e.g. "NN", "NL", "LN", "LL"

-(NSArray *)itemMeansForGroupIndex:(NSUInteger)groupIndex;
// an array of BCMeanValue objects, one object for each item in the daily data for the given group

-(NSArray *)groupMeans;
// an array of arrays; each object in the array is an array of group means


@end
