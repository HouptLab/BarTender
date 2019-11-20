//
//  BCMergeDictionary.h
//  Bartender
//
//  Created by Tom Houpt on 11/20/19.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (MergeExtensions)

-(void)mergeWithSourceDictionary:(NSDictionary *)sourceDictionary;

@end

NS_ASSUME_NONNULL_END
