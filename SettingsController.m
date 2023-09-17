//
//  SettingsController.m
//  Bartender
//
//  Created by Tom Houpt on 23/7/8.
//

#import "SettingsController.h"

@implementation SettingsController


@synthesize dialog;
@synthesize serialnameField;
@synthesize serialname;

@synthesize localdataField;
@synthesize localdata;

@synthesize firebaseField;
@synthesize firebase;

@synthesize bartabField;
@synthesize bartab;

-(id)initWithNameArray:(NSArray *)names; {
    
    self = [super init];
    if (self) {
        
        serialname = names[0];
        localdata = names[1];
        firebase = names[2];
        bartab = names[3];
                
        if (!dialog) {
            
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [NSBundle  loadNibNamed:@"SettingsController" owner:self];
    #pragma clang diagnostic pop
    
        }
        
    }
    return self;
    
}


-(NSArray *)dialogForWindow:(NSWindow *)ownerWindow; {
    

    
    [serialnameField setStringValue:serialname];
    [localdataField setStringValue:localdata];
    [firebaseField setStringValue:firebase];
    [bartabField setStringValue:bartab];

    [NSApp beginSheet: dialog
       modalForWindow: ownerWindow
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    
    [NSApp runModalForWindow: dialog];
    
    // See NSApplication Class Reference/runModalSession
    
    [NSApp endSheet:  dialog];
    [dialog orderOut: dialog];
    
    return @[serialname,localdata,firebase,bartab];
    
}


-(IBAction)cancelButtonPressed:(id)sender; {
    
    [NSApp stopModal];
    serialname = nil;

}

-(IBAction)OKButtonPressed:(id)sender; {
    
    [NSApp stopModal];
    serialname = [serialnameField stringValue];
    localdata = [localdataField stringValue];
    firebase = [firebaseField stringValue];
    bartab = [bartabField stringValue];

}


@end
