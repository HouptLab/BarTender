//
//  Balance.m
//  Bartender
//
//  Created by Tom Houpt on 09/6/19.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import "Balance.h"
#import <Serial.h>



@implementation Balance

-(id)init {
	
	[super init];
	curr_weight = -32000;
	curr_weight_time = 0;
	
	
}
-(void) stopReadingBalance(void) {
	
	continueReading = FALSE;
	
}

-(BOOL) readBalance(void) {
	
	
	if (MyReceiveMessage() > 0 ) {
		
		if (DecodeLine((unsigned char *)weight_input_buffer)) {
			numReadings++;
			return(TRUE);
		}
	}
	
	return(FALSE);
	
}

static unsigned long line_length;

Boolean DecodeLine(unsigned char *buf)
//should be static for asynch call
{
	// used to sue to find first entry
	//line_length = 0;
	//while (buf[line_length] != '\r') line_length++;
	//buf[line_length] = '\0';	
	
	// terminate the line with a NULL character
	long buf_length  = strlen((char *)buf);
	long buf_start;
	char *last_entry;
	// find beginning of last entry
	//start from end of buffer, and find chars in between two \r chars, or
	// between the start of the buffer and a terminal \r
	
	//line_length = 0;
	//while (buf[line_length] != '\r') line_length++;
	//buf[line_length] = '\0';
	
	//NOTE -- not sure we need all this if use the moern serial routines...
	
	buf_start = buf_length - 3;
	
	while (buf_start > 0 && buf[buf_start] != '\r') {
		
		buf_start--;
	}
	
	last_entry = (char *)buf + buf_start;
	
	if (strlen(last_entry) > 6) {
		// decode denver
		// sscanf(last_entry,"%hd %s %lf",&unit, &direction, &curr_weight);
		
		// decode sartorious
		sscanf(last_entry,"%s %lf", &direction, &curr_weight);
		if (direction[0] == '-') curr_weight *= -1.0;
		curr_weight_time = SecsNow();
		curr_weight_stable = CheckStability(last_entry);
		return(TRUE);
	}
	
	return(FALSE);
	
}

-(BOOL) CheckStability(char *last_entry) {
	
	short i;
	
	for (i=0;i<strlen(last_entry);i++) {
		
		
		if (last_entry[i] == 'g') return(YES);
		
	}
	return(NO);
	
}
-(NSError)OpenBalance(void)
{
		
	
	// NOTE: use the modern serial routines to get a file pointer to the balance?
	
	// set the balance to very stable...
	
	SetVeryStable();
	
	error:
	
		(void) CloseBalance();
	
	exit:
		return result;
}

void CloseBalance(void)
{
	
	// NOTE: use the modern serial routines to close the serial port

}



long MyRequestWeight(void) {
	
	//NOTE use SendQueryToSerialPort
	
	// return(WriteSerialOut("\33P\r\n")); 
	// returns number of characters receieved 
	// in classic version, returned bytes go into inputBuffer
		
	SendQueryToSerialPort (serialFileDescriptor,kRequestWeightQuery, &weight_input_buffer, MAX_WEIGHT_TEXT);

}


// NOTE rewrite using SendCommandToSerialPort


void Tare(void) {
	
	char response[256];
	
	SendCommandToSerialPort (serialFileDescriptor,kTareCommand, &response);

	
}

void SetVeryStable(void) {
	
	char response[256];
	SendCommandToSerialPort (serialFileDescriptor,kSetVeryStableCommand, &response);

	
}
void SetStable(void) {
	
	char response[256];
	SendCommandToSerialPort (serialFileDescriptor,kSetStableCommand, &response);

	
}

void SetUnstable(void) {
	
	char response[256];
	SendCommandToSerialPort (serialFileDescriptor,kSetUnstableCommand, &response);

	
}

void SetVeryUnstable(void) {
	
	char response[256];
	SendCommandToSerialPort (serialFileDescriptor,kSetVeryUnstableCommand, &response);

	
	
}




@end
