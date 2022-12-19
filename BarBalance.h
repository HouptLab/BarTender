//
//  BarBalance.h
//  Bartender
//
//  Created by Tom Houpt on 12/7/17.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// see Sartorius BasicPlus manual "BP.pdf"
// manual #98648-006-98
// do both my scales use the same manual?

#define kSartoriusNumDataBits 7
#define kSartoriusParity kOddParity
#define kSartoriusNumStopBits 1

#define kSartoriusRequestScaleModelCode "\33x1_\r\n"
#define kSartoriusRequestSerialNumberCode "\33x2_\r\n"

#define kSartoriusTareCode "\33T\r\n"
#define kSartoriusRequestWeightCode "\33P\r\n"
#define kSartoriusVeryStableCode  "\33K\r\n"
#define kSartoriusStableCode "\33L\r\n"
#define kSartoriusUnstableCode "\33M\r\n"
#define kSartoriusVeryUnstableCode "\33N\r\n"

#define kBalanceBufferSizeDefault 1024

#define kBarBalanceReadingDidChangeNotification @"BarBalanceReadingDidChange"
#define kMinimumReporteableWeightChange ((double)0.005)
#define kCheckWeightInterval 0.1

@interface BarBalance : NSObject {

	double curr_weight;
    double last_reported_weight;
	NSDate *curr_weight_time;
	BOOL curr_weight_stable;
    BOOL last_reported_stability;
	
	// do we use these?
	short unit;
	char direction[5];
	unsigned long bufflength;
	unsigned long numReadings;
    unsigned long readingCount;
	Boolean continueReading;
	
	// for serial i/o
	
	int serialFileDescriptor;
		// fileDescriptor for serial port
		// -1 if openSerialPort failed
	
	Boolean serialPortFound; // was serial port found? 
	Boolean deviceFound; // was device (Keyspan?) found
    
    Boolean fakeReading;
	
	NSString *serialNumber;
	NSString *modelCode;
	
	char *responseBuffer; 
		// buffer to hold serial input data from balance
	
	unsigned long bufferSize;
	
	
}

// **********************************************************************
// public methods


-(void) openBalance;
// open serial drivers; set the serial port baud etc.
// set up input buffers
// set to very stable
// note that serialFileDescriptor == -1 if failure to open

-(void) closeBalance;
// clean up input buffers
// kill the serial ports and close drivers

-(void)postNotification; // post notification that weight has changed
-(void)respondToTimer:(NSTimer *)timer; // called periodically to check if weight changed..
-(BOOL) readBalance;
-(void) stopReadBalance;

-(void) tare;
-(void) setVeryStable;
-(void) setStable;
-(void) setUnstable;
-(void) setVeryUnstable;

-(void)toggleFakeReading;

// get the weight
-(double) curr_weight;
-(NSDate *) curr_weight_time;
-(NSString *) curr_weight_text;
-(BOOL) curr_weight_stable;



// **********************************************************************
// internal methods related to Weight

-(BOOL) decodeLine:(unsigned char *)buf;
// decode sartorious weight string input
// sscanf(last_entry,"%s %lf", &direction, &curr_weight);
// from balance input string, extracts curr_weight and sets curr_weight_stable;
// sets curr_weight_time


-(BOOL) checkStability:(char *)last_entry;
// look for units at end of weight string, e.g. 'g' at end of "435.02 g"
// indicates a stable weight has been acquired


-(void)makeFakeReading;
// called if no balalance attached; fakes curr_weight and sets curr_weight_stable;
// sets curr_weight_time


// **********************************************************************
// Serial internal methods 

-(void) openSerialPort;

-(BOOL) writeSerialOut:(char *)outtext;

-(BOOL) requestWeight;
// read serial data in, put into responseBuffer

// **********************************************************************
// Sleep Notifications
// close the balance when about to sleep, open balance upon waking

- (void) receiveSleepNote: (NSNotification*) note;
- (void) receiveWakeNote: (NSNotification*) note;
- (void) fileSleepNotifications;

@end
