//
//  BCBarcodeLabelsWebView.m
//  Bartender
//
//  Created by Tom Houpt on 12/7/16.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//


#import "BCBarcodeLabelsWebView.h"
#import "BCBarcodeLabelsHtmlFormatter.h"
#import "BarItem.h"


@implementation BCBarcodeLabelsWebView

- (id) initWithExptCode:(NSString *)ec andItemCodes:(NSArray *)ic forSubjectsCount:(NSUInteger)sc; {
	
	NSRect frameRect = NSMakeRect(0,0,10,10);
	// set initial frame very small, so that web view has to increase document size
	// when rendering html
	// we get new size from frame load delegate call
	
	self = [super  initWithFrame:frameRect frameName:nil groupName:nil];
	
	if (self) {
		
		exptCode = ec;
        itemCodes = ic;
        subjectsCount = sc;

        htmlString = [[NSMutableString alloc] init];
        
        
		// set up the webpreferences to print backgrounds
		
		[self setPreferencesIdentifier:@"BarcodeLabelsWebPreferences"];
		
		WebPreferences *prefs = [self preferences];
		
		[prefs setShouldPrintBackgrounds:YES];
		
		// turn off the scroll bars
		[[[self mainFrame] frameView] setAllowsScrolling:NO];
		
		// make us our own load delegate
		[self setFrameLoadDelegate:self];
		
		
		// construct and load the html
		
        // do we need the doctype string? I don't think so
        // [htmlString appendString:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">"];

        // append any local CSS
        [self appendCssToString:htmlString];
                    
        
        // format the expt info as barcode html
        BCBarcodeLabelsHtmlFormatter *htmlFormatter = [[BCBarcodeLabelsHtmlFormatter alloc]
                initWithExptCode:exptCode
                andItemCodes:itemCodes
                forSubjectsCount:subjectsCount
                ];
        
        [htmlFormatter appendHtmlToString:htmlString];
        
        [[self mainFrame] loadHTMLString:htmlString baseURL:nil];
			
        // write html to a file for debugging
        NSString *testFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0] stringByAppendingPathComponent:@"barcodeLabelsWebViewTest.html"];
        [self writeHtmlToPath:testFilePath];

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


-(void)writeHtmlToPath:(NSString *)path; {
    
    NSError *error;
    
    if (nil == htmlString || nil == path) return;
    
    [htmlString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];

    if (nil != error)  {
        NSLog(@"BCBarcodeLabelsWebView writeHtmlToPath Error Desc: %@",[error localizedDescription]);
        NSLog(@"BCBarcodeLabelsWebView writeHtmlToPath Error Sugg: %@",[error  localizedRecoverySuggestion]);
    }
    
}
@end
