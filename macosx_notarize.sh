#!/bin/bash

#Contents partly stolen from https://scriptingosx.com/2019/09/notarize-a-command-line-tool/
#Will need updating for XCode 13+

if [ $# -lt 6 ]
  then
    echo "Usage: ./macosx_notarize.sh <path> <certname> <teamname> <bundleid> <appleid> <applepass>"
    echo ""
    echo "path: the absolute(!) target path"
    echo "certname: the apple signing certificate name. Something like \"Developer ID Application: xxx (yyy)\""
    echo "teamname: the apple team name. 10-digit id yyy from the cert name."
    echo "bundleid: the bundle id of the artifact"
    echo "appleid: id of your apple account"
    echo "applepass: password of your apple account"
    exit 1
fi

echo "##########################################################"
echo "Notarizing $1... This may take a while."

APP_DIR="$( dirname "$1" )"
APP_NAME="$( basename "$1" )"
ZIP_PATH=$1.zip

cd $APP_DIR
echo "Creating zip"
zip -r "$APP_NAME.zip" "$APP_NAME"

echo "Uploading $ZIP_PATH for notarization and waiting for result"
xcrun notarytool submit "$1.zip" \
                 --apple-id $5 \
                 --password $6 \
                 --team-id $3 \
                 --wait 2>&1 | tee notary_output.txt
rm "$APP_NAME.zip"
requestUUID=$(cat notary_output.txt | awk '/id:/ { print $NF; exit; }')
rm notary_output.txt

echo "Notarization log:"
xcrun notarytool log $requestUUID \
                 --apple-id $5 \
                 --password $6 \
                 --team-id $3 \
                 notarization.log
cat notarization.log
rm -f notarization.log
echo ""

# staple
xcrun stapler staple -v "$1"

echo "##########################################################"
