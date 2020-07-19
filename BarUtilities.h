//
//  BarUtilities.h
//  Bartender
//
//  Created by Tom Houpt on 7/19/20.
//


#import <Cocoa/Cocoa.h>

// for parsing label <expt_code><subject_index><item_code> via @"([A-Z]+)([0-9]+)([A-Z]+)" regex
#define kParseIndexExptCode 0
#define kParseIndexSubjectIndex 1
#define kParseIndexItemCode 2

@interface  NSString (ParsingBarTenderLabelExtensions)

- (NSArray *)parseAsBarTenderLabel;


@end
