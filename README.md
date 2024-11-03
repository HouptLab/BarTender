# BarTender Setup

# Required Hardware

Specific item numbers and links are listed at https://wiki.houptlab.org/wiki/BarTender.

1. Macintosh, e.g. iMac of just about any capacity.

3. Unitech BMS340 barcode scanner (or similar)

4. Sartorius BP-3100S (or equivalent modern version)

2. if needed, serial to USB-c adapter, and serial 9-pin to 25-pin D cable

5. printer (e.g. Brother HL-L2400D Compact Monochrome Laser Printer) for daily hardcopy

# Software on Mac

1. free3of9 TrueType font for generating barcodes (included in this repository)

2. Latest drivers for serial to USB-c adapter (check manufacturer's website)

3. Download pre-built binary of BarTender, or build from source

# Item Labels

Items to be weighed should be labeled with barcodes in 3of9 font, in the format `*<expt_code><nnn><item_code>*`, e.g. `*CTA005W` for the #5 water bottle in expt 'CTA'.
 
# Building BarTender from Source

(Note that you can follow the github workflow specified in the BarTender repo in `.github/workflows/objective-c-xcode.yaml`)

1. Clone the BarTender repo from Github.

2. Get the Firebase SDK frameworks. At https://firebase.google.com/docs/ios/setup, see "Integrate without using Swift Package Manager" on downloading Frameworks directly, in particular "Download the framework SDK zip."  When it is downloaded and un-zipped, copy the "Firebase" folder into the Bartender project folder.

3. Copy your `GoogleService-Info.plist` into the BarTender project folder , under the Resources folder. (see Firebase setup below). (To get the project to compile, you can create a dummy `GoogleService-Info.plist` -- but Firebase features won't work, of course.)

4. Distribute via `Product` -> `Archiving`.

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


4. copy `GoogleService-Info.plist` into the BarTender project folder, under the Resources folder. *(TODO: currently include at build time, can it be put into package/contents/resources to include at runtime?)*



