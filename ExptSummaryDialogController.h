//
//  ExptSummaryDialogController.h
//  Bartender
//
//  Created by houpt on 5/27/17.
//
//

#import <Cocoa/Cocoa.h>

@class BarExperiment;
@class BarDocument;


@interface ExptSummaryDialogController : NSWindowController {

    IBOutlet NSWindow *exptSummaryDialogWindow;
    
    IBOutlet NSTextField *exptCode;
    IBOutlet NSTextField *exptName;
    IBOutlet NSButton *okButton;
    IBOutlet NSButton *cancelButton;

    IBOutlet NSButton *includeAllDates;
    IBOutlet NSDatePicker *startDate;
    IBOutlet NSDatePicker *endDate;

    IBOutlet NSButton *item0;
    IBOutlet NSButton *item1;
    IBOutlet NSButton *item2;
    IBOutlet NSButton *item3;
    IBOutlet NSButton *item4;
    IBOutlet NSButton *item5;
    
    NSMutableArray *itemButtons;
    
    IBOutlet NSButton *excludeEmptyColumns;
    
    BarDocument *bartender;
    BarExperiment *theExperiment;


}

// global buttons
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)okButtonPressed:(id)sender;

-(void)setBartender:(BarDocument *)newBartender;
- (void) setTheExperiment:(BarExperiment *)newExpt;

-(void)populateDialog; // set up dialog after window loads


@end
