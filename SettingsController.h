//
//  SettingsController.h
//  Bartender
//
//  Created by Tom Houpt on 23/7/8.
//


#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface SettingsController : NSObject

@property IBOutlet NSWindow *dialog;
@property IBOutlet NSTextField *serialnameField;
@property (copy) NSString *serialname;

@property IBOutlet NSTextField *firebaseField;
@property (copy) NSString *firebase;

@property IBOutlet NSTextField *localdataField;
@property (copy) NSString *localdata;

-(id)initWithNameArray:(NSArray *)names;
-(NSArray *)dialogForWindow:(NSWindow *)ownerWindow; 
-(IBAction)cancelButtonPressed:(id)sender;
-(IBAction)OKButtonPressed:(id)sender;


@end
