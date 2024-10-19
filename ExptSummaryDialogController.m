//
//  ExptSummaryDialogController.m
//  Bartender
//
//  Created by houpt on 5/27/17.
//
//

#import "ExptSummaryDialogController.h"
#import "BarExperiment.h"
#import "DailyData.h"
#import "BarDocument.h"
#import	"BarSubject.h"
#import	"BarItem.h"
#import "BarGroup.h"
#import	"BarPhase.h"
#import "BarDirectories.h"
#import "DailyDataDocument.h"


@interface ExptSummaryDialogController ()

@end

@implementation ExptSummaryDialogController

- (id)initWithExperiment:(BarExperiment *)theExpt;
{
    self = [super initWithWindowNibName:@"ExptSummaryDialog"];
    if (self) {
        // Initialization code here.
        
        [self setTheExperiment:theExpt];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    itemButtons = [NSMutableArray arrayWithArray:@[item0,item1,item2,item3,item4,item5]];
    [self populateDialog];
}


- (void)setTheExperiment:(BarExperiment *)newExpt {
	// set the values in the new expt panel
	// using the values in the given expt
	
	theExperiment = newExpt;
    

    
}


-(void)populateDialog; // set up dialog after window loads
{

    [exptName setStringValue:[theExperiment name]];
	[exptCode setStringValue: [theExperiment code]];
    
    
    NSUInteger numItems = [[theExperiment items] count];
    
    if (numItems > 6) { numItems = 6;}
    
    for (NSUInteger i=0; i < numItems; i++) {
        
        BarItem *item = [[theExperiment items] objectAtIndex:i];
        
        NSString *itemLabel = [NSString stringWithFormat:@"%@: %@", [item code],[item name] ];
        
        [[itemButtons objectAtIndex:i] setStringValue:itemLabel];
    }
    for (NSUInteger i=numItems; i < 6; i++) {
        
        [[itemButtons objectAtIndex:i] setVisible:NO];
        
    }
    
    
}


- (IBAction)cancelButtonPressed:(id)sender {
	
	// NOTE -- need to implement this as a real cancel button...
	
    // user cancelled, so just close the window without exporting summary

	
    NSLog(@"Expt Summary Dialog Cancel Button pressed");
    
    [[self window] performClose:self];
	

	
    
}
- (IBAction)okButtonPressed:(id)sender {
	
	// NOTE -- need to implement this as a real cancel button...
	
    // user cancelled, so just close the window without exporting summary
    
	
    NSLog(@"Expt Summary Dialog ok Button pressed");
    
    [[self window] performClose:self];
	
    // export the summary file
    
	
    
}



@end
