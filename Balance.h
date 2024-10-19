//
//  Balance.h
//  Bartender
//
//  Created by Tom Houpt on 09/6/19.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// pretend that the balance is a specific object that we talk to when we need some weight info

#define INPUT_BUFFER_MAX	32768
#define MAX_WEIGHT_TEXT 256

#define kRequestWeightQuery	"\33P\r\n"
#define kTareCommand	"\33T\r\n"
#define kSetVeryStableCommand	"\33K\r\n"
#define kSetStableCommand	"\33L\r\n"
#define kSetUnstableCommand	"\33M\r\n"
#define kSetVeryUnstableCommand	"\33N\r\n"


@interface Balance : NSObject {

	double curr_weight;
	short unit;
	char direction[5];
	
	char weight_input_buffer[MAX_WEIGHT_TEXT]; // string returned from the balance containing the current weight
	char curr_weight_text[MAX_WEIGHT_TEXT]; // string containing a textual represenation of the current weight
	unsigned long curr_weight_time; // the last time in seconds that the weight was measured
	BOOL curr_weight_stable; // whether the weight currently on the balance is stable

	BOOL continueReading;
	
	
	int serialFileDescriptor; // the fileDecsriptor returned by openSerialPort
	 
}

-(BOOL) openBalance(void);
-(void) closeBalance(void);
-(BOOL) readBalance(void);
-(void) stopReadingBalance(void);


-(long) requestWeight(void); 
// get the string containing current weight from the balance using SendQueryToSerialPort
-(BOOL) decodeLine(unsigned char *buf); 
	// decode a sartorious output line, i.e. "[char direction] [float weight] [char unit]"
-(BOOL) checkStability(char *last_entry); 
// on the sartorius scale, checks if the last string from the balance ended with a unit, e.g. 'g'
// which is how the sartorius indicates a stable weight

// routines to set charateristics of the electronic balance
// the routines send the command string using SendCommandToSerialPort
-(void) tare(void);
-(void) setVeryStable(void);
-(void) setStable(void);
-(void) setUnstable(void);
-(void) setVeryUnstable(void);


@end
