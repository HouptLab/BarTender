/*
 *  Serial.h
 *  Blink
 *
 *  Created by Tom Houpt on Wed Oct 06 2004.
 *  Copyright (c) 2004 Behavioral Cybernetics. All rights reserved.
 *
 */

#include <Carbon/Carbon.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <paths.h>
#include <termios.h>
#include <sysexits.h>
#include <sys/param.h>
#include <sys/select.h>
#include <sys/time.h>
#include <time.h>

#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>

int OpenSerialPort(const char *deviceFilePath);
void CloseSerialPort(int fileDescriptor);
Boolean SendCommandToSerialPort (int fileDescriptor, char *outString, char *response);
Boolean SendQueryToSerialPort (int fileDescriptor, char *outString, char *responseString,short maxResponseLength);

