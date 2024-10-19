#include <Serial.h>#include "ReadBalance.hpp"static short SerialInput = 0;static short SerialOutput = 0;static IOParam SerialParamBlock;#define INPUT_BUFFER_MAX	32768unsigned char InputBuffer[INPUT_BUFFER_MAX];unsigned char *NextInput;double curr_weight = 0;unsigned long curr_weight_time = 0;Boolean curr_weight_stable = FALSE;short unit;char direction[5];char curr_wgt_text[100];unsigned long bufflength = 0;unsigned long numReadings = 0;Boolean continueReading = FALSE;//static DecodeLine(unsigned char *buf);Boolean DecodeLine(unsigned char *buf);static pascal void InputCompletion(ParmBlkPtr paramBlock);static OSErr OpenOneSerialDriver(ConstStr255Param driverName, short *refNum);static OSErr OpenSerialDrivers(ConstStr255Param inName, ConstStr255Param outName, SInt16 *inRefNum, SInt16 *outRefNum);static Boolean SerialArbitrationExists(void);static Boolean DriverIsOpen(ConstStr255Param driverName);void MyRestoreInputBuffer (void);long MyRequestWeight(void);long MyReceiveMessage(void);void MyChangeInputBuffer(void);unsigned char myWeightBuffer[1024];unsigned char myOutputBuffer[1024];Boolean CheckStability(char *last_entry);long WriteSerialOut(char *outtext);void Tare(void);void SetVeryStable(void);void SetStable(void);void SetUnstable(void);void SetVeryUnstable(void);void StopReadBalance(void) {	continueReading = FALSE;}Boolean ReadBalance(void) {	OSErr result;		if (MyReceiveMessage() > 0 ) {			if (DecodeLine((unsigned char *)myWeightBuffer)) {			numReadings++;			return(TRUE);		}	}		return(FALSE);}static unsigned long line_length;Boolean DecodeLine(unsigned char *buf)//should be static for asynch call{	// used to sue to find first entry	//line_length = 0;	//while (buf[line_length] != '\r') line_length++;	//buf[line_length] = '\0';		// terminate the line with a NULL character	long buf_length  = strlen((char *)buf);	long buf_start;	char *last_entry;	// find beginning of last entry	//start from end of buffer, and find chars in between two \r chars, or	// between the start of the buffer and a terminal \r		//line_length = 0;	//while (buf[line_length] != '\r') line_length++;	//buf[line_length] = '\0';			buf_start = buf_length - 3;		while (buf_start > 0 && buf[buf_start] != '\r') {			buf_start--;	}		last_entry = (char *)buf + buf_start;		if (strlen(last_entry) > 6) {		// decode denver		// sscanf(last_entry,"%hd %s %lf",&unit, &direction, &curr_weight);				// decode sartorious		sscanf(last_entry,"%s %lf", &direction, &curr_weight);		if (direction[0] == '-') curr_weight *= -1.0;		curr_weight_time = SecsNow();		curr_weight_stable = CheckStability(last_entry);		return(TRUE);	}				return(FALSE);}Boolean CheckStability(char *last_entry) {short i;	for (i=0;i<strlen(last_entry);i++) {				if (last_entry[i] == 'g') return(TRUE);		}	return(FALSE);}static pascal void InputCompletion(ParmBlkPtr paramBlock){		OSErr result;		if (SerialParamBlock.ioResult == noErr) {			bufflength = NextInput - InputBuffer;				if (*NextInput == '\r') {			DecodeLine(InputBuffer);			NextInput = InputBuffer;			result = SerReset(SerialInput, baud9600 | stop20 | noParity | data8);		} 		else if (NextInput - InputBuffer < INPUT_BUFFER_MAX) {			NextInput++;								}	}		if (continueReading) {				// launch another asynchronous read...			SerialParamBlock.ioCompletion	= NewIOCompletionProc (InputCompletion);		SerialParamBlock.ioVRefNum		= 0;		SerialParamBlock.ioRefNum		= SerialInput;		SerialParamBlock.ioBuffer		= (char *)NextInput;		SerialParamBlock.ioReqCount		= 1;		SerialParamBlock.ioPosMode		= 0;		SerialParamBlock.ioPosOffset	= fsAtMark;		result = PBReadAsync((ParmBlkPtr)&SerialParamBlock);	}		}OSErr OpenBalance(void){	OSErr result;	SerShk flags = {0, 1, 0, 0, 0, 0, 0, 1};		result = OpenSerialDrivers("\p.AIn", "\p.AOut", &SerialInput,&SerialOutput);	if (result != noErr) goto error;	//	result = OpenDriver ("\p.AIn",  &SerialInput);//	if (result != noErr) goto error;//	result = OpenDriver ("\p.AOut", &SerialOutput);	//if (result != noErr) goto error;	       SerShk mySerShkRec;                 mySerShkRec.fXOn = 0;  //turn off XON/XOFF output flow control         mySerShkRec.fCTS = 0;  //turn off CTS/DTR flow control          mySerShkRec.errs = 0; //clear error mask          mySerShkRec.evts = 0; //clear event mask          mySerShkRec.fInX = 0; //turn off XON/XOFF input flow control          mySerShkRec.fDTR = 0; //turn off DTR input flow control    	//result = Control(SerialOutput, 14, &flags);	result = Control(SerialOutput, 14, &mySerShkRec);	if (result != noErr) goto error;	// dafault is what we want.		// works for Denver	//result = SerReset(SerialInput, baud9600 | stop20 | noParity | data8);	//if (result != noErr) goto error;	//result = SerReset(SerialOutput, baud9600 | stop20 | noParity | data8);	//if (result != noErr) goto error;		//works for sartorius	result = SerReset(SerialInput, baud9600 | stop10 | oddParity | data7);	if (result != noErr) goto error;	result = SerReset(SerialOutput, baud9600 | stop10 | oddParity | data7);	if (result != noErr) goto error;		MyChangeInputBuffer();	NextInput = InputBuffer;			// set it to very stable...		SetVeryStable();	/*	SerialParamBlock.ioCompletion	= NewIOCompletionProc (InputCompletion);	SerialParamBlock.ioVRefNum		= 0;	SerialParamBlock.ioRefNum		= SerialInput;	SerialParamBlock.ioBuffer		= (char *)NextInput;	SerialParamBlock.ioReqCount		= 1;	SerialParamBlock.ioPosMode		= 0;	SerialParamBlock.ioPosOffset	= fsAtMark;		result = PBReadAsync((ParmBlkPtr)&SerialParamBlock);	if (result != noErr) goto error;*/		goto exit;	error:	(void) CloseBalance();exit:	return result;}void CloseBalance(void){OSErr err;	MyRestoreInputBuffer();	if (SerialInput != 0) {		err = KillIO(SerialInput);		err = CloseDriver(SerialInput);		SerialInput = 0;	}		if (SerialOutput != 0) {		err = KillIO(SerialOutput);		err = CloseDriver(SerialOutput);		SerialOutput = 0;	}}Handle gInputBufHandle;unsigned long kInputBufSize = 32768; // size of my input buffer in bytesvoid MyChangeInputBuffer(void) {// Replace the default input buffer with a larger buffer.}   gInputBufHandle = NewHandle(kInputBufSize); //allocate storage   HLock(gInputBufHandle); //lock it   SerSetBuf(SerialInput, *gInputBufHandle, kInputBufSize); //set the buffer}long MyRequestWeight(void) { return(WriteSerialOut("\33P\r\n")); }long WriteSerialOut(char *outtext) {//{Use the Device Manager PBWrite function to write data to the output driver.} //char myBuffer[1024]; //       {a buffer to receive the data}  long myWriteCount; //      {number of bytes to read}  IOParam myParamBlock; // {parameter block for the PBWritefunction}  OSErr err;			   myOutputBuffer[0] = '\0';   strcpy((char *)myOutputBuffer,outtext);   CtoPstr((char *)myOutputBuffer);   myWriteCount  = 4;      	   if (myWriteCount > 0) {       	myParamBlock.ioRefNum = SerialOutput; //write to the output driver}        myParamBlock.ioBuffer = (char *)myOutputBuffer; // pointer to my data buffer}        myParamBlock.ioReqCount = myWriteCount; // number of bytes to write}        myParamBlock.ioCompletion = NULL;      // no completion routine specified}        myParamBlock.ioVRefNum = 0;           // not used by the Serial Driver}        myParamBlock.ioPosMode = 0;           // not used by the Serial Driver}                  err = PBWrite((ParmBlkPtr)(&myParamBlock), FALSE); // synchronousDeviceManagerrequest		if (err != noErr) {			SysBeep(0);		}		if (myWriteCount != 4) {			SysBeep(0);		}		}				return(myWriteCount);}long MyReceiveMessage(void)//{Use the Device Manager PBRead function to read data from the input driver.}{ //char myBuffer[1024]; //       {a buffer to receive the data}  long myReadCount,oldReadCount; //      {number of bytes to read}  IOParam myParamBlock; // {parameter block forthePBReadfunction}  OSErr err;  unsigned long start,wait;    err = KillIO(SerialInput);    MyRequestWeight();	   myWeightBuffer[0] = '\0';        start = SecsNow();   do {   	    myReadCount  = 0;	    	   	err = SerGetBuf(SerialInput,&myReadCount); 	   	//determine how many bytes are in the input buffer	   	wait = SecsNow() - start;	} while (wait < 5 && myReadCount < 16);      if (myReadCount > 0) {       	myParamBlock.ioRefNum = SerialInput; //read from the input driver}        myParamBlock.ioBuffer = (char *)myWeightBuffer; // pointer to my data buffer}        myParamBlock.ioReqCount = myReadCount; // number of bytes to read}        myParamBlock.ioCompletion = NULL;      // no completion routine specified}        myParamBlock.ioVRefNum = 0;           // not used by the Serial Driver}        myParamBlock.ioPosMode = 0;           // not used by the Serial Driver}                  err = PBRead((ParmBlkPtr)(&myParamBlock), FALSE); // synchronousDeviceManagerrequest			myWeightBuffer[myReadCount] = '\0';		}		return(myReadCount);}void MyRestoreInputBuffer (void)// Restore the default input buffer.{   SerSetBuf(SerialInput, *gInputBufHandle, (short)0); // 0 means restore default   HUnlock(gInputBufHandle); //release my old buffer}static OSErr OpenOneSerialDriver(ConstStr255Param driverName, short *refNum)    // The one true way of opening a serial driver.  This routine    // tests whether a serial port arbitrator exists.  If it does,    // it relies on the SPA to do the right thing when OpenDriver is called.    // If not, it uses the old mechanism, which is to walk the unit table    // to see whether the driver is already in use by another program.{    OSErr err;        if ( SerialArbitrationExists() ) {        err = OpenDriver(driverName, refNum);    } else {        if ( DriverIsOpen(driverName) ) {            err = portInUse;        } else {            err = OpenDriver(driverName, refNum);        }    }    return err;}static OSErr OpenSerialDrivers(ConstStr255Param inName, ConstStr255Param outName,                                 SInt16 *inRefNum, SInt16 *outRefNum)    // Opens both the input and output serial drivers, and returns their    // refNums.  Both refNums come back as an illegal value (0) if we    // can't open either of the drivers.{    OSErr err;        err = OpenOneSerialDriver(outName, outRefNum);    if (err == noErr) {        err = OpenOneSerialDriver(inName, inRefNum);        if (err != noErr) {            (void) CloseDriver(*outRefNum);        }    }    if (err != noErr) {        *inRefNum = 0;        *outRefNum = 0;    }    return err;}/*The above code opens the output serial driver before opening the input serial driver.This is the recommended order for the built-in serial drivers, and consequently forother CRM-registered serial drivers. This is because the output driver is the onethat reserves system resources and actually checks for the availability of the port.For the built-in serial ports, if you successfully open the output driver, you should always be able to open the input driver. Not all CRM-registered serial drivers work this way, however, so your code shouldalways check the error result from both opens.The code for determining whether a serial port arbitrator is installed is shown below:*/enum {    gestaltSerialPortArbitratorAttr = 'arb ',            gestaltSerialPortArbitratorExists = 0};static Boolean SerialArbitrationExists(void)    // Test Gestalt to see if serial arbitration exists    // on this machine.{    Boolean result;    long    response;        result = ( Gestalt(gestaltSerialPortArbitratorAttr, &response) == noErr &&                (response & (1 << gestaltSerialPortArbitratorExists) != 0)  != 0);    return result;}static Boolean DriverIsOpen(ConstStr255Param driverName)    // Walks the unit table to determine whether the    // given driver is marked as open in the table.    // Returns false if the driver is closed, or does    // not exist.{    Boolean     found;    Boolean     isOpen;    short       unit;    DCtlHandle  dceHandle;    StringPtr   namePtr;        found = false;    isOpen = false;        unit = 0;       while ( ! found && ( unit < LMGetUnitTableEntryCount() ) ) {            // Get handle to a device control entry.  GetDCtlEntry        // takes a driver refNum, but we can convert between        // a unit number and a driver refNum using bitwise not.                dceHandle = GetDCtlEntry( ~unit );                if ( dceHandle != nil && (**dceHandle).dCtlDriver != nil ) {                    // If the driver is RAM based, dCtlDriver is a handle,            // otherwise it's a pointer.  We have to do some fancy            // casting to handle each case.  This would be so much            // easier to read in Pascal )-:                        if ( ((**dceHandle).dCtlFlags & dRAMBasedMask) != 0 ) {                namePtr = & (**((DRVRHeaderHandle) (**dceHandle).dCtlDriver)).drvrName[0];            } else {                namePtr = & (*((DRVRHeaderPtr) (**dceHandle).dCtlDriver)).drvrName[0];            }                // Now that we have a pointer to the driver name, compare            // it to the name we're looking for.  If we find it,            // then we can test the flags to see whether it's open or            // not.                        if ( EqualString(driverName, namePtr, false, true) ) {                found = true;                isOpen = ((**dceHandle).dCtlFlags & dOpenedMask) != 0;            }        }        unit += 1;    }        return isOpen;}void Tare(void) {	WriteSerialOut("\33T\r\n");}void SetVeryStable(void) {	WriteSerialOut("\33K\r\n");}void SetStable(void) {	WriteSerialOut("\33L\r\n");}void SetUnstable(void) {	WriteSerialOut("\33M\r\n");}void SetVeryUnstable(void) {	WriteSerialOut("\33N\r\n");}