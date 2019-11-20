//
//  BCMergeDictionary.m
//  Bartender
//
//  Created by Tom Houpt on 11/20/19.
//

#import "BCMergeDictionary.h"

@implementation NSMutableDictionary (MergeExtensions)

/** mergeWithSourceDictionary

 given a target dictionary, merge this dictionary  with the target:

 if key is in self but not target, add key-object to target
 if key is in self and also in target, replace target object
 (recurse through subdictionaries so only leaves are replaced)

 */

-(void)mergeWithSourceDictionary:(NSDictionary *)sourceDictionary; {

    for (NSString *key in sourceDictionary) {

        id value = self[key];

        // is key not in targetDictionary? then add key-object to targetDictionary
        if (nil == value) {

            self[key] = sourceDictionary[key];

        }
        else { // key is in targetDictionary

            // is key-object a dictionary? then we need to recurse and only add/overwrite leaves
            if ([[value className] isEqualToString:@"NSDictionary"]) {

                NSDictionary *sourceSubDictionary = sourceDictionary[key];

                // convert sub-dictionary to a mutable dictionary
                NSMutableDictionary *targetSubDictionary = [[NSMutableDictionary alloc] init];
                [targetSubDictionary setDictionary:(NSDictionary *)value];
                self[key] = targetSubDictionary;

                [targetSubDictionary mergeWithSourceDictionary:sourceSubDictionary];

            }
            else {
                // if key-object is not a dictionary, then overwrite target with source value
                self[key] = sourceDictionary[key];
            }

        }
    } // next source key

}
@end
