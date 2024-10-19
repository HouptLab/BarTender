/* ExptInfoController */

// added July 2009

#import <Cocoa/Cocoa.h>

@class BarExperiment;
@class BarDocument;


@interface ExptInfoController : NSWindowController {
	
	
	IBOutlet NSWindow *exptInfoWindow;
 //   IBOutlet NSWindowController *exptInfoWindowController;	
	
	// info tab
	IBOutlet NSTextField *exptCodeView;
	IBOutlet NSTextField *exptNameView;
	IBOutlet NSTextField *exptInvestigatorsView;
	IBOutlet NSTextField *exptProtocolView;
    IBOutlet NSTextField *exptWikiView;
	IBOutlet NSTextField *exptProjCodeView;
    IBOutlet NSTextField *exptProjNameView;
	IBOutlet NSTextView  *exptSummaryView;

	// items tab
	IBOutlet NSTableView *itemsTableView;
	
	IBOutlet NSButton *calcPreference; 
	
	IBOutlet NSPopUpButton *prefItemPopupMenu;
	IBOutlet NSPopUpButton *refItemPopupMenu;
	
	
	
	// radio buttons for %of ref Item, % of total
	IBOutlet NSMatrix *prefTypes;
	
	// groups tab
	IBOutlet NSTableView *groupsTableView;

    // drug tab
    IBOutlet NSTableView *drugsTableView;
	
	// subjects tab
	IBOutlet NSTableView *subjectsTableView;
	IBOutlet NSTextField  *exptSubjectsView;

    NSPopUpButtonCell *groupPopupMenu;

	
	// phases tab
	IBOutlet NSTableView *phasesTableView;
	
	// data tab
	IBOutlet NSTextField  *backupSummaryPathView;
	IBOutlet NSTableView *dailyDataTableView;
    NSPopUpButtonCell *phasePopupMenu;
	

	
	BarDocument *bartender;
	
	BarExperiment *originalExperiment;
        // the original experiment; if editing is successful,
        // originalExperiment gets modified to matched edited theExperiment
    BarExperiment *theExperiment;
        // a copy of the originalExperiment for editing;
        // if successful, then originalExperiment gets modified to matched edited theExperiment

    NSUInteger numDataDays;
    NSMutableArray *dailyDataArray;

	
	// barcodes tab
	// NOTE need to implement printing of barcodes from inside Bartender
	
	// data tab
	// NOTE need to implement posting of data to remote webdav, rss feed, posting html of latest graphs
	 	
}

// initialization of the expt info panel
-(void)setBartender:(BarDocument *)newBartender;


// global buttons
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;

- (IBAction)saveTemplateButtonPressed:(id)sender;
- (IBAction)applyTemplateButtonPressed:(id)sender;

- (void) setTheExperiment:(BarExperiment *)newExpt;
- (void) addItemsToMenu:(NSMenu *)itemMenu;
- (void) setItemPopupMenus;
- (void) setGroupPopupMenu;
- (void) setPhasePopupMenu;

- (BarExperiment *) getExperiment;
- (void) loadTheExpt;


// tab specific buttons

// expt code 
-(IBAction)exptCodeEdited:(id)sender;


// items

- (IBAction)addItem:(id)sender;
- (IBAction)deleteItem:(id)sender;

// groups
- (IBAction)addGroup:(id)sender;
- (IBAction)deleteGroup:(id)sender;

// drugs
- (IBAction)addDrug:(id)sender;
- (IBAction)deleteDrug:(id)sender;


// subjects
-(IBAction)numberOfSubjectsChanged:(id)sender;

- (IBAction)assignGroupsAlternating:(id)sender;
- (IBAction)assignGroupsBlocks:(id)sender;

- (IBAction)printBarcodeLabels:(id)sender;





//phases

- (IBAction)addPhase:(id)sender;
- (IBAction)deletePhase:(id)sender;

// data

// not implemented
// -(IBAction)selectPath:(id)sender;
//-(IBAction)addDailyData:(id)sender;
//-(IBAction)deleteDailyData:(id)sender;
//-(IBAction)editDailyData:(id)sender;

@end
