# Bartender Setup

TODO: instructions for integrating firebase into BarTender code

TODO: instructions for integrating firebase into PointOfScale code

TODO: user instructions for setting up their own firebase database

TODO: setup a "sandbox" to allow users to play with BarTender in firebase sandbox without overwriting lab data?

# Required Hardware

1. Macintosh, e.g. iMac of just about any capacity.

2. serial to USB-c adapter, and serial 9-pin to 25-pin D cable

3. Unitech BMS340 barcode scanner (or similar)

4. Sartorius BP6100 scale

5. printer (e.g. Brother xxxx) for daily hardcopy

# Software on Mac

1. Latest drivers for serial to USB-c adapter (check manufacturer's website)

2. free3of9 TrueType font for generating barcodes (check website)

3. Download pre-built binary of BarTender, or build from source


# Building BarTender from Source:

# integrating firebase into macos app

## install Firebase SDKs as downloaded

https://firebase.google.com/docs/ios/setup

see "Integrate without using Swift Package Manager" on downloading Frameworks directly

follow Firebase README.md for install frameworks, and set to "Embed & Sign":

1. need to drag frameworks from folders:

- Firebase Analytics
- FirebaseAuth
- FirebaseFunctions
- FirebaseDatabase 

1. some redundancies, so don't need to drag duplicate frameworks. 

1. Symlinked into Firebase Analytics, so must keep that folder in the project (but don't have to drag in all the Analytics frameworks)

Be sure to clean the build folder often when installing new frameworks.

## modify some project setting:

- add "dummy.swift" file WITHOUT BRIDGING HEADER (prevents lots of swift undefined symbol errors)

- add link path "usr/lib/swift" to T"arget/Build Settings/Linking - General/Runpath Search Paths", as per https://stackoverflow.com/questions/52536380/why-do-i-get-ios-linker-errors-with-my-static-libraries/52939037#52939037

- to allow Firebase Authentication: add "Keychain Sharing" capability to project, because user gets stored as "firebase_auth_1___FIRAPP_DEFAULT_firebase_user"

- to allow connections, add App Sandbox capability, and check "Incoming Connections (Server)" and "Outgoing Connections (client)""


# Firebase setup

In console -> "Project settings" -> "General" tab:

1. Under "Your Project" copy "Web Api Key" to enter in "Settings" of BarTender and PointOfScale apps.


2. create an iOS+ "Apple app" for BarTender, with Bundle ID com.bcybernetics.bartender

2. create an iOS+ "Apple app" for PointOfScale, with Bundle ID com.bcybernetics.PointOfScale

3. In console -> "Authentication" -> "Sign-In Methods" tab:
    enable Email/Password

4. In console -> "Authentication" -> "Users" tab:
    add user with email and password 
   
4. enter this email and password in "Settings" of BarTender and PointOfScale apps.
    [NOTE: the way password is stored in the apps is not as secure as it could be...]


4. copy GoogleService-Info.plist into BarTender (TODO: include at build time, can it be put into package/contents/resources?)

4. how to copy into PointOfScale?


# Notes:

# Using curl to get/write data from firebase

## BarTender log into database

https://firebase.google.com/docs/auth/ios/password-auth#objective-c_3

## authenticate with email and password?

https://firebase.google.com/docs/database/rest/auth

1. get id token for user: 

https://firebase.google.com/docs/auth/admin/verify-id-tokens#retrieve_id_tokens_on_clients

after logging in with FIRAuth, then get currentUser and their IDToken

[FIRAuth auth].currentUser -> [currentUser getIDTokenForcingRefresh]


2. authenticate request with the id token:

e.g. to read data from field in the database:

```curl "https://\<DATABASE_NAME\>.firebaseio.com/users/ada/name.json?auth=\<ID_TOKEN\>"```

post url request with e.g. "PATCH" to write new data to the database

https://firebase.google.com/docs/reference/rest/auth

## Could not get these curl commands to work, need to pass in "auth=\<ID_TOKEN\>"

```

curl 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=[API_KEY]' -H 'Content-Type: application/json' --data-binary '{"email":"[EMAIL]","password":"[XXXX]","returnSecureToken":true}'


curl 'https://identitytoolkit.googleapis.com/v1/accounts:signUp?"key=[API_KEY]"' -H 'Content-Type: application/json' --data-binary '{"returnSecureToken":true}'

```

