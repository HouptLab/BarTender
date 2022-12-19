//
//  BartenderAppDelegate.m
//  Bartender
//
//  Created by Tom Houpt on 8/30/12.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import "BartenderAppDelegate.h"
#import "SerialPortNameController.h"
#define kBartenderSerialPortNameKey @"BartenderSerialPortName"

@implementation BartenderAppDelegate

@synthesize aboutWindow;

#define ABOUTBOX_SPLASH_DURATION_SECS 2 

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	
	
	// intialize the about box
 NSBundle *main = [NSBundle mainBundle];
    
    [self.versionLabel setStringValue:[NSString stringWithFormat:@"Version %@ (%@)",  [main objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [main objectForInfoDictionaryKey:@"CFBundleVersion"]] ];

    [self.copyrightLabel setStringValue: [main objectForInfoDictionaryKey:@"NSHumanReadableCopyright"]];
    
    
         [self setSerialPortLabel];
	
	[aboutWindow center];
	[aboutWindow makeKeyAndOrderFront:nil];
	
	// hide the about window after some interval?
	//	call [aboutWindow orderOut:nil] to hide the aboutWindow
	
	NSTimeInterval displayTime = ABOUTBOX_SPLASH_DURATION_SECS; // display for, e.g., 2 seconds
	//(NSInvocation *)invocation // set this to [aboutWindow OrderOut:nil];
	
	[NSTimer scheduledTimerWithTimeInterval:displayTime  target:self selector:@selector(hideAboutBox:) userInfo:NULL repeats:NO];
		
}

-(void)setSerialPortLabel; {
 NSString *serialPortName = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderSerialPortNameKey];
     
     NSString *defaultName = (nil == serialPortName || 0 == [serialPortName length]) ? @"none" : serialPortName;
     
    [self.serialDeviceLabel setStringValue: defaultName];
	
    
}
-(IBAction)showAboutBox:(id)sender; {
	
  [self setSerialPortLabel];
	
       
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



-(IBAction)enterSerialDeviceName:(id)sender; {

    NSString *serialPortName = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderSerialPortNameKey];
     
     NSString *defaultName = (nil == serialPortName) ? @"cu.usbserial" : serialPortName;
     
    
        // get name from user
        SerialPortNameController *newNameDialog =  [[SerialPortNameController alloc] initWithName:defaultName];
        NSString *newSerialPortName = [newNameDialog dialogForWindow:[NSApp keyWindow]];
        
        if (nil == serialPortName || 0 == [serialPortName length]) {
                 [[NSUserDefaults standardUserDefaults] setValue: nil forKey:kBartenderSerialPortNameKey];        
        }
        else {

        [[NSUserDefaults standardUserDefaults] setValue: newSerialPortName forKey:kBartenderSerialPortNameKey];
        }
        
    
      
}

@end
