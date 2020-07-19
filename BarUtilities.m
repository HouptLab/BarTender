//
//  BarUtilities.m
//  Bartender
//
//  Created by Tom Houpt on 7/19/20.
//

#include "BarUtilities.h"

@implementation NSString (ParsingBarTenderLabelExtensions)

- (NSArray *)parseAsBarTenderLabel; {

    NSRange  searchedRange = NSMakeRange(0, [self length]);
    NSString *pattern = @"([A-Z]+)([0-9]+)([A-Z]+)";
    NSError  *error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:self options:0 range: searchedRange];

    if (0 == numberOfMatches) { return nil; }

    NSTextCheckingResult* match  = [regex firstMatchInString:self options:NSRegularExpressionCaseInsensitive range: searchedRange];

    NSUInteger n = [match numberOfRanges];
    if (4 > [match numberOfRanges]){ return nil; }

    NSString* matchText = [self substringWithRange:[match range]];
    NSString* exptCode = [self substringWithRange:[match rangeAtIndex:1]];
    NSString* subjectIndex = [self substringWithRange:[match rangeAtIndex:2]];
    NSString* itemCode = [self substringWithRange:[match rangeAtIndex:3]];

    NSLog(@"Match Text: %@ %@ %@",exptCode,subjectIndex,itemCode );

    NSArray *label_codes = @[ exptCode, subjectIndex, itemCode];
    return label_codes;

}

@end
