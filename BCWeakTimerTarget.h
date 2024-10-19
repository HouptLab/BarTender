//
//  BCWeakTimerTarget.h
//  Bartender
//
//  Created by Tom Houpt on 13/2/15.
//
//


// NSTimer+BCWeakTimerTarget.h:
#import <Foundation/NSTimer.h>
@interface NSTimer (BCWeakTimerTarget)
+(NSTimer *)BCscheduledTimerWithTimeInterval:(NSTimeInterval)ti weakTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)shouldRepeat logsDeallocation:(BOOL)shouldLogDealloc;
@end
