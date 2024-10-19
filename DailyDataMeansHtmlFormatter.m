//
//  DailyDataMeansHtmlFormatter.m
//  Bartender
//
//  Created by Tom Houpt on 13/2/16.
//
//

#import "DailyDataMeansHtmlFormatter.h"

@implementation DailyDataMeansHtmlFormatter

-(id)initWithDailyData:(DailyData *)d andTableID:(NSString *)tid; {
	
	self = [super  init];
	
	if (self) {
		
		data = d;
		tableID = tid;
		
		useVerticalLines = YES;
		useAlternatingRowColors = YES;
        
        if (nil != data) { 
        
            itemLabels = [data itemLabels];
            groupLabels = [data groupLabels];
            groupMeans = [data groupMeans];
        
        }
	}
	
	return self;
	
}

- (NSString *) htmlString; {
	
	NSMutableString *htmlString = [[NSMutableString alloc] init];
	
	[self appendHtmlToString:htmlString];
	
	return htmlString;
	
}

-(void)appendCssToString:(NSMutableString *)buffer; {
    
	
	NSMutableString *cssString = [[NSMutableString alloc] init];
	
	[cssString appendString: @"<style>\r"];
	
	NSString *prefixString;
	
	if (nil == tableID) prefixString = @".meantable";
	else prefixString = [NSString stringWithFormat:@"#%@",tableID];
    
	// specify 12 pt fonts for table
	
	[cssString appendFormat: @"%@ th, td {font-family: Helvetica, sans-serif; font-size:9pt;} \r", prefixString];
    //	[cssString appendFormat: @"%@ table { border-style: hidden } \r", prefixString];
    
    
    //	// to put vertical rules between columns, set
    //	td: { border-style: none solid none solid; border-width:thin; }
    //  or is this better?
    //	col { border-style: none solid }
    
    //
    //	// to put rule under header row, set
    //	th: { border-style: none none solid none; }
    
	
	// make san-serif
	if (useAlternatingRowColors) {
		
		//  http://www.w3.org/Style/Examples/007/evenodd.en.html
		
		[cssString appendFormat: @"%@ tr:nth-child(odd)  { background-color:#ddd; } \r", prefixString];
		[cssString appendFormat: @"%@ tr:nth-child(even)   { background-color:#fff; } \r", prefixString];
		
		// be sure to set up the webpreferences of the webview to print backgrounds, e.g.
		
		//		[myWebView setPreferencesIdentifier:@"myWebPreferences"];
		//		WebPreferences *prefs = [myWebView preferences];
		//		[prefs setShouldPrintBackgrounds:YES];
		
		
	}
	
	[cssString appendString: @"</style>\r"];
	
	[buffer appendString:cssString];
	
}



- (void) appendHtmlToString:(NSMutableString *)buffer; {
	
	[self appendCssToString:buffer];
    
    [buffer appendString:@"<BR>\r"];
    [buffer appendString:@"<BR>\r"];

    [buffer appendString:@"<strong>Group Means</strong>"];
	
	[buffer appendFormat: @"<TABLE "];
	
	if (nil == tableID)[buffer appendString: @"class = \"meantable\" "];
	else [buffer appendFormat: @"id = \"%@\" ",tableID];
	
	NSString *rulesString;
	
	if (!useVerticalLines && !useHorizontalLines) {rulesString = @"rules=none ";}
	if ( useVerticalLines && !useHorizontalLines) {rulesString = @"rules=cols "; }
	if (!useVerticalLines &&  useHorizontalLines) {rulesString = @"rules=rows "; }
	if ( useVerticalLines &&  useHorizontalLines) {rulesString = @"rules=all "; }
	
	if (nil == tableID)[buffer appendString: rulesString];
	
	[buffer appendString: @">\r"];
    
	[self appendHeadersToString:buffer];
	
	NSUInteger rowIndex;
	NSUInteger numRows = [groupLabels count];
	
	for (rowIndex=0;rowIndex<numRows;rowIndex++) {
		
		[self appendRowAtIndex:rowIndex toString:buffer];
		
	}
    
	[buffer appendString: @"</TABLE>\r"];
	
}

-(void)appendHeadersToString:(NSMutableString *)buffer; {
	
	[buffer appendString: @"\t<TR frame=\"below\">\r"];
    
    // remember to add "Group" label
    [buffer appendString: @"\t\t<TH>Group</TH>\r"];
    
	for (NSString *itemName in itemLabels) {
        
		[buffer appendString: @"\t\t<TH>"];
		[buffer appendString:itemName];
		[buffer appendString: @"</TH>\r"];
		
	}
	
	[buffer appendString: @"\t</TR>\r"];
    
}

-(void)appendRowAtIndex:(NSUInteger)rowIndex toString:(NSMutableString *)buffer; {
	
    NSArray *rowArray = [groupMeans objectAtIndex:rowIndex];
    
	[buffer appendString: @"\t<TR>\r"];
    
    // put in group name
    
    [buffer appendString: @"\t\t<TD>"];
    [buffer appendString: [groupLabels objectAtIndex:rowIndex]];
    [buffer appendString: @"</TD>\r"];
	
	for (BCMeanValue *theMean in rowArray) {
        
		[buffer appendString: @"\t\t<TD>"];
        [buffer appendString: [theMean mean2Text]];
		[buffer appendString: @"</TD>\r"];
		
	}
    
	[buffer appendString: @"\t</TR>\r"];
	
}

@end
