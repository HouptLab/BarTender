//
//  FadeOutText.m
//  Bartender
//
//  Created by Tom Houpt on 13/2/5.
//
//

#import "FadeOutText.h"

@implementation NSTextField (AnimatedSetString)

- (void) setAnimatedStringValue:(NSString *)aString
{
    if ([[self stringValue] isEqual: aString])
    {
        return;
    }
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration: 2.0];
        [context setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut]];
        [self.animator setAlphaValue: 0.0];
    }
                        completionHandler:^{
                            [self setStringValue: aString];
                            [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
                                [context setDuration: 1.0];
                                [context setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn]];
                                [self.animator setAlphaValue: 1.0];
                            } completionHandler: ^{}];
                        }];
}


@end
