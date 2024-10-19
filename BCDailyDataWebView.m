//
//  BCDailyDataWebView.m
//  Bartender
//
//  Created by Tom Houpt on 12/7/16.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//


#import "BCDailyDataWebView.h"
#import "BarExperiment.h"
#import "BCTableHtmlFormatter.h"
#import "DailyDataMeansHtmlFormatter.h"


@implementation BCDailyDataWebView

-(id)initWithDailyData:(DailyData *)data andTable:(NSTableView *)table; {
	
	NSRect frameRect = NSMakeRect(0,0,10,10);
	// set initial frame very small, so that web view has to increase document size
	// when rendering html
	// we get new size from frame load delegate call
	
	self = [super  initWithFrame:frameRect frameName:nil groupName:nil];
	
	if (self) {
		
		dailyData = data;
		
		tableView = table;
		
        htmlString = [[NSMutableString alloc] init];
                
		// set up the webpreferences to print backgrounds
		
		[self setPreferencesIdentifier:@"DailyDataWebPreferences"];
		
		WebPreferences *prefs = [self preferences];
		
		[prefs setShouldPrintBackgrounds:YES];
		
		// turn off the scroll bars
		[[[self mainFrame] frameView] setAllowsScrolling:NO];
		
		// make us our own load delegate
		[self setFrameLoadDelegate:self];
		
		// construct and load the html
			
        // [htmlString appendString:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">"];

        
        [self appendCssToString:htmlString];
        
        // append daily data expt info 
        [self appendDailyDataInfoToString:htmlString];
        
        // append the daily data table
        BCTableHtmlFormatter *htmlFormatter = [[BCTableHtmlFormatter alloc] initWithTableView:tableView andTableID:@"weightTable"];
        [htmlFormatter appendHtmlToString:htmlString];
        
        // append the comment (if any)
        if (nil != [data comment]) {
            if ([[data comment] length] > 0) {
                
                [htmlString appendString:@"<BR>\r"];
                [htmlString appendString:@"<DIV class = \"dailydata\" >\r"];
                [htmlString appendString:[data comment]];
                [htmlString appendString:@"\r</DIV>\r"];
                
            }
        }
        
        // append the group means table
        if (kWeighingOff == [data currentState] || kUserEditing == [data currentState]) {
            DailyDataMeansHtmlFormatter *meanFormatter = [[DailyDataMeansHtmlFormatter alloc] initWithDailyData:data andTableID:@"meanTable"];
            [meanFormatter appendHtmlToString:htmlString];
        }

        [[self mainFrame] loadHTMLString:htmlString baseURL:nil];
			
//            NSString *testFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0] stringByAppendingPathComponent:@"dailyDataWebViewTest.html"];
//        [self writeHtmlToPath:testFilePath];

//		NSView *frameView = [[self mainFrame] frameView];
//		NSView *docView = [frameView documentView];
//		NSRect webViewRect = [self frame];
//		NSRect frameViewRect = [frameView frame];
//		NSRect docViewRect = [docView frame];
//		
//		NSLog(@"before load? page: %@",NSStringFromRect(docViewRect));
		
}
	
	return self;
	
}

-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)webFrame; {
	
	if ([webFrame isEqual:[self mainFrame]]) {
		
//		NSView *frameView = [[self mainFrame] frameView];
//		NSView *docView = [frameView documentView];
//		NSRect webViewRect = [self frame];
//		NSRect frameViewRect = [frameView frame];
//		NSRect docViewRect = [docView frame];	
//		
		
		NSRect docViewRect = [[[[self mainFrame] frameView] documentView] frame];
	
		NSLog(@"after loading page: %@",NSStringFromRect(docViewRect));

		// NOTE: we should make sure the frame is a minimum width, like the width of the paper page, 
		
		if (docViewRect.size.width < 526) { docViewRect.origin.x = 0; docViewRect.size.width = 526; }
		
		docViewRect.origin.y = 0; 
		
		[self setFrame:docViewRect];

		
	}
//    if (nil != printOp){
//        
//        [printOp setShowsPrintPanel:showPrintPanels];
//        
//        if (showPrintPanels) {
//            // Add accessory view, if needed
//        }
//        
//        // Run operation, which shows the Print panel if showPanels was YES
//        
//        [printSender runModalPrintOperation:printOp
//                            delegate:printSender
//                      didRunSelector:@selector(documentDidRunModalPrintOperation:success:contextInfo:)
//                         contextInfo:NULL];
//        
//        // zero out the print op and the sender
////        printOp = nil;
////        printSender = nil;
//    }
}

//-(void)print:(BOOL)showPanels fromDocument:(NSDocument *)sender; {
//    //
//    //	If you have
//    //
//    //	WebView *myView;
//    //
//    //	Don't print myView, but print [[[myView mainFrame] frameView] documentView].
//    //
//    //	Consider WebView and frameView like NSScrollView. You don't want to
//    //	print the scroll view but its content.
//    //
//
//    
//    showPrintPanels = showPanels;
//    printSender = sender;
//    
//	NSView *printView = [[[self mainFrame] frameView] documentView];
//    	
//    // Construct the print operation and setup Print panel
//    printOp = [NSPrintOperation
//                    printOperationWithView:printView
//                    printInfo:[printSender printInfo]];
//
//    
//    // move rest of printing operation  into the BCDailyDataWebView View:didFinishLoadForFrame: method,
//    // so that printing is completed only after the webview finishes loading the html
//    // (apparently has time to load in debug mode, but in release mode the printing starts
//    // without the html loading completely, so we get a blank document...
//	
//  
//}

//<HEAD>
//<TITLE>How to Carve Wood</TITLE>
//<STYLE type="text/css">
//BODY {text-align: center}
//</STYLE>
//<BODY>
//...the body is centered...
//</BODY>

-(void)appendCssToString:(NSMutableString *)buffer; { }

-(void) appendDailyDataInfoToString:(NSMutableString *)buffer; {
	
	// expt_code: expt_name
	[buffer appendFormat:@"<P><STRONG><BIG>%@</BIG></STRONG></P>\r",[[dailyData theExperiment] codeName]];
	
	[buffer appendString:@"<Style> \r"];
	[buffer appendFormat: @".dailydata td {font-family: Helvetica, sans-serif; font-size:9pt;} \r"];
	[buffer appendString:@"</Style> \r"];
	
	
	[buffer appendString:@"<TABLE class = \"dailydata\" >\r"];
	
	// Days completed: expt_days
	[buffer appendFormat:@"\t<TR><TD>Experiment Day %ld </TD></TR>\r", [dailyData exptDayIndex] + 1];
	// increment by 1 to make 1-indexed
	// this is the actual day of the current dailyData, e.g. it's position in the dailyData Array
	// if for weighing on (i.e. weighing off is still pending), the exptDayIndex is the index of the next day to be added
	
	// Phase: phase name; Day phase_day
	NSString *phaseLabel;
	
	if ([[dailyData phaseName] isEqualToString:@"<none>"]) {phaseLabel = kNoDataCellText; }
	else { phaseLabel = [NSString stringWithFormat: @"Phase: %@, Day %ld", [dailyData phaseName], [dailyData phaseDayIndex]+1]; }

	[buffer appendFormat:@"\t<TR><TD>%@ </TD></TR>\r", phaseLabel];
	 
	 // weighed on:
	 [buffer appendFormat:@"\t<TR><TD>Weighed on: %@</TD></TR>\r", [dailyData onTimeString]];
	 
	 // weighed off:
	 [buffer appendFormat:@"\t<TR><TD>Weighed off: %@</TD></TR>\r", [dailyData offTimeString]];
	
	 [buffer appendString:@"</TABLE>\r"];
	
	  [buffer appendString:@"<BR>\r"];
}

-(void)writeHtmlToPath:(NSString *)path; {
    
    NSError *error;
    
    if (nil == htmlString || nil == path) return;
    
    [htmlString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];

    if (nil != error)  {
        NSLog(@"BCDailyDataWebView writeHtmlToPath Error Desc: %@",[error localizedDescription]);
        NSLog(@"BCDailyDataWebView writeHtmlToPath Error Sugg: %@",[error  localizedRecoverySuggestion]);
    }
    
}

// from http://cocoadev.com/wiki/NSStringCategory
// Replaces all XML reserved chars with entities; replaces \n or \r with <BR>
// for all entities see http://www.w3.org/TR/html4/sgml/entities.html

- (NSString *)stringSafeForXML:(NSString *)aString; {
    
    NSMutableString *str = [NSMutableString  stringWithString:aString];
    [str replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange (0, [str length])];
    [str replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange (0, [str length])];
    [str replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange (0, [str length])];
    [str replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange (0, [str length])];
    [str replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSLiteralSearch range:NSMakeRange (0, [str length])];

    [str replaceOccurrencesOfString:@"\n" withString:@"<BR>\r" options:NSLiteralSearch range:NSMakeRange (0, [str length])];
    [str replaceOccurrencesOfString:@"\r" withString:@"<BR>\r"  options:NSLiteralSearch range:NSMakeRange (0, [str length])];

    return str;
}
@end
