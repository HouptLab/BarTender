//
//  BartenderAppDelegate.m
//  Bartender
//
//  Created by Tom Houpt on 8/30/12.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import "BartenderAppDelegate.h"
#import "SettingsController.h"
#import "Bartender_Constants.h"

@implementation BartenderAppDelegate

@synthesize aboutWindow;

#define ABOUTBOX_SPLASH_DURATION_SECS 2 

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	
	
	// intialize the about box
 NSBundle *main = [NSBundle mainBundle];
 
 NSDictionary *appDefaults = @{
kBartenderSerialPortNameKey : kBartenderDefaultSerialPortName ,  // all_graphs
kBartenderLocalBackupDirectoryKey : [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] ,  // all_graphs
kBartenderFirebaseDirectoryKey : kBartenderDefaultFirebaseURLString,  // all_graphs
kBartenderBartabURLKey : kBartenderDefaultBartabURLString };
 
 [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
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
      NSString *localDataName = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderLocalBackupDirectoryKey];
        NSString *firebaseName = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebaseDirectoryKey];
             NSString *bartabName = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderBartabURLKey];

     
    NSArray<NSString *> *oldNames = @[serialPortName,localDataName,firebaseName,bartabName];
        // get name from user
        SettingsController *newNameDialog =  [[SettingsController alloc] initWithNameArray:oldNames];
        
        NSArray<NSString *> *names = [newNameDialog dialogForWindow:[NSApp keyWindow]];
        
        NSArray<NSString *> *keys = @[kBartenderSerialPortNameKey,kBartenderLocalBackupDirectoryKey,kBartenderFirebaseDirectoryKey,kBartenderBartabURLKey];
        
         NSArray<NSString *> *defaults = 
         @[kBartenderDefaultSerialPortName, [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]  ,kBartenderDefaultFirebaseURLString,kBartenderDefaultBartabURLString];
        
        
        //TODO: validate new defaults somehow?
        
        for (NSUInteger index = 0; index < [names count]; index++) {
            if (![names[index] isEqualToString:oldNames[index]]){
                [[NSUserDefaults standardUserDefaults] setValue: names[index] forKey:keys[index]];
            }
        }
     
    if (![names[0] isEqualToString:oldNames[0]]){
        // serial port has been resetterm
    // TODO: ask the bardocument to reset the serial port
    }
      
}

@end
