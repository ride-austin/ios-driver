if [ -f $SRCROOT/../fastlane/.env.default ]
then
	source $SRCROOT/../fastlane/.env.default
elif test -z "$CIRCLECI"
then
	echo "Please provide missing ${SRCROOT}/../fastlane/.env.default file"
	exit 1
fi

TEMPLATE_FILE=$SRCROOT/scripts/templates/RideDriverEnterprise-Info.plist.template
OUTPUT_FILE=$SRCROOT/support/Plist/RideDriverEnterprise-Info.plist

cp $TEMPLATE_FILE $OUTPUT_FILE

if test -z "$FACEBOOK_APP_ID"
then
	echo "Please provide missing \$FACEBOOK_APP_ID"
fi
if test -z "$FACEBOOK_BUNDLE_URL_SCHEME"
then
	echo "Please provide missing \$FACEBOOK_BUNDLE_URL_SCHEME"
fi
if test -z "$FACEBOOK_DISPLAY_NAME"
then
	echo "Please provide missing \$FACEBOOK_DISPLAY_NAME"
fi
if test -z "$FACEBOOK_URL_SCHEME_SUFFIX"
then
	echo "Please provide missing \$FACEBOOK_URL_SCHEME_SUFFIX"
fi

sed -i '' -e "s|{{facebookAppId}}|$FACEBOOK_APP_ID|g" $OUTPUT_FILE
sed -i '' -e "s|{{facebookBundleUrlScheme}}|$FACEBOOK_BUNDLE_URL_SCHEME|g" $OUTPUT_FILE
sed -i '' -e "s|{{facebookDisplayName}}|$FACEBOOK_DISPLAY_NAME|g" $OUTPUT_FILE
sed -i '' -e "s|{{facebookUrlSchemeSuffix}}|$FACEBOOK_URL_SCHEME_SUFFIX|g" $OUTPUT_FILE

echo "Done with setup of ${OUTPUT_FILE}"
