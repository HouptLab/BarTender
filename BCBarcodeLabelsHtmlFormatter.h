//
//  BCBarcodeLabelsHtmlFormatter.h
//  Bartender
//
//  Created by Tom Houpt on 12/7/15.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// table cells without stringValue are given text @"--"
// unless headerCell stringValue is @"" (blank column name), 
// in which case the cells are made blank (@"  ")

#define kBlankCellText @"&nbsp"
#define kNoDataCellText @"--"

#define kCellWidthInches 1.85in
#define kBarcodeCellHeightInches 0.5in
#define kPlaintextCellHeightInches 0.2in
#define kBarcodeFontSize 36pt
#define kPlaintextFontSize 18pt


#define kNumColumns 3
#define kNumSubjectsPerPage 10



// each cell should should be 2.0 inches wide by 0.75 inches high
// border of cell should be thin dotted lines (for cutting)
// label text should be centered in the cell in 2 lines:
// barcode line should  3of9  font at 36 pt (FRE3OF9X.TTF  from http://www.free-barcode-font.com is what we use on Macs)
// format of barcode line:
// @"*%@%3lud%@*", exptCode, itemIndex, (NSString *)[itemLabels objectAtIndex:itemIndex]
// plain text line should be in Times Roman Bold font at 18 pt
// format of plaintext line: 
// @"%@ %3lud %@", exptCode, itemIndex, (NSString *)[itemLabels objectAtIndex:itemIndex]];

// Example:
// for experiment with code "GP" and items "W" and "S", then the labels for subject #19 should be:
//
//      *GP019W*            *GP019W*
//      GP 019 W            GP 019 S
//
//

@interface BCBarcodeLabelsHtmlFormatter : NSObject {
		
	NSTableView *tableView;
	NSString *tableID;
	
    NSString *exptCode;
    NSArray *itemCodes;
    NSUInteger numSubjects;
    
}

- (id) initWithExptCode:(NSString *)ec andItemCodes:(NSArray *)il forSubjectsCount:(NSUInteger)sc;
- (NSString *) htmlString;
- (void) appendCssToString:(NSMutableString *)buffer;
- (void) appendHtmlToString:(NSMutableString *)buffer;
- (void) appendHeadersToString:(NSMutableString *)buffer;
-(void)appendRowAtIndex:(NSUInteger)rowIndex withItemCode:(NSString *)itemCode toString:(NSMutableString *)buffer;

@end
