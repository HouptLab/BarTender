//
//  ExptQRCodePoster.h
//  Bartender
//
//  Created by Tom Houpt on 8/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kQRPosterProtocolFontSize 14
#define kQRPosterTitleFontSize 24
#define kQRPosterInvestFontSize 18

#define kQRPosterLabelFontSize 24
#define kQRPosterLabelTopMargin 12

#define kQRPosterPageWidth 540
#define kQRPosterPageHeight 720


#define kQRPosterQRCodeWidth 180

#define kQRPosterProtocolY (kQRPosterPageHeight - 36)

#define kQRPosterTitleY (kQRPosterPageHeight - 72)

#define kQRPosterInvestY (kQRPosterTitleY - 36)

#define kQRPosterTopQRCodeY 374

#define kQRPosterBottomQRCodeY 120


@class ExptQRCodePoster;

@interface ExptQRCodePosterView : NSView {


}

@property IBOutlet ExptQRCodePoster *posterDoc;

@property NSRect pageRect;

@property NSString *title;
@property NSString *invest;
@property NSString *wikiUrl;
@property NSString *graphUrl;
@property NSString *protocol;

 -(void)drawQRPoster:(CGContextRef)posterContext;

@end


@interface ExptQRCodePoster : NSDocument

@property IBOutlet ExptQRCodePosterView *posterView;

@property NSString *title;
@property NSString *invest;
@property NSString *wikiUrl;
@property NSString *graphUrl;
@property NSString *protocol;



- (IBAction)printDocument:(id)sender;
@end

NS_ASSUME_NONNULL_END
