//
//  FadeOutText.h
//  Bartender
//
//  Created by Tom Houpt on 13/2/5.
//
//

#import <QuartzCore/QuartzCore.h>

// code by "ipmcc"
// http://stackoverflow.com/questions/14174911/how-do-i-animate-fadein-fadeout-effect-in-nstextfield-when-changing-its-text

@interface NSTextField (AnimatedSetString)

// fade-out the current string value [self stringValue], then set and fade in the new string value (aString)

- (void) setAnimatedStringValue:(NSString *)aString;

@end
