# Firebase Integration Notes

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

## Modify some project settings:

- add "dummy.swift" file WITHOUT BRIDGING HEADER (prevents lots of swift undefined symbol errors)

- add link path "usr/lib/swift" to "Target/Build Settings/Linking - General/Runpath Search Paths", as per https://stackoverflow.com/questions/52536380/why-do-i-get-ios-linker-errors-with-my-static-libraries/52939037#52939037

- to allow Firebase Authentication: add "Keychain Sharing" capability to project, because user gets stored as "firebase_auth_1___FIRAPP_DEFAULT_firebase_user"

- to allow connections, add App Sandbox capability, and check "Incoming Connections (Server)" and "Outgoing Connections (client)""
