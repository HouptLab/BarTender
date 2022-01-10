//
//  BartenderAppDelegate.m
//  Bartender
//
//  Created by Tom Houpt on 8/30/12.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import "BartenderAppDelegate.h"


@implementation BartenderAppDelegate

@synthesize aboutWindow;

#define ABOUTBOX_SPLASH_DURATION_SECS 2 

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	
	
	// intialize the about box
 NSBundle *main = [NSBundle mainBundle];
    
    [self.versionLabel setStringValue:[NSString stringWithFormat:@"Version %@ (%@)",  [main objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [main objectForInfoDictionaryKey:@"CFBundleVersion"]] ];

    [self.copyrightLabel setStringValue: [main objectForInfoDictionaryKey:@"NSHumanReadableCopyright"]];
	
	[aboutWindow center];
	[aboutWindow makeKeyAndOrderFront:nil];
	
	// hide the about window after some interval?
	//	call [aboutWindow orderOut:nil] to hide the aboutWindow
	
	NSTimeInterval displayTime = ABOUTBOX_SPLASH_DURATION_SECS; // display for, e.g., 2 seconds
	//(NSInvocation *)invocation // set this to [aboutWindow OrderOut:nil];
	
	[NSTimer scheduledTimerWithTimeInterval:displayTime  target:self selector:@selector(hideAboutBox:) userInfo:NULL repeats:NO];
		
}

-(IBAction)showAboutBox:(id)sender; {
	
	[aboutWindow center];
	[aboutWindow makeKeyAndOrderFront:nil];
}

-(void)hideAboutBox:(NSTimer *)aboutTimer; {
	// hide the about window after some interval?
	//	call [aboutWindow orderOut:nil] to hide the aboutWindow
	
	[aboutWindow orderOut:nil];
	//	[aboutTimer release];
	
}

//- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
//{
//	return NO;
//}
//
@end
