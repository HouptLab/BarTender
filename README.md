# BarTender Setup

TODO: instructions for integrating firebase into BarTender code

TODO: instructions for integrating firebase into PointOfScale code

TODO: user instructions for setting up their own firebase database

TODO: setup a "sandbox" to allow users to play with BarTender in firebase sandbox without overwriting lab data?

# Required Hardware

Specific item numbers and links are listed at https://wiki.houptlab.org/wiki/BarTender.

1. Macintosh, e.g. iMac of just about any capacity.

2. serial to USB-c adapter, and serial 9-pin to 25-pin D cable

3. Unitech BMS340 barcode scanner (or similar)

4. Sartorius BP-3100S

5. printer (e.g. Brother HL-L2400D Compact Monochrome Laser Printer) for daily hardcopy

# Software on Mac

1. Latest drivers for serial to USB-c adapter (check manufacturer's website)

2. free3of9 TrueType font for generating barcodes (included in this repository)

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

## modify some project settings:

- add "dummy.swift" file WITHOUT BRIDGING HEADER (prevents lots of swift undefined symbol errors)

- add link path "usr/lib/swift" to "Target/Build Settings/Linking - General/Runpath Search Paths", as per https://stackoverflow.com/questions/52536380/why-do-i-get-ios-linker-errors-with-my-static-libraries/52939037#52939037

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



4. copy GoogleService-Info.plist into the BarTender project *(TODO: currently include at build time, can it be put into package/contents/resources to include at runtime?)*



