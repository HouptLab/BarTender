//
//  FirebaseSummary.h
//  Bartender
//
//  Created by Tom Houpt on 10/23/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FirebaseSummary : NSObject

- (BOOL) saveExpt:(NSString *)exptCode withData:(NSString *)exptDataJSON;

@end

NS_ASSUME_NONNULL_END
