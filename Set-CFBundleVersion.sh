#!/bin/bash

#  Set-CFBundleVersion.sh
#
#  Sets the built-product's CFBundeVersion to the current working-directory Subversion revision.
#
#  Install by adding a Run-Script Phase to the end of target's Build Phases with the script:
#
#       $SRCROOT/Set-CFBundleVersion.sh
#
#  Select "Run script only when installing" to limit execution to Release/Archiving.
#
#  Created by Chuck Houpt on 10/23/13.
#  Copyright 2013 Behavioral Cybernetics LLC. All rights reserved.

set -eu

exit

# Only run on release builds, since debug builds are by definition based on un-commmited code changes.
if [ $CONFIGURATION != 'Release' ] ; then exit ; fi

# Preemptively call svn-cleanup to avoid sqlite-errors from svnversion
svn cleanup

REVISION=$(svnversion -n)

# Report problems if the working directory isn't a completely clean single-revision checkout.
# Use REPORT var to switch between warning and error ("Jerk Mode")
REPORT=warning
# REPORT=error

if [[ ! "$REVISION" =~ ^[0-9]+$ ]]
then
        echo "$REPORT: working directory is not a single unmodified revision. svnversion reports: $REVISION (note: X:Y means mixed-revision, so update work-dir. 'M' means modified, so commit work-dir changes)"
        [ $REPORT == 'warning' ]
elif [[ $(svn status) ]]
then
        echo "warning: working directory is not a completely clean checkout with no extranious files. svn status reports:"
        svn status
fi

# Modify CFBundleVersion in the product's compiled Info.plist

if grep --quiet 'CFBundleVersion' "$BUILT_PRODUCTS_DIR/$INFOPLIST_PATH"
then
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $REVISION" "$BUILT_PRODUCTS_DIR/$INFOPLIST_PATH"
else
        /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string $REVISION" "$BUILT_PRODUCTS_DIR/$INFOPLIST_PATH"
fi
