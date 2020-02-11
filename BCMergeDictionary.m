//
//  BCMergeDictionary.m
//  Bartender
//
//  Created by Tom Houpt on 11/20/19.
//

#import "BCMergeDictionary.h"

@implementation NSMutableDictionary (MergeExtensions)

/** mergeWithSourceDictionary

 self is target, given dictionary is source
 given a source dictionary, merge this dictionary  with the source:
 if key is in source but not self, add key-object to self
 if key is in self and also in source, keep self (ie. replace source with target)
 (recurse through subdictionaries so only leaves are replaced)

 */

-(void)mergeWithSourceDictionary:(NSDictionary *)sourceDictionary; {

    // don't try to merge a nil dictionary
    
    if (nil == sourceDictionary) { return; }
    for (NSString *key in sourceDictionary) {

        id value = self[key];
        
        if ([key isEqualToString:@"Body Weight"]) {
            NSLog(@"body weight %@", key);

            
        }

        // is key not in targetDictionary? then add key-object to targetDictionary
        if (nil == value) {
            self[key]  = sourceDictionary[key];
            NSLog(@"added value from source to target at key %@", key);
        }
        else { // key is in sourceDictionary and targetDictionary

            // is key-object a dictionary? then we need to recurse and only add/overwrite leaves
            if ([value isKindOfClass:[NSDictionary class]]) {

                NSDictionary *sourceSubDictionary = sourceDictionary[key];

                // convert sub-dictionary to a mutable dictionary
                NSMutableDictionary *targetSubDictionary = [(NSDictionary *)self[key] mutableCopy];
                [targetSubDictionary mergeWithSourceDictionary:sourceSubDictionary];
                self[key] = targetSubDictionary;

            }
            else {
                // if key-object is not a dictionary, then use target value instead of source (ie don't change target)                
             //   NSLog(@"updated  value in target overrides source at key %@", key);

            }

        }
    } // next source key

}
@end
