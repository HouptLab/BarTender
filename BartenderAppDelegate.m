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
#import "ExptQRCodePoster.h"
#import "BarDocument.h"
#import "BarExperiment.h"
#import "BCAlert.h"

#import "Firebase.h"
@import FirebaseAuth;
@import FirebaseCore;

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
        kBartenderBartabURLKey : kBartenderDefaultBartabURLString ,
        kBartenderFirebaseEmailKey:kBartenderDefaultFirebaseEmailString,
        kBartenderFirebasePasswordKey:kBartenderDefaultFirebasePasswordString
        // don't set a default password, make sure we have one...
        // kBartenderFirebasePasswordKey:kBartenderDefaultFirebasePasswordString
        
    };
    
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
    
    
    // initialize Firebase for entire app
    
    [FIRApp configure];
    
    

    [self checkUserDefaults];
}
-(void)checkUserDefaults; {
    
    BOOL allGood = YES;

    allGood &= (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderSerialPortNameKey]);
    allGood &= (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderLocalBackupDirectoryKey]);
    allGood &= (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderBartabURLKey]);

    allGood &= (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebaseDirectoryKey]);
    allGood &= (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebaseEmailKey]);
    allGood &= (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebasePasswordKey]);

    if (!allGood) {

        BCOneButtonAlert(NSAlertStyleInformational, @"Settings incomplete",
                           @"Not all of the Settings have been specified (e.g., serial port location, firebase account info, etc. For full functionality, be sure to fill in the Settings.",
                           @"OK");

        [self enterSerialDeviceName:self];
    }


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
    NSString *bartabName = [[NSUserDefaults standardUserDefaults]  valueForKey:kBartenderBartabURLKey];
    
    NSString *firebaseEmail = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebaseEmailKey];
    
    NSString *firebasePassword = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebasePasswordKey];
    
    
    
    NSArray<NSString *> *oldNames = @[serialPortName,
                                      localDataName,
                                      firebaseName,
                                      bartabName,
                                      firebaseEmail,
                                      firebasePassword];
    
    // get name from user
    SettingsController *newNameDialog =  [[SettingsController alloc] initWithNameArray:oldNames];
    
    NSArray<NSString *> *names = [newNameDialog dialogForWindow:[NSApp keyWindow]];
    
    NSArray<NSString *> *keys = @[kBartenderSerialPortNameKey,
                                  kBartenderLocalBackupDirectoryKey,
                                  kBartenderFirebaseDirectoryKey,
                                  kBartenderBartabURLKey,
                                  kBartenderFirebaseEmailKey,
                                  kBartenderFirebasePasswordKey];
    
    
    
    
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

-(IBAction)qrExptPoster:(id)sender; {
    
    if (nil == _bartender) { return; }
    
    BarExperiment *expt = [_bartender selectedExpt];
    
    if (nil == expt) {  
        BCOneButtonAlert(NSAlertStyleInformational,@"Edit Expt", @"Select an Experiment",@"OK");
        return;
    }
    
    if (nil == _poster) {
        _poster = [[ExptQRCodePoster alloc] init]; 
        
    }
    [_poster setTitle: [NSString stringWithFormat:@"%@: %@", [expt code], [expt name]]];
    [_poster setWikiUrl: [expt wiki]];
    NSString *bartabUrl = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderBartabURLKey];
    
    NSString * exptGraphUrl = [NSString stringWithFormat:@"%@/expt/?id=%@",bartabUrl,[expt code] ];
    
    [_poster setGraphUrl:exptGraphUrl];
    
    [_poster setInvest:[expt investigators]];
    
    [_poster setProtocol:[expt protocol]];
    
    [[_poster posterView] setNeedsDisplay:YES];
    
    
    [_poster makeWindowControllers];
    
    [_poster showWindows];
    
}

@end
