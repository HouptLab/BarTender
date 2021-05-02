//
//  BarUtilities.m
//  Bartender
//
//  Created by Tom Houpt on 7/19/20.
//

#include "BarUtilities.h"

@implementation NSString (ParsingBarTenderLabelExtensions)

- (NSArray *)parseAsBarTenderLabel; {

    // parse a string from a barcode in the format <expt_code><subject_index><item_code>
    // where expt_code is all alpha, subject_index is all numberic, and item_code is all alpha
    // if there is no item_code, item_code is set to "_na"
    // returns an NSArray @[ exptCode, subjectIndex, itemCode];

    // NB: Barcode Code39 indicates lowercase letters with a "+" prefix, eg.  "g" -> "+G"
    // so we want to recognize alpha as A-Z and the + sign
    // other ASCII characters use other escape prefixes, like "%" and "/" and "$",
    // but those are outside our valid label characters
    // https://en.wikipedia.org/wiki/Code_39

    NSRange  searchedRange = NSMakeRange(0, [self length]);
    NSString *pattern = @"([A-Z\\+]+)([0-9]+)([A-Z\\+]+)*";
    NSError  *error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:self options:0 range: searchedRange];

    if (0 == numberOfMatches) { return nil; }

    NSTextCheckingResult* match  = [regex firstMatchInString:self options:0 range: searchedRange];

    NSUInteger numberOfRanges = [match numberOfRanges];
    if (4 > numberOfRanges){ return nil; }

 /*
    for (NSUInteger j = 0; j < numberOfRanges; j++) {
    
        NSLog(@"%ld  loc: %ld len: %ld", j, [match rangeAtIndex:j].location, [match rangeAtIndex:j].length);
    }
*/


   // NSString* matchText = [self substringWithRange:[match range]];
    
    NSString* exptCode = nil;
    NSString* subjectIndex = nil;
    NSString* itemCode = @"_na";
    if ( NSNotFound != [match rangeAtIndex:1].location && 0 != [match rangeAtIndex:1].length){
        exptCode = [[self substringWithRange:[match rangeAtIndex:1]] stringByReplacingOccurrencesOfString:@"+" withString:@""];
    }
    if ( NSNotFound != [match rangeAtIndex:2].location && 0 != [match rangeAtIndex:2].length){
        subjectIndex = [[self substringWithRange:[match rangeAtIndex:2]] stringByReplacingOccurrencesOfString:@"+" withString:@""];
    }
    
    if ( NSNotFound != [match rangeAtIndex:3].location && 0 != [match rangeAtIndex:3].length){
        itemCode = [[self substringWithRange:[match rangeAtIndex:3]] stringByReplacingOccurrencesOfString:@"+" withString:@""];
    }

  //  NSLog(@"Match Text: %@ %@ %@ %@", matchText, exptCode,subjectIndex,itemCode );

    NSArray *label_codes = @[ exptCode, subjectIndex, itemCode];
    return label_codes;

}

@end
