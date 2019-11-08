//
//  FirebaseSummary.m
//  Bartender
//
//  Created by Tom Houpt on 10/23/19.
//

#import "FirebaseSummary.h"

#define kBartenderFirebaseURLString @"https://bartenderdata.firebaseio.com/expts/"

@implementation FirebaseSummary


- (BOOL) saveExpt:(NSString *)exptCode withData:(NSString *)exptDataJSON; {

    NSLog(@"json: %@",exptDataJSON);

    // curl -X PUT -d "{\"name\":{\"last\": \"sparrow\"}}" https://samplechat.firebaseio-demo.com/users/jack.json

    NSMutableString *firebaseExptURLString = [NSMutableString stringWithString:kBartenderFirebaseURLString ];
    [firebaseExptURLString appendString: exptCode];
    [firebaseExptURLString appendString: @".json"];

    NSData *postData = [exptDataJSON dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];

    NSURL *url = [NSURL URLWithString:firebaseExptURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"PATCH"];
    [request setHTTPBody:postData];

    NSData *responseData = [NSURLConnection  sendSynchronousRequest:request returningResponse:NULL error:NULL];
    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", response);

    return YES;

}

@end
