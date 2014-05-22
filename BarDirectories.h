//
//  BarDirectories.h
//  Bartender
//
//  Created by Tom Houpt on 12/9/24.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>



// **********************************************************************
// DIRECTORY UTILITIES --------------------------------------------------------------

// returns the directory path to the standard directories
// side effect: creates the directory if it doesn't exist already


BOOL CreateDirectoryAtPath(NSString *directoryPath);
NSString *GetDocDirectoryPath(void);
NSString *GetExptDirectoryPath(void);
NSString *GetDailyDataDirectoryPath(void);
NSString *GetArchiveDirectoryPath(NSString *code);
NSString *GetTemplateDirectoryPath(void);
