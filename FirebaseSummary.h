//
//  FirebaseSummary.h
//  Bartender
//
//  Created by Tom Houpt on 10/23/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FirebaseSummary : NSObject

- (NSData *)getExpt:(NSString *)exptCode;
- (BOOL) saveExpt:(NSString *)exptCode withData:(NSData *)exptJSONData;

-(BOOL) setArchive:(NSString *)exptCode;


@end

NS_ASSUME_NONNULL_END
