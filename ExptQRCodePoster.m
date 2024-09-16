//
//  ExptQRCodePoster.m
//  Bartender
//
//  Created by Tom Houpt on 8/5/24.
//

#import "ExptQRCodePoster.h"
#import "QRCodeMaker.h"

@implementation ExptQRCodePosterView

-(void)awakeFromNib; {

}

-(void)drawRect:(NSRect)rect; {

      CGContextRef cgcontext = [[NSGraphicsContext currentContext] CGContext];
    
  //  CGContextBeginPath(cgcontext);
 //   CGContextSetRGBFillColor(cgcontext, 0, 0.95, 0.95, 1.0);
    CGContextClearRect(cgcontext, self.bounds);
    [self drawQRPoster:cgcontext];

}



-(void)drawQRPoster:(CGContextRef)posterContext;
{

    
/*
    CFDataRef boxData = NULL;
    CFMutableDictionaryRef myDictionary = NULL;

    
   CGColorSpaceRef  colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    
   size_t bitsPerComponent = 8;
   size_t bytesPerRow = kQRPosterPageWidth;
   size_t bitmapByteCount  = (bytesPerRow * kQRPosterPageHeight);
   
   void *bitmapData = calloc( bitmapByteCount, sizeof(uint8_t) );

    
    posterContext = CGContextRef CGBitmapContextCreate( bitmapData, kQRPosterPageWidth, kQRPosterPageHeight,  bitsPerComponent, bytesPerRow, CGColorSpaceRef, kCGImageAlphaPremultipliedLast);
     CGColorSpaceRelease( colorSpace );
*/

    [self drawQRCodesToContext:posterContext ];// 8

  //  CGContextRelease (posterContext);// 10

}

-(void)drawQRCodesToContext:(CGContextRef) posterContext ; {

   [self setTitle: [_posterDoc title]];
    [self setInvest: [_posterDoc invest]];
    [self setWikiUrl: [_posterDoc wikiUrl]];
    [self setGraphUrl: [_posterDoc graphUrl]];
    [self setProtocol: [_posterDoc protocol]];

    
    if (nil == _title) { 
        return;
    }
    
        NSDictionary *protocolfontAttributes =
      [NSDictionary dictionaryWithObjectsAndKeys:
       @"Helvetica", (NSString *)kCTFontFamilyNameAttribute,
       @"Bold", (NSString *)kCTFontStyleNameAttribute,
       [NSNumber numberWithFloat:kQRPosterProtocolFontSize],
       (NSString *)kCTFontSizeAttribute,
       nil];
       
    NSDictionary *titlefontAttributes =
      [NSDictionary dictionaryWithObjectsAndKeys:
       @"Helvetica", (NSString *)kCTFontFamilyNameAttribute,
       @"Bold", (NSString *)kCTFontStyleNameAttribute,
       [NSNumber numberWithFloat:kQRPosterTitleFontSize],
       (NSString *)kCTFontSizeAttribute,
       nil];
       
        NSDictionary *investfontAttributes =
      [NSDictionary dictionaryWithObjectsAndKeys:
       @"Helvetica", (NSString *)kCTFontFamilyNameAttribute,
       @"Bold", (NSString *)kCTFontStyleNameAttribute,
       [NSNumber numberWithFloat:kQRPosterInvestFontSize],
       (NSString *)kCTFontSizeAttribute,
       nil];
       
               NSDictionary *labelfontAttributes =
      [NSDictionary dictionaryWithObjectsAndKeys:
       @"Helvetica", (NSString *)kCTFontFamilyNameAttribute,
       @"Bold", (NSString *)kCTFontStyleNameAttribute,
       [NSNumber numberWithFloat:kQRPosterLabelFontSize],
       (NSString *)kCTFontSizeAttribute,
       nil];


    //  CGContextSetRGBStrokeColor(posterContext, 0.98, 0.98, 0.98, 1.0);
      CGContextSetRGBStrokeColor(posterContext, 0.95, 0.95, 0.95, 1.0);


// protocol #

      CFStringRef prot = (__bridge CFStringRef)[self protocol];
      
      [self drawCGText:prot withAttributes:protocolfontAttributes  inContext:posterContext atCenterPoint:CGPointMake(kQRPosterPageWidth/2,kQRPosterProtocolY)];
      
// put title at top of page

      CFStringRef title = (__bridge CFStringRef)[self title];
      
      [self drawCGText:title withAttributes:titlefontAttributes  inContext:posterContext atCenterPoint:CGPointMake(kQRPosterPageWidth/2,kQRPosterTitleY)];
      
// put PI at top of page
      CFStringRef invest =  (__bridge CFStringRef)[self invest];

      [self drawCGText:invest withAttributes:investfontAttributes  inContext:posterContext atCenterPoint:CGPointMake(kQRPosterPageWidth/2,kQRPosterInvestY)];

// draw top qr code for wiki

                CGContextBeginPath(posterContext);

               CGFloat x = (kQRPosterPageWidth - kQRPosterQRCodeWidth)/2 ;
               CGFloat topy =  kQRPosterTopQRCodeY;
               
               // put box around the qr code

//                CGRect box = CGRectMake(x,
//                                       y,
//                                        kQRPosterQRCodeWidth 
//                                        kQRPosterQRCodeWidth);
//                CGContextAddRect(posterContext,box);
//                CGContextStrokePath(posterContext); // closes the path too


                QRCodeMaker *qrMaker = [[QRCodeMaker alloc] initWithString:_wikiUrl andSideInPixels:kQRPosterQRCodeWidth];
                
                CGRect qrRect = CGRectMake(x,topy,
                                    kQRPosterQRCodeWidth,
                                    kQRPosterQRCodeWidth);
                 CGContextDrawImage(posterContext, qrRect, [qrMaker cgimage]);

                CGPoint centerLabelPoint = CGPointMake(x+ (kQRPosterQRCodeWidth/2) , topy - kQRPosterLabelFontSize  - kQRPosterLabelTopMargin);
                

                CFStringRef label =  (__bridge CFStringRef)@"WIKI";


                [self drawCGText:label withAttributes:labelfontAttributes inContext:posterContext atCenterPoint:centerLabelPoint];


             CGFloat boty =  kQRPosterBottomQRCodeY;
             
              QRCodeMaker *qrTabMaker = [[QRCodeMaker alloc] initWithString:_graphUrl andSideInPixels:kQRPosterQRCodeWidth];
                
                CGRect qrbotRect = CGRectMake(x,boty,
                                    kQRPosterQRCodeWidth,
                                    kQRPosterQRCodeWidth);
                 CGContextDrawImage(posterContext, qrbotRect, [qrTabMaker cgimage]);

                CGPoint botcenterLabelPoint = CGPointMake(x+ (kQRPosterQRCodeWidth/2) , boty - kQRPosterLabelFontSize  - kQRPosterLabelTopMargin);
                
                CFStringRef tablabel =  (__bridge CFStringRef)@"DATA";

                

                [self drawCGText:tablabel withAttributes:labelfontAttributes inContext:posterContext atCenterPoint:botcenterLabelPoint];

    
}

-(void)drawCGText:(CFStringRef)string withAttributes:(NSDictionary *)fontAttributes inContext:(CGContextRef)context atCenterPoint:(CGPoint)point; {

    CTFontDescriptorRef descriptor =
        CTFontDescriptorCreateWithAttributes((CFDictionaryRef)fontAttributes);
    
     //
    // Initialize the string, font, and context
    
    CTFontRef font = CTFontCreateWithFontDescriptor(descriptor, 0.0, NULL);
    CFRelease(descriptor);

    // CTFontRef font = CTFontCreateWithName(CFStringCreateWithCString(NULL, "Helvetica", kCFStringEncodingUTF8), 14, NULL); 
    CFStringRef keys[] = { kCTFontAttributeName };
    CFTypeRef values[] = { font };
    
    CFDictionaryRef attributes =
    CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
                       (const void**)&values, sizeof(keys) / sizeof(keys[0]),
                       &kCFTypeDictionaryKeyCallBacks,
                       &kCFTypeDictionaryValueCallBacks);
    
    CFAttributedStringRef attrString =
    CFAttributedStringCreate(kCFAllocatorDefault, string, attributes);
    CFRelease(string);
    CFRelease(attributes);
        
    //CGContextSetTextMatrix(context, CGAffineTransformRotate(CGAffineTransformIdentity, -90.0));
   // CGContextSetTextMatrix(context, CGAffineTransformMakeRotation((CGFloat)M_PI));
    
    CTLineRef line = CTLineCreateWithAttributedString(attrString);
    CGRect lineBounds = CTLineGetImageBounds(line, context);
    
    // Set text position and draw the line into the graphics context
    CGContextSetTextPosition(context, point.x - (lineBounds.size.width/2), point.y);
    CTLineDraw(line, context);
    CFRelease(line);

}






/*---------------------------------------------------------------------------------------*/


@end


@implementation ExptQRCodePoster 


- (NSString *)windowNibName {
    // Implement this to return a nib to load OR implement -makeWindowControllers to manually create your controllers.
    return @"ExptQRCodePoster";
}
-(void)awakeFromNib; {

   
}
- (IBAction)printDocument:(id)sender {
    
//    If you want users to be able to print a document, you must override printOperationWithSettings: error:, possibly providing a modified NSPrintInfo object.
	
	// get page size from [self printInfo]
//	NSRect paperRect = NSMakeRect(0,0,[[self printInfo] paperSize].width, [[self printInfo] paperSize].height);
	
    // Obtain a custom view that will be printed
//    NSView *printView = [[BCDailyDataWebView alloc] initWithDailyData:dailyData andTable:dailyTableView];
	
       
    NSView *printView = _posterView;
  
    
    // Construct the print operation and setup Print panel
//   NSPrintOperation *printOp = [NSPrintOperation
//               printOperationWithView:printView
//               printInfo:[self printInfo]];
    // don't pass NSDocument printInfo to printOp: printView will show up in printPanel preview but won't print
    // maybe because printView is not associated with an actual NSDocument
    
   // [self setPrintInfo:[NSPrintInfo sharedPrintInfo]];
    [[NSPrintInfo sharedPrintInfo] setVerticalPagination:NSPrintingPaginationModeAutomatic];
    float horizontalMargin, verticalMargin;

    horizontalMargin = 0;
    verticalMargin = 0;

    [[NSPrintInfo sharedPrintInfo] setLeftMargin:horizontalMargin];
    [[NSPrintInfo sharedPrintInfo] setRightMargin:horizontalMargin];
    [[NSPrintInfo sharedPrintInfo] setHorizontallyCentered:YES];
    [[NSPrintInfo sharedPrintInfo] setTopMargin:verticalMargin];

    [[NSPrintInfo sharedPrintInfo] setBottomMargin:verticalMargin];
    
    NSPrintOperation *printOp = [NSPrintOperation printOperationWithView:printView];



    [printOp runOperation];
    
 

    
// the rest of this is for modal print
//    
//    [printOp setShowsPrintPanel:showPanels];
//    
//    if (showPanels) {
//        // Add accessory view, if needed
//    }
//    
// 
//    
//    // Run operation, which shows the Print panel if showPanels was YES
//    
//    [self runModalPrintOperation:printOp
//                               delegate:self
//                         didRunSelector:@selector(documentDidRunModalPrintOperation:success:contextInfo:)
//                            contextInfo:NULL];
//    
   
}

/*
-(void)setTitle:(NSString *)t; {

    [_posterView setTitle:t];
}
-(void)setInvest:(NSString *)i; {

    [_posterView setInvest:i];
}
-(void)setWikiUrl:(NSString *)w;{

    [_posterView setWikiUrl:w];
}
-(void)setGraphUrl:(NSString *)g;{

    [_posterView setGraphUrl:g];
}
*/


@end

