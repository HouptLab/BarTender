#!/bin/bash

#  Set-CFBundleVersion.sh
#
#  Sets the built-product's CFBundeVersion to the current working-directory revision.
#
#  Install by adding a Run-Script Phase to the end of target's Build Phases with:
#
#    Script:  $SRCROOT/Set-CFBundleVersion.sh
#    Based on dependency analysis: False
#    Input Files: $(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)
#
#  Select "Run script only when installing" to limit execution to Release/Archiving.
#
#  Created by Chuck Houpt on 10/23/13.
#  Copyright 2013-2024 Behavioral Cybernetics LLC. All rights reserved.

set -eux

# Only run on release builds, since debug builds are by definition based on un-commmited code changes.
#if [ $CONFIGURATION != 'Release' ] ; then exit ; fi

if [[ ! -d .git ]]
then
    echo "warning: working dir not under version control, could not set version"
    exit
fi

REVISION=$(git rev-list --count HEAD)
DESCRIBE=$(git describe --tags --long --always --dirty=-mutant)

# Emulate SVN by adding M if dirty
case $DESCRIBE in
  *-mutant) REVISION="${REVISION}M" ;;
esac

# Modify CFBundleVersion in the product's compiled Info.plist

/usr/libexec/PlistBuddy -c "Add :CFBundleVersion string $REVISION" \
    -c "Add :BCGitDescribe string $DESCRIBE" \
    "$BUILT_PRODUCTS_DIR/$INFOPLIST_PATH" || echo "warning: failed to setup CFBundleVersion"
