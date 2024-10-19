//
//  BCBarcodeLabelsHtmlFormatter.m
//  Bartender
//
//  Created by Tom Houpt on 12/7/15.
//  Copyright 2012 Behavioral Cybernetics. All rights reserved.
//

#import "BCBarcodeLabelsHtmlFormatter.h"


#define kBarcodeFormat (@"*%@%02ld%@*")
#define kPlainTextFormat (@"%@ %02ld %@")


@implementation BCBarcodeLabelsHtmlFormatter


- (id) initWithExptCode:(NSString *)ec andItemCodes:(NSArray *)il forSubjectsCount:(NSUInteger)sc;	{
	
	self = [super  init];
	
	if (self) {
		
		exptCode = ec;
		itemCodes = il;
        numSubjects = sc;
		
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
	
	[cssString appendString: @"<style type=\"text/css\">\r"];
			
	// specify fixed layout and collapsed borders for barcode table
	[cssString appendString:@"table { table-layout: fixed ; border-collapse: collapse; page-break-after: always; } \r"];
 
	[cssString appendString:@"table:last-child { page-break-after: auto; } \r"];

  	// specify 1.8" wide table cells with dotted borders
 	[cssString appendString:@"td { width: 1.8in; border: 1px dotted; padding-bottom: 0px;padding-top: 0px;} \r"];
    
    // specify barcode font "New" at 36pt with 0.5in height for barcode cells
    [cssString appendString:@".barcode { font-family:\"New\"; font-size: 36pt; vertical-align: bottom; text-align: center; height: 0.5in; border-bottom:hidden; } \r"];

    // specify times New Roman font "New" at 18pt with 0.2in height for plaintext cells
    [cssString appendString:@".plaintext { font-family: \"Times New Roman\"; font-weight:bold; font-size: 18pt; vertical-align: top; text-align: center; height: 0.2in; border-top:hidden; padding-top: 0px;} \r"];
	
	[cssString appendString: @"</style>\r"];
	
	[buffer appendString:cssString];
	
}



- (void) appendHtmlToString:(NSMutableString *)buffer; {
	
    NSUInteger itemIndex;
    NSUInteger subjectPage, numPages;
    NSUInteger subjectIndex;

	
	[self appendCssToString:buffer];
    
    // ten labels per page
    numPages = (numSubjects/kNumSubjectsPerPage) + 1;
        

    for (itemIndex = 0; itemIndex < [itemCodes count]; itemIndex++) {
        
        for (subjectPage = 0; subjectPage < numPages; subjectPage++) {

                        NSString *theItemCode = (NSString *)[itemCodes objectAtIndex:itemIndex];

            [buffer appendFormat: @"<TABLE>\r"];
        
            for (subjectIndex=subjectPage * kNumSubjectsPerPage;subjectIndex < numSubjects && subjectIndex < ((subjectPage+1) * kNumSubjectsPerPage);subjectIndex++) {
                
                [self appendRowAtIndex:subjectIndex withItemCode:theItemCode toString:buffer];
                
            } // next subject
            
            [buffer appendString: @"</TABLE>\r"];
                
        
        } // next subject page

    } // next item
    
    
    
    // write html to a file for debugging

	NSError *error;
    
    NSString *testFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0] stringByAppendingPathComponent:@"barcodeLabelsHtmlTest.html"];
    
	[buffer writeToFile:testFilePath atomically:YES encoding:NSUnicodeStringEncoding error:&error];
    
    if (nil != error)  {
        NSLog(@"BCBarcodeLabelsdHtmlFormatter appendHtmlToString Error Desc: %@",[error localizedDescription]);
        NSLog(@"BCBarcodeLabelsdHtmlFormatter appendHtmlToString Error Sugg: %@",[error  localizedRecoverySuggestion]);
    }
    
		
}

-(void)appendHeadersToString:(NSMutableString *)buffer; {
	

	[buffer appendString: @"\t<TR frame=\"below\">\r"];

	for (NSTableColumn *aTableColumn in [tableView tableColumns]) {

		[buffer appendString: @"\t\t<TH>"];
		
		[buffer appendString:[[aTableColumn headerCell] stringValue]];
	
		[buffer appendString: @"</TH>\r"];
		
	}
	
	[buffer appendString: @"\t</TR>\r"];

}


-(void)appendRowAtIndex:(NSUInteger)rowIndex withItemCode:(NSString *)itemCode toString:(NSMutableString *)buffer; {
	
    NSUInteger i;

    // first barcode row...
	[buffer appendString: @"\t<TR class=\"barcode\">\r"];

    for (i=0; i<kNumColumns;i++) {
         
		[buffer appendString: @"\t\t<TD>"];
        
        // label text should be centered in the cell
        // this should be in 3of9 barcode font 36 pt (FRE3OF9X.TTF is what we use on Macs)
        NSString *barcodeString = [[NSString alloc] initWithFormat:kBarcodeFormat, exptCode, (rowIndex+1), itemCode];
        
        [buffer appendString:barcodeString];
			
		[buffer appendString: @"</TD>\r"];
		
	}

	[buffer appendString: @"\t</TR>\r"];

// then  plaintext row...
    [buffer appendString: @"\t<TR class=\"plaintext\">\r"];

    for (i=0; i<kNumColumns;i++) {

        [buffer appendString: @"\t\t<TD>"];
        
      // this should be in Times Roman Bold 18 pt
        NSString *plaintextString = [[NSString alloc] initWithFormat:kPlainTextFormat, exptCode, (rowIndex+1),itemCode];

        [buffer appendString:plaintextString];

        [buffer appendString: @"</TD>\r"];

    }

    [buffer appendString: @"\t</TR>\r"];


}


//- (NSString *)stringForObjectValue:(id)anObject; {
//
//	// Textual representation of cell content
//	// taken from "MyValueFormatter.m" of "QTMetadataEditor" sample code
//		
//	NSString *resultString;
//		
//	if ([anObject isMemberOfClass:[NSData class]]) {
//		// resultString = [MyValueFormatter hexStringFromData:(NSData *)anObject];
//	}
//	else if ([anObject isMemberOfClass:[NSString class]]) {
//		resultString = anObject;
//	}
//	else if ([anObject isMemberOfClass:[NSNumber class]]) {
//		resultString = [anObject stringValue];
//	}
//	return resultString;
//}
	


@end
