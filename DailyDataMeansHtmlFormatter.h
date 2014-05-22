//
//  DailyDataMeansHtmlFormatter.h
//  Bartender
//
//  Created by Tom Houpt on 13/2/16.
//
//

#import <Foundation/Foundation.h>
#import "DailyData.h"

@interface DailyDataMeansHtmlFormatter : NSObject {

    DailyData *data;
    NSString *tableID;
    
    NSArray *itemLabels;
    NSArray *groupLabels;
    NSArray *groupMeans;

    BOOL useAlternatingRowColors;
    BOOL useVerticalLines;
    BOOL useHorizontalLines;
    BOOL useCaption;
    BOOL useRowNumbers;
}

-(id)initWithDailyData:(DailyData *)d andTableID:(NSString *)tid;

- (NSString *) htmlString;
- (void) appendCssToString:(NSMutableString *)buffer;
- (void) appendHtmlToString:(NSMutableString *)buffer;
- (void) appendHeadersToString:(NSMutableString *)buffer;
- (void) appendRowAtIndex:(NSUInteger)rowIndex toString:(NSMutableString *)buffer;

@end
