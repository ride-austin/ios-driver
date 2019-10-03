
if [ -f $SRCROOT/../fastlane/.env.default ]
then
	source $SRCROOT/../fastlane/.env.default
elif test -z "$CIRCLECI"
then
	echo "Please provide missing ${SRCROOT}/fastlane/.env.default file"
	exit 1
fi

TEMPLATE_FILE=$SRCROOT/scripts/templates/AppConfig.m.template
OUTPUT_FILE=$SRCROOT/FuelMeDriver/Classes/Managers/AppConfig.m

cp $TEMPLATE_FILE $OUTPUT_FILE

if test -z "$API_KEY"
then
	echo "Please provide missing \$API_KEY"
	exit 1
fi
if test -z "$GOOGLE_MAP_KEY"
then
	echo "Please provide missing \$GOOGLE_MAP_KEY"
	exit 1
fi
if test -z "$GOOGLE_MAP_DIRECTIONS_KEY"
then
	echo "Please provide missing \$GOOGLE_MAP_DIRECTIONS_KEY"
	exit 1
fi
if test -z "$BUG_FENDER_KEY"
then
	echo "Please provide missing \$BUG_FENDER_KEY"
fi
if test -z "$PRODUCTION_SERVER_URL"
then
	echo "Please provide missing \$PRODUCTION_SERVER_URL"
	exit 1
fi
if test -z "$QA_SERVER_URL"
then
	echo "Please provide missing \$QA_SERVER_URL"
fi
if test -z "$STAGE_SERVER_URL"
then
	echo "Please provide missing \$STAGE_SERVER_URL"
fi
if test -z "$DEV_SERVER_URL"
then
	echo "Please provide missing \$DEV_SERVER_URL"
fi
if test -z "$MD5_PASSWORD_SALT"
then
	echo "Please provide missing \$MD5_PASSWORD_SALT"
	exit 1
fi
if test -z "$HOCKEYAPP_ID_PRODUCTION"
then
	echo "Please provide missing \$HOCKEYAPP_ID_PRODUCTION"
	exit 1
fi
if test -z "$HOCKEYAPP_ID_QA"
then
	echo "Please provide missing \$HOCKEYAPP_ID_QA"
fi

sed -i '' -e "s|{{apiKey}}|$API_KEY|g" $OUTPUT_FILE
sed -i '' -e "s|{{GoogleMapKey}}|$GOOGLE_MAP_KEY|g" $OUTPUT_FILE
sed -i '' -e "s|{{googleMapDirectionsKey}}|$GOOGLE_MAP_DIRECTIONS_KEY|g" $OUTPUT_FILE
sed -i '' -e "s|{{bugFenderKey}}|$BUG_FENDER_KEY|g" $OUTPUT_FILE
sed -i '' -e "s|{{productionServerURL}}|$PRODUCTION_SERVER_URL|g" $OUTPUT_FILE
sed -i '' -e "s|{{qaServerURL}}|$QA_SERVER_URL|g" $OUTPUT_FILE
sed -i '' -e "s|{{stageServerURL}}|$STAGE_SERVER_URL|g" $OUTPUT_FILE
sed -i '' -e "s|{{devServerURL}}|$DEV_SERVER_URL|g" $OUTPUT_FILE
sed -i '' -e "s|{{md5PasswordSalt}}|$MD5_PASSWORD_SALT|g" $OUTPUT_FILE
sed -i '' -e "s|{{hockeyAppId}}|$HOCKEYAPP_ID_PRODUCTION|g" $OUTPUT_FILE
sed -i '' -e "s|{{hockeyAppTestId}}|$HOCKEYAPP_ID_QA|g" $OUTPUT_FILE

echo "Done with setup of AppConfig.m"
