if [ "$CONFIGURATION" == "DebugEnterprise" ] || [ "$CONFIGURATION" == "ReleaseEnterprise" ]; then
	echo "Found ProductionEnterprise file for com.driveaustin"
	TEMPLATE_FILE=$SRCROOT/support/Plist/GoogleService-Info-ProductionEnterprise.plist
elif [ "$CONFIGURATION" == "DebugQA" ] || [ "$CONFIGURATION" == "ReleaseQAEnterprise" ]; then
	echo "Found QA file for com.driveaustin.test"
	TEMPLATE_FILE=$SRCROOT/support/Plist/GoogleService-Info-QA.plist
else
	echo "Found Production file for com.driveaustin.public"
	TEMPLATE_FILE=$SRCROOT/support/Plist/GoogleService-Info-Production.plist
fi

OUTPUT_FILE=$SRCROOT/support/Plist/GoogleService-Info.plist

cp $TEMPLATE_FILE $OUTPUT_FILE