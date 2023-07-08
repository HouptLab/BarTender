//
//  FirebaseSummary.m
//  Bartender
//
//  Created by Tom Houpt on 10/23/19.
//

#import "FirebaseSummary.h"
#import "DailyData.h"
#import "Bartender_Constants.h"


@implementation FirebaseSummary

- (NSData *)getExpt:(NSString *)exptCode; {

    NSString *firebaseURL = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebaseDirectoryKey];
    
    // TODO: alert if firebaseURL is nil
    
    NSMutableString *firebaseExptURLString = [NSMutableString stringWithString:firebaseURL ];
    [firebaseExptURLString appendString: exptCode];
    [firebaseExptURLString appendString: @".json"];
    
    
    NSURL *url = [NSURL URLWithString:firebaseExptURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSData *responseData = [NSURLConnection  sendSynchronousRequest:request returningResponse:NULL error:NULL];
   //  NSString *expDataJSON = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
  //  NSLog(@"%@", expDataJSON);
    
    return responseData;

    
}
- (BOOL) saveExpt:(NSString *)exptCode withData:(NSData *)exptJSONData; {

//    NSLog(@"json: %@",exptDataJSON);

    // curl -X PUT -d "{\"name\":{\"last\": \"sparrow\"}}" https://samplechat.firebaseio-demo.com/users/jack.json

    NSString *firebaseURL = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebaseDirectoryKey];
    
    // TODO: alert if firebaseURL is nil
    
    NSMutableString *firebaseExptURLString = [NSMutableString stringWithString:firebaseURL ];
    
    [firebaseExptURLString appendString: exptCode];
    [firebaseExptURLString appendString: @".json"];

    // NSData *postData = [exptDataJSON dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];

    NSURL *url = [NSURL URLWithString:firebaseExptURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"PATCH"];
    [request setHTTPBody:exptJSONData];

    NSData *responseData = [NSURLConnection  sendSynchronousRequest:request returningResponse:NULL error:NULL];
    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
   //  NSLog(@"%@", response);

    return YES;

}

-(BOOL) setArchive:(NSString *)exptCode; {

    NSString *firebaseURL = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebaseDirectoryKey];
    
    // TODO: alert if firebaseURL is nil
    
    NSMutableString *firebaseExptURLString = [NSMutableString stringWithString:firebaseURL ];


    [firebaseExptURLString appendString: exptCode];
    [firebaseExptURLString appendString: @"/archived.json"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setDateFormat:kDateWithDayFormatString];
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
   
   NSError *error;
   
    NSDictionary *archiveDictionary = [[NSDictionary alloc] initWithObjects:@[dateString] forKeys:@[@"archive_date" ]];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:archiveDictionary
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];   
                                                         
  NSURL *url = [NSURL URLWithString:firebaseExptURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"PATCH"];
    [request setHTTPBody:jsonData];

    NSData *responseData = [NSURLConnection  sendSynchronousRequest:request returningResponse:NULL error:NULL];
    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
   //  NSLog(@"%@", response);

    return YES;                                                        
}


@end
