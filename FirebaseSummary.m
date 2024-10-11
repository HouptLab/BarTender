//
//  FirebaseSummary.m
//  Bartender
//
//  Created by Tom Houpt on 10/23/19.
//

#import "FirebaseSummary.h"
#import "BarSummaryData.h"
#import "DailyData.h"
#import "Bartender_Constants.h"
#import "Firebase.h"
#import "BCAlert.h"

@import FirebaseAuth;
@import FirebaseCore;


/*
 codesigning crash:
 
 https://forums.developer.apple.com/forums/thread/739421
 
 https://stackoverflow.com/questions/74419883/firebase-does-not-support-mac-os
 https://stackoverflow.com/questions/54244720/issue-with-entitlements-in-ios-when-using-firebase
 
 
 https://stackoverflow.com/questions/63044652/how-do-i-get-a-flutter-project-running-on-macos-to-successfully-use-firestore
 */

@implementation FirebaseSummary

/*
 // add Keychain Sharing entitlement, because auth gets stored in keychain
 // https://stackoverflow.com/questions/38456471/secitemadd-always-returns-error-34018-in-xcode-8-in-ios-10-simulator/38543243#38543243
 
 
 [[FIRAuth auth] signInWithEmail:firebaseEmail
 password:firebasePassword
 completion:^(FIRAuthDataResult * _Nullable authResult,
 NSError * _Nullable signinerror) {
 
 
 if (signinerror) {
 NSLog([signinerror description]);
 return;
 }
 
 FIRUser *currentUser = [FIRAuth auth].currentUser;
 [currentUser getIDTokenForcingRefresh:YES
 completion:^(NSString *_Nullable idToken,
 NSError *_Nullable tokenerror) {
 if (tokenerror) {
 // Handle error
 NSLog([tokenerror description]);
 return;
 }
 
 
 NSError *_Nullable dataerror;
 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"test2": @"testdata2" }
 options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
 error:&dataerror];
 
 
 NSString *firebaseURL = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebaseDirectoryKey];
 
 // TODO: alert if firebaseURL is nil
 
 
 
 NSMutableString *firebaseExptURLString = [NSMutableString stringWithString:firebaseURL ];
 [firebaseExptURLString appendString: @"XXX"];
 [firebaseExptURLString appendString: @".json"];
 [firebaseExptURLString appendString: @"?auth="];
 [firebaseExptURLString appendString: idToken];
 
 NSURL *url = [NSURL URLWithString:firebaseExptURLString];
 NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
 [request setHTTPMethod:@"PATCH"];
 [request setHTTPBody:jsonData];
 
 NSData *responseData = [NSURLConnection  sendSynchronousRequest:request returningResponse:NULL error:NULL];
 NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
 NSLog(@"%@", response);
 
 
 NSError *signOutError;
 BOOL status = [[FIRAuth auth] signOut:&signOutError];
 if (!status) {
 NSLog(@"Error signing out: %@", signOutError);
 return;
 }
 
 // POST NOTIFICATION THAT OPERATION WAS COMPLETED
 
 }]; // get id Token
 
 }]; // sign in to firebase
 
 */

/***************************************************************************************************/
/**
 
 given an exptCode
 get firebaseURL, email, and password from user defaults
 login to firebase and get IDToken
 read the <firebaseURL>/expt/<exptCode> data using curl, authenticating with the IDToken
 merge local and firebase data and save to firebase
 sign out of firebase
 
 return the expt JSON as NSData
 
 */

- (NSData *)getAndMergeExpt:(NSString *)exptCode withSummaryData: (BarSummaryData *)summary; {
    
    NSString *firebaseURL = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebaseDirectoryKey];
    
    NSString *firebaseEmail = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebaseEmailKey];
    
    // TODO: store password in more secure way, eg. in keychain?
    NSString *firebasePassword = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebasePasswordKey];
    
    if (nil == firebaseURL || nil == firebaseEmail || nil == firebasePassword) {
        
        BCOneButtonAlert(NSAlertStyleInformational, @"Firebase Settings missing",
                         @"One or more Firebase settings (database url, user email, or password) is missing. Please enter in the BarTender settings, then quit and restart BarTender.",
                         @"OK");
        return nil;
        
        
    }
    
    // construct path down to expt data
    NSMutableString *firebaseExptURLString = [NSMutableString stringWithString:firebaseURL ];
    [firebaseExptURLString appendString: exptCode];
    [firebaseExptURLString appendString: @".json"];
    
    
    // add Keychain Sharing entitlement, because auth gets stored in keychain
    // https://stackoverflow.com/questions/38456471/secitemadd-always-returns-error-34018-in-xcode-8-in-ios-10-simulator/38543243#38543243
    
    [[FIRAuth auth] signInWithEmail:firebaseEmail
                           password:firebasePassword
                         completion:^(FIRAuthDataResult * _Nullable authResult,
                                      NSError * _Nullable signinerror) {
        
        
        if (signinerror) {
            NSLog(@"SignIn error:%@",[signinerror description]);
            NSString *info = [NSString stringWithFormat:@"Couldn't sign-in to Firebase. Check Settings. %@",[signinerror description]];
            
            BCOneButtonAlert(NSAlertStyleInformational, @"Firebase Authentication Failed",
                             info,
                             @"OK");
            return;
        }
        
        FIRUser *currentUser = [FIRAuth auth].currentUser;
        [currentUser getIDTokenForcingRefresh:YES
                                   completion:^(NSString *_Nullable idToken,
                                                NSError *_Nullable tokenerror) {
            if (tokenerror) {
                // Handle error
                NSLog(@"Get idToken error:%@",[tokenerror description]);
                
                NSString *info = [NSString stringWithFormat:@"Couldn't sign-in to Firebase. Check Settings. %@",[tokenerror description]];
                
                BCOneButtonAlert(NSAlertStyleInformational, @"Firebase Authentication Failed",
                                 info,
                                 @"OK");
                return;
            }
            
            
            // append the idToken to the firebase url
            [firebaseExptURLString appendString: @"?auth="];
            [firebaseExptURLString appendString: idToken];
            
            // set up the url request for curl
            NSURL *url = [NSURL URLWithString:firebaseExptURLString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            
            // get the json data for the experiment currently in firebase
            NSData *firebaseData = [NSURLConnection  sendSynchronousRequest:request returningResponse:NULL error:NULL];
            // TODO: handle an error
            
            // got the firebase expt data, now merge with summary data
            NSData *mergedData = [summary mergedJsonData:firebaseData];
            // merging the data also writes out the json locally
            
            // patch the firebase record with the merged (updated) data
            NSMutableURLRequest *patchRequest = [NSMutableURLRequest requestWithURL:url];
            [patchRequest setHTTPMethod:@"PATCH"];
            [patchRequest setHTTPBody:mergedData];
            
            NSData *patchResponseData = [NSURLConnection  sendSynchronousRequest:patchRequest returningResponse:NULL error:NULL];
            // TODO: handle an error
            NSString *patchResponse = [[NSString alloc] initWithData:patchResponseData encoding:NSUTF8StringEncoding];
            // TODO: handle some patch response
            
            
            NSError *signOutError;
            BOOL status = [[FIRAuth auth] signOut:&signOutError];
            if (!status) {
                NSLog(@"Error signing out: %@", signOutError);
                return;
            }
            
        }]; // getIDTokenForcingRefresh
    }]; // firebase signin
    
    return nil;
    
}
/***************************************************************************************************/
/**
 
 given an exptCode and the expt data in json (ALL of the data, for all days)
 get firebaseURL, email, and password from user defaults
 login to firebase and get IDToken
 patch the <firebaseURL>/expt/<exptCode> data using curl, authenticating with the IDToken
 sign out of firebase
 
 */

/*
 - (BOOL) saveExpt:(NSString *)exptCode withData:(NSData *)exptJSONData; {
 
 
 
 NSString *firebaseURL = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebaseDirectoryKey];
 
 NSString *firebaseEmail = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebaseEmailKey];
 // TODO: store password in more secure way, eg. in keychain?
 
 NSString *firebasePassword = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebasePasswordKey];
 
 if (nil == firebaseURL || nil == firebaseEmail || nil == firebasePassword) {
 
 BCOneButtonAlert(NSAlertStyleInformational, @"Firebase Settings missing",
 @"One or more Firebase settings (database url, user email, or password) is missing. Please enter in the BarTender settings, then quit and restart BarTender.",
 @"OK");
 return NO;
 
 }
 
 // construct path down to expt data
 NSMutableString *firebaseExptURLString = [NSMutableString stringWithString:firebaseURL ];
 [firebaseExptURLString appendString: exptCode];
 [firebaseExptURLString appendString: @".json"];
 
 
 [[FIRAuth auth] signInWithEmail:firebaseEmail
 password:firebasePassword
 completion:^(FIRAuthDataResult * _Nullable authResult,
 NSError * _Nullable signinerror) {
 
 
 
 if (signinerror) {
 NSLog(@"SignIn error:%@",[signinerror description]);
 NSString *info = [NSString stringWithFormat:@"Couldn't sign-in to Firebase. Check Settings. %@",[signinerror description]];
 
 BCOneButtonAlert(NSAlertStyleInformational, @"Firebase Authentication Failed",
 info,
 @"OK");
 return;
 }
 
 FIRUser *currentUser = [FIRAuth auth].currentUser;
 [currentUser getIDTokenForcingRefresh:YES
 completion:^(NSString *_Nullable idToken,
 NSError *_Nullable tokenerror) {
 if (tokenerror) {
 // Handle error
 NSLog(@"Get idToken error:%@",[tokenerror description]);
 
 NSString *info = [NSString stringWithFormat:@"Couldn't sign-in to Firebase. Check Settings. %@",[tokenerror description]];
 
 BCOneButtonAlert(NSAlertStyleInformational, @"Firebase Authentication Failed",
 info,
 @"OK");
 return;
 }
 
 
 // append the idToken to the firebase url
 [firebaseExptURLString appendString: @"?auth="];
 [firebaseExptURLString appendString: idToken];
 
 
 NSURL *url = [NSURL URLWithString:firebaseExptURLString];
 NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
 [request setHTTPMethod:@"PATCH"];
 [request setHTTPBody:exptJSONData];
 
 NSData *responseData = [NSURLConnection  sendSynchronousRequest:request returningResponse:NULL error:NULL];
 NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
 //  NSLog(@"%@", response);
 
 
 NSError *signOutError;
 BOOL status = [[FIRAuth auth] signOut:&signOutError];
 if (!status) {
 NSLog(@"Error signing out: %@", signOutError);
 return;
 }
 
 // TODO: POST NOTIFICATION THAT responseData WAS received (or will be nil if problem?)
 
 // return responseData;
 
 }]; // getIDTokenForcingRefresh
 }]; // firebase signin
 
 return YES;
 }
 */

/**
 
 mark and experiment as archived on firebase, by signing into firebase,
 and patching given experiment at /<exptCode> with a "archived":{ "@archive_date":<timestamp> } field
 
 */
-(BOOL) setArchive:(NSString *)exptCode; {
    
    NSString *firebaseURL = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebaseDirectoryKey];
    
    NSString *firebaseEmail = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebaseEmailKey];
    // TODO: store password in more secure way, eg. in keychain?
    
    NSString *firebasePassword = [[NSUserDefaults standardUserDefaults] valueForKey:kBartenderFirebasePasswordKey];
    
    if (nil == firebaseURL || nil == firebaseEmail || nil == firebasePassword) {
        
        BCOneButtonAlert(NSAlertStyleInformational, @"Firebase Settings missing",
                         @"One or more Firebase settings (database url, user email, or password) is missing. Please enter in the BarTender settings, then quit and restart BarTender.",
                         @"OK");
        return NO;
        
    }
    
    // construct path down to expt data
    NSMutableString *firebaseExptURLString = [NSMutableString stringWithString:firebaseURL ];
    [firebaseExptURLString appendString: exptCode];
    [firebaseExptURLString appendString: @"/archived.json"];
    
    [[FIRAuth auth] signInWithEmail:firebaseEmail
                           password:firebasePassword
                         completion:^(FIRAuthDataResult * _Nullable authResult,
                                      NSError * _Nullable signinerror) {
        
        
        if (signinerror) {
            NSLog(@"SignIn error:%@",[signinerror description]);
            NSString *info = [NSString stringWithFormat:@"Couldn't sign-in to Firebase. Check Settings. %@",[signinerror description]];
            
            BCOneButtonAlert(NSAlertStyleInformational, @"Firebase Authentication Failed",
                             info,
                             @"OK");
            return;
        }
        
        FIRUser *currentUser = [FIRAuth auth].currentUser;
        [currentUser getIDTokenForcingRefresh:YES
                                   completion:^(NSString *_Nullable idToken,
                                                NSError *_Nullable tokenerror) {
            if (tokenerror) {
                // Handle error
                NSLog(@"Get idToken error:%@",[tokenerror description]);
                
                NSString *info = [NSString stringWithFormat:@"Couldn't sign-in to Firebase. Check Settings. %@",[tokenerror description]];
                
                BCOneButtonAlert(NSAlertStyleInformational, @"Firebase Authentication Failed",
                                 info,
                                 @"OK");
                return;
            }
            
            
            // append the idToken to the firebase url
            
            [firebaseExptURLString appendString: @"?auth="];
            [firebaseExptURLString appendString: idToken];
            
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
            // TODO: handle error
            
            NSURL *url = [NSURL URLWithString:firebaseExptURLString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"PATCH"];
            [request setHTTPBody:jsonData];
            
            NSData *responseData = [NSURLConnection  sendSynchronousRequest:request returningResponse:NULL error:NULL];
            // TODO: handle error
            NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            // TODO: handle a response if there is one
            
            NSError *signOutError;
            BOOL status = [[FIRAuth auth] signOut:&signOutError];
            if (!status) {
                NSLog(@"Error signing out: %@", signOutError);
                // TODO: handle error
                return;
            }
            
            // TODO: POST NOTIFICATION THAT responseData WAS received (or will be nil if problem?)
                        
            
        }]; // get token id
        
    }]; // sign in to firebase
    
    return YES;
    
}


@end
