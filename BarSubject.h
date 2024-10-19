//
//  BarSubject.h
//  Bartender
//
//  Created by Tom Houpt on 09/7/11.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BarSubject : NSObject {
				
	unsigned long groupIndex;
		
}
	
-(id)initWithGroupIndex:(unsigned long)index;
-(unsigned long)groupIndex;
-(void)setGroupIndex:(unsigned long)index;

	
@end
