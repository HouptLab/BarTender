//
//  BCBarcodeLabelsWebView.h
//  Bartender
//
//  Created by Tom Houpt on 12/7/16.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "BarExperiment.h"

@interface BCBarcodeLabelsWebView : WebView {
		
	BarExperiment *experiment;
    NSString *exptCode;
    NSArray *itemCodes;
    NSUInteger subjectsCount;
	
	NSMutableString *htmlString;
    
    // for printing
//    NSPrintOperation *printOp;
//    NSDocument *printSender;
//    BOOL showPrintPanels;
	
}

- (id) initWithExptCode:(NSString *)ec andItemCodes:(NSArray *)ic forSubjectsCount:(NSUInteger)sc;
- (void) appendCssToString:(NSMutableString *)buffer;
- (void) writeHtmlToPath:(NSString *)path;
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)webFrame;
//- (void)print:(BOOL)showPanels fromDocument:(NSDocument *)sender;

// -(void)print:(id)sender; 
//- (void)drawRect:(NSRect)dirtyRect;


@end
