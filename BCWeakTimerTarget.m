//
//  BCWeakTimerTarget.m
//  Bartender
//
//  Created by Tom Houpt on 13/2/15.
//
//

#import "BCWeakTimerTarget.h"

@interface BCWeakTimerTarget : NSObject {
   // id weakTarget;
    SEL selector;
    // for logging purposes:
    BOOL logging;
    NSString *targetDescription;
}

@property (weak) id weakTarget;

-(id)initWithTarget:(id)target selector:(SEL)aSelector shouldLog:(BOOL)shouldLogDealloc;
-(void)passthroughFiredTimer:(NSTimer *)aTimer;
-(void)dumbCallbackTimer:(NSTimer *)aTimer;
@end

@implementation BCWeakTimerTarget

//@synthesize _weakTarget;


-(id)initWithTarget:(id)target selector:(SEL)aSelector shouldLog:(BOOL)shouldLogDealloc
{
    self = [super init];
    if ( !self )
        return nil;
    
    logging = shouldLogDealloc;
    
    if (logging)
        targetDescription = [[target description] copy];
    
    _weakTarget = target;
    selector = aSelector;
    
    return self;
}

-(void)dealloc
{
    if (logging)
        NSLog(@"-[%@ dealloc]! (Target was %@)", self, targetDescription);
  
// ARC forbids
//    [targetDescription release];
//    [super dealloc];
}

-(void)passthroughFiredTimer:(NSTimer *)aTimer;
{
    [_weakTarget performSelector:selector withObject:aTimer];
}

-(void)dumbCallbackTimer:(NSTimer *)aTimer;
{
    [_weakTarget performSelector:selector];
}
@end

@implementation NSTimer (BCWeakTimerTarget)
+(NSTimer *)BCscheduledTimerWithTimeInterval:(NSTimeInterval)ti weakTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)shouldRepeat logsDeallocation:(BOOL)shouldLogDealloc
{
    SEL actualSelector = @selector(dumbCallbackTimer:);
    if ( 2 != [[target methodSignatureForSelector:selector] numberOfArguments] )
        actualSelector = @selector(passthroughFiredTimer:);
    
    BCWeakTimerTarget *indirector = [[BCWeakTimerTarget alloc] initWithTarget:target selector:selector shouldLog:shouldLogDealloc];
    
    NSTimer *theTimer = [NSTimer scheduledTimerWithTimeInterval:ti target:indirector selector:actualSelector userInfo:userInfo repeats:shouldRepeat];
    
    // ARC forbids
    // [indirector release];
    
    return theTimer;
}
@end
