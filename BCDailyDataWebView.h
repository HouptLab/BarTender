//
//  BCDailyDataWebView.h
//  Bartender
//
//  Created by Tom Houpt on 12/7/16.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "DailyData.h"

@interface BCDailyDataWebView : WebView {
	
	DailyData *dailyData;
	
	NSTableView *tableView;
	
	NSMutableString *htmlString;
	
	BOOL useAlternatingRowColors;
	BOOL useVerticalLines;
	BOOL useHorizontalLines;
	BOOL useCaption;
	BOOL useRowNumbers;
    
    // for printing
//    NSPrintOperation *printOp;
//    NSDocument *printSender;
//    BOOL showPrintPanels;
	
}

- (id) initWithDailyData:(DailyData *)data andTable:(NSTableView *)table;
- (void) appendCssToString:(NSMutableString *)buffer;
- (void) appendDailyDataInfoToString:(NSMutableString *)buffer;
- (void)writeHtmlToPath:(NSString *)path;
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)webFrame;
//- (void)print:(BOOL)showPanels fromDocument:(NSDocument *)sender;

// -(void)print:(id)sender; 
//- (void)drawRect:(NSRect)dirtyRect;


@end
