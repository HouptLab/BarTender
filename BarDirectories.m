//
//  BarDirectories.m
//  Bartender
//
//  Created by Tom Houpt on 12/9/24.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import "BarDirectories.h"

// **********************************************************************
// DIRECTORY UTILITIES --------------------------------------------------------------

// returns the directory path to the standard directories
// side effect: creates the directory if it doesn't exist already

BOOL CreateDirectoryAtPath(NSString *directoryPath) {
	
	NSError *fileManagerError;
	BOOL createFlag;
	
	
	NSFileManager *defaultFileManager = [ NSFileManager defaultManager];
	
	createFlag = [defaultFileManager 
				  createDirectoryAtPath:directoryPath
				  withIntermediateDirectories:YES
				  attributes:nil
				  error:&fileManagerError]; //returns YES on success
	
	return createFlag;
	
	
}

NSString *GetDocDirectoryPath(void) {
	
	NSString *docDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];

	if (CreateDirectoryAtPath(docDirectoryPath) ) { return docDirectoryPath; }
	
	return nil;

}

NSString *GetExptDirectoryPath(void) {
	
	// set to the template directory
	// check if the appropriate directories exist, create them if they don't exist
	
	NSString *docDirectoryPath = GetDocDirectoryPath();
	
	NSString *exptDirectoryPath = [docDirectoryPath stringByAppendingPathComponent:@"Bartender/Experiments"];
	
	if (CreateDirectoryAtPath(exptDirectoryPath) ) { return exptDirectoryPath; }
	
	
	return nil;

}

NSString *GetArchiveDirectoryPath(NSString *code) {
	
	// set to the template directory
	// check if the appropriate directories exist, create them if they don't exist
	NSString *docDirectoryPath = GetDocDirectoryPath();
	
	NSString *exptArchiveName = [NSString stringWithFormat:@"Bartender/Archives/%@",code];
	
	NSString *archiveDirectoryPath = [docDirectoryPath stringByAppendingPathComponent:exptArchiveName];
	
	if (CreateDirectoryAtPath(archiveDirectoryPath) ) { return archiveDirectoryPath; }
	
	return nil;
	
}


NSString *GetDailyDataDirectoryPath(void) {
	
	// set to the template directory
	// check if the appropriate directories exist, create them if they don't exist
	NSString *docDirectoryPath = GetDocDirectoryPath();
	NSString *dailyDataDirectoryPath = [docDirectoryPath stringByAppendingPathComponent:@"Bartender/DailyData"];
	
	if (CreateDirectoryAtPath(dailyDataDirectoryPath) ) { return dailyDataDirectoryPath; }
	
	return nil;
	
	
}

NSString *GetTemplateDirectoryPath(void) {
	
	// set to the template directory
	// check if the appropriate directories exist, create them if they don't exist
	NSString *docDirectoryPath = GetDocDirectoryPath();
	NSString *templateDirectoryPath = [docDirectoryPath stringByAppendingPathComponent:@"Bartender/Templates"];
	
	if (CreateDirectoryAtPath(templateDirectoryPath) ) { return templateDirectoryPath; }
	
	return nil;
	
}

