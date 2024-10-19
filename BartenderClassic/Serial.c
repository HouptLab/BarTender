/*
 *  Serial.c
 *  Blink
 *
 *  Created by Tom Houpt on Wed Oct 06 2004.
 *  Copyright (c) 2004 Behavioral Cybernetics. All rights reserved.
 *
 */

#include "Serial.h"

int FindAndOpenSerialPort(char *targetFilePath);

static kern_return_t FindRS232Port(io_iterator_t *matchingServices);
static kern_return_t GetSerialPath(io_iterator_t serialPortIterator, char *deviceFilePath, char * targetPath, CFIndex maxPathSize);


static char *MyLogString(char *str);
short wildstrncmp(char *subject,char *query,short q_length);

#define kMyErrReturn -1

enum {
    kNumRetries = 3
};

// Hold the original termios attributes so we can reset them
static struct termios gOriginalTTYAttrs;


int FindAndOpenSerialPort(char *targetFilePath) {

	// tries to match the given target file path with a serial port
	// if successful, it opens the serial port and returns a file descriptor
	// otherwise returns -1

	int fileDescriptor = -1;
	kern_return_t result;
	char deviceFilePath[256];
	io_iterator_t serialPortIterator;
	
	result = FindRS232Port(&serialPortIterator);
	if (result == KERN_SUCCESS) {
		result = GetSerialPath(serialPortIterator, deviceFilePath, targetFilePath,256);
		if (result == KERN_SUCCESS) {
			fileDescriptor = OpenSerialPort(deviceFilePath);
		}
	}
	
	return(fileDescriptor);
	
}

static kern_return_t FindRS232Port(io_iterator_t *matchingServices) {

    kern_return_t       kernResult; 
    mach_port_t         masterPort;
    CFMutableDictionaryRef  classesToMatch;

    kernResult = IOMasterPort(MACH_PORT_NULL, &masterPort);

    if (KERN_SUCCESS != kernResult) {
        printf("IOMasterPort returned %d\n", kernResult);
		goto exit;
    }

    // Serial devices are instances of class IOSerialBSDClient.

    classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue);

    if (classesToMatch == NULL) {
		printf("IOServiceMatching returned a NULL dictionary.\n");
    }
    else {

        CFDictionarySetValue(classesToMatch,
                             CFSTR(kIOSerialBSDTypeKey),
                             CFSTR(kIOSerialBSDRS232Type));


        // Each serial device object has a property with key
        // kIOSerialBSDTypeKey and a value that is one of
        // kIOSerialBSDAllTypes, kIOSerialBSDModemType, 
        // or kIOSerialBSDRS232Type. You can experiment with the
		// matching by changing the last parameter in the above call
        // to CFDictionarySetValue.

    }

    kernResult = IOServiceGetMatchingServices(masterPort, classesToMatch, matchingServices);    

    if (KERN_SUCCESS != kernResult) {
        printf("IOServiceGetMatchingServices returned %d\n", kernResult);
		goto exit;
    }
        

exit:

    return kernResult;

}

short wildstrncmp(char *subject,char *query,short q_length) {

	// compare the subject to the query for the first numChars characters
	// query can contain wildchars '*' that match any number of characters (or zero character)
	// if subject doesn't match return failure (1)
	// otherwise return success (0)
	
	short s_length,s_index,q_index;
	char compstring[256];
	
	compstring[0]='\0';
	
	s_length = strlen(subject);
	s_index = 0;
	for (q_index=0;q_index<q_length;q_index++) {
	
		if (subject[s_index] == query[q_index]) {
			compstring[s_index] = subject[s_index];compstring[s_index+1] = '\0'; 
			s_index++;
			if (s_index >= s_length && q_index < q_length-1) return (1); // subject shorter than query
		}
		else if (query[q_index] == '*') { // character doesn't match, but query is a wildcard
			while (subject[s_index] != query[q_index+1] ) {
				// skip characters until we match the charater after the wildcard
				compstring[s_index] = '*';compstring[s_index+1] = '\0'; 
				s_index++;
				if (s_index == s_length) return(1); // subject short than query (or wildcard area too long)
			}
		}
		else return(1); // character doesn't match query at all
	}
	
	return(0);


}


static kern_return_t GetSerialPath(io_iterator_t serialPortIterator, char *deviceFilePath, char * targetPath, CFIndex maxPathSize) {

// given an iterator full of serial devices, get the device file path name as a C string
// (FindRS232Port will have built the iterator full of RS232 ports)
// stick code in here to find a specific device...
// I assume the Keyspan devices will be "/dev/cu.USA28X*P1.1" or "/dev/cu.USA28X*P2.2"
// middle digits are position in usb tree, matched with wildcard

    io_object_t     serialService;
    kern_return_t   kernResult = KERN_FAILURE;
    Boolean     portFound = false;

    // Initialize the returned path
    *deviceFilePath = '\0';    

    // Iterate across all ports found. In this example, we exit after 
    // finding the first port.    

    while ((serialService = IOIteratorNext(serialPortIterator)) && !portFound) {

        CFTypeRef   deviceFilePathAsCFString;

		// Get the callout device's path (/dev/cu.xxxxx). 
		// The callout device should almost always be
		// used. You would use the dialin device (/dev/tty.xxxxx) when 
		// monitoring a serial port for
		// incoming calls, for example, a fax listener.

        

		deviceFilePathAsCFString = IORegistryEntryCreateCFProperty(
									serialService,
									CFSTR(kIOCalloutDeviceKey),
									kCFAllocatorDefault,
									0);

        if (deviceFilePathAsCFString) {

			Boolean result;

        // Convert the path from a CFString to a NULL-terminated C string 
        // for use with the POSIX open() call.            

			result = CFStringGetCString(	deviceFilePathAsCFString,
											deviceFilePath,
											maxPathSize, 
											kCFStringEncodingASCII);

            CFRelease(deviceFilePathAsCFString);           
			
            if (result) {
				printf("BSD path: %s", deviceFilePath);
				// we have a C string with the device path, is it the one we want? 
				
				
				if (wildstrncmp(deviceFilePath,targetPath,strlen(targetPath)) == 0) {
					portFound = true;
					kernResult = KERN_SUCCESS;
				}
            }

        }

        printf("\n");
        // Release the io_service_t now that we are done with it.

		(void) IOObjectRelease(serialService);

    }

    return kernResult;

}

int OpenSerialPort(const char *deviceFilePath) {

    int				fileDescriptor = -1;
    int				handshake;
    struct termios  options;

    // Open the serial port read/write, with no controlling terminal, 
    // and don't wait for a connection.
    // The O_NONBLOCK flag also causes subsequent I/O on the device to 
    // be non-blocking.
    // See open(2) ("man 2 open") for details.

    fileDescriptor = open(deviceFilePath, O_RDWR | O_NOCTTY | O_NONBLOCK);

    if (fileDescriptor == -1) {
        printf("Error opening serial port %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
        goto error;
    }

    // Note that open() follows POSIX semantics: multiple open() calls to 
    // the same file will succeed unless the TIOCEXCL ioctl is issued.
    // This will prevent additional opens except by root-owned processes.
    // See tty(4) ("man 4 tty") and ioctl(2) ("man 2 ioctl") for details.

    if (ioctl(fileDescriptor, TIOCEXCL) == kMyErrReturn) {
        printf("Error setting TIOCEXCL on %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
        goto error;
    }

    // Now that the device is open, clear the O_NONBLOCK flag so 
    // subsequent I/O will block.
    // See fcntl(2) ("man 2 fcntl") for details.
    

    if (fcntl(fileDescriptor, F_SETFL, 0) == kMyErrReturn) {
        printf("Error clearing O_NONBLOCK %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
        goto error;
    }
    
    // Get the current options and save them so we can restore the 
    // default settings later.

    if (tcgetattr(fileDescriptor, &gOriginalTTYAttrs) == kMyErrReturn) {
        printf("Error getting tty attributes %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
        goto error;
    }

    // The serial port attributes such as timeouts and baud rate are set by 
    // modifying the termios structure and then calling tcsetattr to
    // cause the changes to take effect. Note that the
    // changes will not take effect without the tcsetattr() call.
    // See tcsetattr(4) ("man 4 tcsetattr") for details.

    options = gOriginalTTYAttrs;

    // Print the current input and output baud rates.
    // See tcsetattr(4) ("man 4 tcsetattr") for details.    

    printf("Current input baud rate is %d\n", (int) cfgetispeed(&options));
    printf("Current output baud rate is %d\n", (int) cfgetospeed(&options));

	// Set raw input (non-canonical) mode, with reads blocking until either 
    // a single character has been received or a one second timeout expires.
    // See tcsetattr(4) ("man 4 tcsetattr") and termios(4) ("man 4 termios") 
    // for details.

    cfmakeraw(&options);
    options.c_cc[VMIN] = 1;
    options.c_cc[VTIME] = 10;

    // The baud rate, word length, and handshake options can be set as follows:
    cfsetspeed(&options, B9600);   // Set 9600 baud 
	
	// see man termios for bit settings of c_cflag
    options.c_cflag = 0;
	options.c_cflag =   CS8 |		// Use 8 bit words, no parity, 1 stop bit, no flow control
						CREAD |		// receiver is enabled
						CLOCAL;		// connection does not depend on modem status lines
						
				// no parity because PARENB bit not set
				// 1 stop bit because CSTOP bit not set (otherwise would be 2 bits)
				// no flow control because CCTS_OFLOW and CRTS_IFLOW not set
			
	// Print the new input and output baud rates.

    printf("Input baud rate changed to %d\n", (int) cfgetispeed(&options));
    printf("Output baud rate changed to %d\n", (int) cfgetospeed(&options));    

    // Cause the new options to take effect immediately.

    if (tcsetattr(fileDescriptor, TCSANOW, &options) == kMyErrReturn) {
        printf("Error setting tty attributes %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
        goto error;
    }

    // To set the modem handshake lines, use the following ioctls.
    // See tty(4) ("man 4 tty") and ioctl(2) ("man 2 ioctl") for details.
    
    if (ioctl(fileDescriptor, TIOCSDTR) == kMyErrReturn) {
		// Assert Data Terminal Ready (DTR)
        printf("Error asserting DTR %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
	}

    if (ioctl(fileDescriptor, TIOCCDTR) == kMyErrReturn) {
		// Clear Data Terminal Ready (DTR)
        printf("Error clearing DTR %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
    }

    handshake = TIOCM_DTR | TIOCM_RTS | TIOCM_CTS | TIOCM_DSR;

    // Set the modem lines depending on the bits set in handshake.
    if (ioctl(fileDescriptor, TIOCMSET, &handshake) == kMyErrReturn) {
        printf("Error setting handshake lines %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
    }

    
    // To read the state of the modem lines, use the following ioctl.
    // See tty(4) ("man 4 tty") and ioctl(2) ("man 2 ioctl") for details.

	if (ioctl(fileDescriptor, TIOCMGET, &handshake) == kMyErrReturn) {
		// Store the state of the modem lines in handshake.
        printf("Error getting handshake lines %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
    }

	printf("Handshake lines currently set to %d\n", handshake);    
	
	// Success:
    return fileDescriptor;

    // Failure:

error:

    if (fileDescriptor != kMyErrReturn) {
        close(fileDescriptor);
    }
    return -1;

}

void CloseSerialPort(int fileDescriptor) {

    // Block until all written output has been sent from the device.
    // Note that this call is simply passed on to the serial device driver.
    // See tcsendbreak(3) ("man 3 tcsendbreak") for details.

    if (tcdrain(fileDescriptor) == kMyErrReturn) {
        printf("Error waiting for drain - %s(%d).\n", strerror(errno), errno);
    }

	// It is good practice to reset a serial port back to the state in
    // which you found it. This is why we saved the original termios struct
    // The constant TCSANOW (defined in termios.h) indicates that
    // the change should take effect immediately.

    if (tcsetattr(fileDescriptor, TCSANOW, &gOriginalTTYAttrs) ==  kMyErrReturn) {
		printf("Error resetting tty attributes - %s(%d).\n", strerror(errno), errno);
    }

    close(fileDescriptor);

}

 Boolean SendCommandToSerialPort (int fileDescriptor, char *outString, char *responseString) {

    char    buffer[256];    // Input buffer
    char    *bufPtr;        // Current char in buffer
    ssize_t numBytes;       // Number of bytes read or written
    int     tries;          // Number of tries so far

    Boolean result = false;

    for (tries = 1; tries <= kNumRetries; tries++) {
		
       // Send the output command to the serial port
        numBytes = write(fileDescriptor, outString,strlen(outString));
		
		if ( numBytes == kMyErrReturn ) {
            printf("Error writing to modem - %s(%d).\n", strerror(errno), errno);
            continue;
        }
		else { printf("Wrote %d bytes \"%s\"\n", numBytes, MyLogString(outString)); }

		if ( numBytes < strlen(outString) ) { continue; }
/*
        printf("Looking for \"%s\"\n", MyLogString(responseString));

		// for the response, Read characters into our buffer until we get a CR or LF.

        bufPtr = buffer;

        do {
            numBytes = read(fileDescriptor, bufPtr, &buffer[sizeof(buffer)] - bufPtr - 1);

            if (numBytes == kMyErrReturn) { printf("Error reading from modem - %s(%d).\n", strerror(errno), errno); }
            else if (numBytes > 0) {
                bufPtr += numBytes;
                if (*(bufPtr - 1) == '\n' || *(bufPtr - 1) == '\r')  {
                    break;
                }
            }
            else { printf("Nothing read.\n"); }

        } while (numBytes > 0);

        // NULL terminate the string and see if we got a response of OK.
        *bufPtr = '\0';
        printf("Read \"%s\"\n", MyLogString(buffer));

        if (strncmp(buffer, responseString, strlen(responseString)) == 0) {
            result = true;
            break;
        }
		*/
    }
	result = TRUE;
    return result;

}
 Boolean SendQueryToSerialPort (int fileDescriptor, char *outString, char *responseString,short maxResponseLength) {

    char    buffer[256];    // Input buffer
    char    *bufPtr;        // Current char in buffer
    ssize_t numBytes;       // Number of bytes read or written
    int     tries;          // Number of tries so far

    Boolean result = false;

    for (tries = 1; tries <= kNumRetries; tries++) {
		
       // Send the output command to the serial port
        numBytes = write(fileDescriptor, outString,strlen(outString));
		
		if ( numBytes == kMyErrReturn ) {
            printf("Error writing to modem - %s(%d).\n", strerror(errno), errno);
            continue;
        }
		else { printf("Wrote %d bytes \"%s\"\n", numBytes, MyLogString(outString)); }

		if ( numBytes < strlen(outString) ) { continue; }

        printf("Looking for \"%s\"\n", MyLogString(responseString));

		// for the response, Read characters into our buffer until we get a CR or LF.

        bufPtr = buffer;

        do {
            numBytes = read(fileDescriptor, bufPtr, &buffer[sizeof(buffer)] - bufPtr - 1);

            if (numBytes == kMyErrReturn) { printf("Error reading from modem - %s(%d).\n", strerror(errno), errno); }
            else if (numBytes > 0) {
                bufPtr += numBytes;
                if (*(bufPtr - 1) == '\n' || *(bufPtr - 1) == '\r')  {
                    break;
                }
            }
            else { printf("Nothing read.\n"); }

        } while (numBytes > 0);

        // NULL terminate the string and see if we got a response of OK.
        *bufPtr = '\0';
        printf("Read \"%s\"\n", MyLogString(buffer));
		
		if (strlen(buffer) > 0) strncpy(responseString,buffer,maxResponseLength); 

    }
    return result;
}


static char *MyLogString(char *str) {
// print unprintable characters
	static char	 buf[2048];
	char			*ptr = buf;
	int			 i;

	*ptr = '\0';

	while (*str)
	{
		if (isprint(*str))
		{
			*ptr++ = *str++;
		}
		else {
			switch(*str)
			{
			case ' ':
				*ptr++ = *str;
				break;

			case 27:
				*ptr++ = '\\';
				*ptr++ = 'e';
				break;

			case '\t':
				*ptr++ = '\\';
				*ptr++ = 't';
				break;

			case '\n':
				*ptr++ = '\\';
				*ptr++ = 'n';
				break;

			case '\r':
				*ptr++ = '\\';
				*ptr++ = 'r';
				break;

			default:
				i = *str;
				(void)sprintf(ptr, "\\%03o", i);
				ptr += 4;
				break;
			}

			str++;
		}
		*ptr = '\0';
	}
	return buf;
}

