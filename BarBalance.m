//
//  BarBalance.m
//  Bartender
//
//  Created by Tom Houpt on 12/7/17.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import "BarBalance.h"
#import "BCSerial.h"
#import "BCAlert.h"
#import "SerialPortNameController.h"

#define debug_log YES

@implementation BarBalance

// static pascal void InputCompletion(ParmBlkPtr paramBlock);

// **********************************************************************
// public methods

// ----------------------------------------------------------------------
-(id)init; {
	
	self = [super init];
	
	if (self) {
		
		serialFileDescriptor = kSerialErrReturn;
		
		// initialize response buffer
		bufferSize = kBalanceBufferSizeDefault;
		responseBuffer = malloc(bufferSize);
        
        // set up sleep notifications so that we close balance when sleeping
        // and re-pen balance upon awakening
        [self fileSleepNotifications];
		
		[self openBalance];
        
        fakeReading = NO;
        
        // start an NSTimer to make us check weight every so often e.g., 0.1 seconds
        NSTimer *checkWeightTimer;
        checkWeightTimer = [NSTimer scheduledTimerWithTimeInterval:kCheckWeightInterval  target:self selector:@selector(respondToTimer:) userInfo:NULL repeats:YES];
   	
	}
	
	return self;
	
}

-(void)dealloc; {
	
	[self closeBalance];
	if (responseBuffer != NULL) { free (responseBuffer); }
	
	
}

-(void) openBalance; {
	
//	OSErr result;
//	SerShk flags = {0, 1, 0, 0, 0, 0, 0, 1};
	
	
//	result = OpenSerialDrivers("\p.AIn", "\p.AOut", &SerialInput,&SerialOutput);
//	if (result != noErr) goto error;
//	
//	//	result = OpenDriver ("\p.AIn",  &SerialInput);
//	//	if (result != noErr) goto error;
//	//	result = OpenDriver ("\p.AOut", &SerialOutput);
//	//if (result != noErr) goto error;
//	
//	
//    SerShk mySerShkRec;
//    
//    
//	mySerShkRec.fXOn = 0;  //turn off XON/XOFF output flow control
//	mySerShkRec.fCTS = 0;  //turn off CTS/DTR flow control
//	mySerShkRec.errs = 0; //clear error mask
//	mySerShkRec.evts = 0; //clear event mask
//	mySerShkRec.fInX = 0; //turn off XON/XOFF input flow control
//	mySerShkRec.fDTR = 0; //turn off DTR input flow control
//	
//    
//	
//	//result = Control(SerialOutput, 14, &flags);
//	result = Control(SerialOutput, 14, &mySerShkRec);
//	if (result != noErr) goto error;
//	
//	// dafault is what we want.
//	
//	// works for Denver
//	//result = SerReset(SerialInput, baud9600 | stop20 | noParity | data8);
//	//if (result != noErr) goto error;
//	//result = SerReset(SerialOutput, baud9600 | stop20 | noParity | data8);
//	//if (result != noErr) goto error;
//	
//	//works for sartorius
//	result = SerReset(SerialInput, baud9600 | stop10 | oddParity | data7);
//	if (result != noErr) goto error;
//	result = SerReset(SerialOutput, baud9600 | stop10 | oddParity | data7);
//	if (result != noErr) goto error;
	
	
// so sartorius: 7 data bits odd parity 1 stop bit = 701
//	
//	MyChangeInputBuffer();
//	NextInput = InputBuffer;
	
	// open serial port
	
	[self openSerialPort];
	
    if (debug_log) { NSLog(@"openBalance: serialFileDescriptor = %d", serialFileDescriptor); }
	// NOTE: confirm that balance is there? and working?

	if (serialFileDescriptor != kSerialErrReturn) {
        
        // tare the balance
        [self tare];

        // set it to very stable...
        [self setVeryStable];
            
    }
	
}


// get the weight
-(double) curr_weight; {return curr_weight; }
-(NSDate *) curr_weight_time; { return curr_weight_time; }

-(NSString *) curr_weight_text; { 
	
	NSString * curr_text;
	if (curr_weight_stable) {  curr_text = [NSString stringWithFormat:@"%.2lf g",curr_weight]; }
	else {  curr_text = [NSString stringWithFormat:@"%.2lf",curr_weight]; }
	return curr_text;

}

-(BOOL) curr_weight_stable; {return curr_weight_stable; }


// **********************************************************************
// Serial internal methods 

#define kSerialPortNotOpenedString @"Serial Port not opened."
#define kSerialPortNotFoundString @"Serial port was not found.")
#define kSerialDeviceNotFoundString @"Serial device \"%@\" was not found. Make sure USB serial adapter is plugged in, and re-enter its name as found in /dev directory."

#define kBartenderSerialPortNameKey @"BartenderSerialPortName"

-(void) openSerialPort; {
	
	// open serial port on Keyspan Device
	// (get fileDescriptor for serial port)
	
	// defaults for sartorius balance: 7 data bits odd parity 1 stop bit
	// predefined constants kSartoriusNumDataBits, kSartoriusParity, kSartoriusNumStopBits
	
    // TODO: store and read serial device from preferences   
    // TODO: present dialog to choose serial device from list at /dev/cu.*
            
     // get serial port name from user defaults
     NSString *serialPortName = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderSerialPortNameKey];
     
     if (nil == serialPortName) {
        // get name from user
        SerialPortNameController *newNameDialog =  [[SerialPortNameController alloc] initWithName:@"cu.usbserial"];
        serialPortName = [newNameDialog dialogForWindow:[NSApp keyWindow]];
        if (nil == serialPortName || 0 == [serialPortName length]) {
            serialPortName = @"none";
        }
     }
     


        if ([serialPortName isEqualToString:@"none"]) {
            serialFileDescriptor = kSerialErrReturn;
        }
        else {
            serialFileDescriptor = FindAndOpenSerialPort([serialPortName UTF8String], &serialPortFound, &deviceFound, kSartoriusNumDataBits, kSartoriusParity, kSartoriusNumStopBits);
        }
       
        
        // NOTE: put in error code here to alert if balance is not found...

        if ( kSerialErrReturn == serialFileDescriptor) {     
            
            
            NSString *deviceString = [NSString stringWithFormat:kSerialDeviceNotFoundString, serialPortName];
            
            NSString *information;
            
            if (!serialPortFound && !deviceFound) {
                
                information = [NSString stringWithFormat:@"%@\n%@", kSerialPortNotOpenedString, deviceString];
                
            }
            else if (!serialPortFound) {
                
                information = kSerialPortNotOpenedString;
                
            }
            else if (!deviceFound) {
                information = deviceString;
            }
            
                BCOneButtonAlert(NSWarningAlertStyle, @"Serial Port not opened.", information, @"OK");
                
                // erase the serialport name because it didn't work
                [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderSerialPortNameKey];
            
        } // kSerialErrReturn
        else {
              // worked, so save the serial port name
              [[NSUserDefaults standardUserDefaults] setValue:serialPortName forKey:kBartenderSerialPortNameKey];
        }
	
	
 
}

-(BOOL) writeSerialOut:(char *)outtext; {
	
	Boolean resultFlag = FALSE;
	
	if (serialFileDescriptor != kSerialErrReturn) {
		
		resultFlag = SendCommandToSerialPort(serialFileDescriptor, outtext);
		
	}
	
	return (BOOL)resultFlag;
	
}
// ----------------------------------------------------------------------


-(void) closeBalance; {
	
	if (serialFileDescriptor != kSerialErrReturn) {
		CloseSerialPort(serialFileDescriptor);
		serialFileDescriptor = kSerialErrReturn;
	}
	
}


// **********************************************************************

// wrappers for sending commands to balance


// ----------------------------------------------------------------------
-(BOOL) requestSerialNumber; {	
	
	Boolean resultFlag = FALSE;
	
	if (serialFileDescriptor != kSerialErrReturn) {
		
		resultFlag = SendQueryToSerialPort (serialFileDescriptor, kSartoriusRequestScaleModelCode, responseBuffer, bufferSize);
		
		if (resultFlag) {
			
			// convert response to NSString
			serialNumber = [NSString stringWithCString:responseBuffer encoding:[NSString defaultCStringEncoding]];
			
		}
	}
	
	return (BOOL)resultFlag;
}

// ----------------------------------------------------------------------
-(BOOL) requestModelCode; {	
	
	Boolean resultFlag = FALSE;
	
	if (serialFileDescriptor != kSerialErrReturn) {
		
				resultFlag = SendQueryToSerialPort (serialFileDescriptor, kSartoriusRequestScaleModelCode, responseBuffer, bufferSize);
		
		if (resultFlag) {
			
			// convert response to NSString
			modelCode = [NSString stringWithCString:responseBuffer encoding:[NSString defaultCStringEncoding]];
			
		}
	}
	
	return (BOOL)resultFlag;
}


// ----------------------------------------------------------------------
-(void) tare; {
    
    [self writeSerialOut:kSartoriusTareCode];
    [ self postNotification];
}

// ----------------------------------------------------------------------

-(void) setVeryStable; {
    
    [self writeSerialOut:kSartoriusVeryStableCode];
    [ self postNotification];

}

// ----------------------------------------------------------------------

-(void) setStable; {
    
    [self writeSerialOut:kSartoriusStableCode];
    [ self postNotification];

}

// ----------------------------------------------------------------------

-(void) setUnstable; {
    
    [self writeSerialOut:kSartoriusUnstableCode];
    [ self postNotification];

}

// ----------------------------------------------------------------------

-(void) setVeryUnstable; {
    
    [self writeSerialOut:kSartoriusVeryUnstableCode];
    [ self postNotification];

}

// ----------------------------------------------------------------------


-(void)toggleFakeReading; {

    fakeReading = !fakeReading;
}

// ----------------------------------------------------------------------

-(void) stopReadBalance; {
    
    continueReading = FALSE;

}

// ----------------------------------------------------------------------


-(void)postNotification; {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:kBarBalanceReadingDidChangeNotification
                                      object:self];
}

// ----------------------------------------------------------------------

-(void)respondToTimer:(NSTimer *)timer; {
    
    if ([self readBalance]) {
        // compare the current weight with the last time we reported a new weight
        // post notification that weight has changed IF:
        // the weight has changed perceptably (> kMinimumReporteableWeightChange)
        // OR
        // the stability of the weight has changed (ie. the balance was unstable at last reading, now it is stable)
        
        if ((fabs(curr_weight - last_reported_weight) > kMinimumReporteableWeightChange)
            ||
            (curr_weight_stable != last_reported_stability)
            ) {
            
            // report the current weight
            last_reported_weight = curr_weight;
            last_reported_stability = curr_weight_stable;
            
            [self postNotification];
          
        }
        
    }
}
-(BOOL) readBalance; {
		
   // if (debug_log){ NSLog(@"Entered ReadBalance"); }
    
    if (serialFileDescriptor != kSerialErrReturn) {
    
        if ([self requestWeight] ) {
            
            if (debug_log) { NSLog(@"ReadBalance: line to decode = %s", responseBuffer); }

            if ([self decodeLine:((unsigned char *)responseBuffer)]) {
                numReadings++;
                return(YES);
            }
        }
    }
    else if ( fakeReading  ){
        
        readingCount++;
        
        if (debug_log && (readingCount % 10 == 0)) { NSLog(@"ReadBalance: about to fakereading count: %lu", readingCount); }
       
        [self makeFakeReading];
         numReadings++;
         return(YES);
        
    }
	
	return(NO);
	
}


// **********************************************************************
// internal methods

-(BOOL) decodeLine:(unsigned char *)buf; {
    
    // from balance input string, extracts curr_weight and sets curr_weight_stable;
    // sets curr_weight_time

	//should be static for asynch call

	// used to sue to find first entry
	//line_length = 0;
	//while (buf[line_length] != '\r') line_length++;
	//buf[line_length] = '\0';
	
	
	size_t buf_length  = strlen((char *)buf);
	size_t buf_start;
	char *last_entry;
	// find beginning of last entry
	//start from end of buffer, and find chars in between two \r chars, or
	// between the start of the buffer and a terminal \r
	
	//line_length = 0;
	//while (buf[line_length] != '\r') line_length++;
	//buf[line_length] = '\0';
	
	
	buf_start = buf_length - 3;
	
	while (buf_start > 0 && buf[buf_start] != '\r') {
		
		buf_start--;
	}
	
	last_entry = (char *)buf + buf_start;
	
	if (strlen(last_entry) > 6) {
		// decode denver
		// sscanf(last_entry,"%hd %s %lf",&unit, &direction, &curr_weight);
		
		// decode sartorious
		// if weight less than zero, " - %lf"
		// if weight greater than zero, " + %lf"
		// if weight equal to zero, then no direction symbol "   %lf"
		// if weight is stable, then unit symbol after weight: e.g., " + %lf g"
		
		if (last_entry[0] == '-') { sscanf(last_entry,"%s %lf", direction, &curr_weight); curr_weight *= -1.0; }
		else if (last_entry[0] == '+') { sscanf(last_entry,"%s %lf", direction, &curr_weight); }
		else { sscanf(last_entry,"%lf", &curr_weight); }
		
		curr_weight_time = [NSDate date];
		curr_weight_stable = [self checkStability:last_entry];
		return(TRUE);
	}
	
	return(FALSE);
}

-(void)makeFakeReading; {
    
  
    curr_weight_time = [NSDate date];
    curr_weight = ([curr_weight_time timeIntervalSince1970] - trunc([curr_weight_time timeIntervalSince1970])) * 1000.0;

    curr_weight_stable = YES;

    
}
// ----------------------------------------------------------------------

-(BOOL) checkStability:(char *)last_entry; {
	
	size_t i;
	
	for (i=0;i<strlen(last_entry);i++) {
		
		if (last_entry[i] == 'g') return(TRUE);
		
	}
	return(FALSE);
	
}

// ----------------------------------------------------------------------



-(BOOL) requestWeight; {
	
	Boolean resultFlag = FALSE;
	
	if (serialFileDescriptor != kSerialErrReturn) {
		
		resultFlag = SendQueryToSerialPort (serialFileDescriptor, kSartoriusRequestWeightCode, responseBuffer, bufferSize);
	}
    
    
    if (debug_log){ NSLog(@"requestWeight serialFileDescriptor= %d, resultFlag = %d",serialFileDescriptor, resultFlag ); }

	
	return (BOOL)resultFlag;
}

// **********************************************************************
// Sleep Notifications
// close the balance when about to sleep, open balance upon waking

- (void) receiveSleepNote: (NSNotification*) note; {
    
    if (debug_log) { NSLog(@"BarBalance receiveSleepNote: %@", [note name]); }
    
    // close the serial port before sleeping
    [self closeBalance];
    
}

// **********************************************************************

- (void) receiveWakeNote: (NSNotification*) note; {
    
    if (debug_log) { NSLog(@"BarBalance receiveWakeNote: %@", [note name]); }
    // open the serial port upon awakening
    [self openBalance];
    
}

// **********************************************************************

- (void) fileSleepNotifications; {
    
    //These notifications are filed on NSWorkspace's notification center, not the default
    // notification center. You will not receive sleep/wake notifications if you file
    //with the default notification center.
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveSleepNote:)
                                                               name: NSWorkspaceWillSleepNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveWakeNote:)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
}


@end
