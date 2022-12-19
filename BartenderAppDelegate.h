//
//  BartenderAppDelegate.h
//  Bartender
//
//  Created by Tom Houpt on 8/30/12.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BartenderAppDelegate : NSObject <NSApplicationDelegate> {
	
   //  NSWindow *__weak aboutWindow;
    NSWindow *aboutWindow;

}

//@property (weak) IBOutlet NSWindow *aboutWindow;
@property IBOutlet NSWindow *aboutWindow;
@property IBOutlet NSTextField *versionLabel;
@property IBOutlet NSTextField *copyrightLabel;

@property IBOutlet NSTextField *serialDeviceLabel;

-(IBAction)showAboutBox:(id)sender; 
// display about box
-(void)hideAboutBox:(NSTimer *)aboutTimer;
// hide the aboutbox after a short splash; invoked by a NSTimer 

//- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender;

-(IBAction)enterSerialDeviceName:(id)sender;

@end
