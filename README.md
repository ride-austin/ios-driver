# RideAustin Driver
> Driver iOS App for RiderAustin 

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/EZSwiftExtensions.svg)](https://img.shields.io/cocoapods/v/LFAlertController.svg)  
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) 

Ride sharing is valuable to all citizens, empowers drivers and riders, saves lives and is part of any transportation future. We created RideAustin to get the city moving again and to reinvest in our community.

RideAustin is a non-profit ride share built for the Austin community. It is powered by donations, with paid and volunteer hours from both the Austin tech community and the broader Austin community working together. We believe ride sharing saves lives, empowers drivers & riders and is part of any transportation future.


![](https://static1.squarespace.com/static/57302ab61d07c088bf6e694b/57408281e3214003460a6d3a/5740828137013bfb815d1b4a/1463845509237/phone-main.jpg?format=1000w)

## Requirements

- iOS 12.0+
- Xcode 10.2.1
- Configure SSH for the github 

## Installation

- Install Bundler to manage ruby gems [Bundler guide](https://bundler.io) after installation successful run:

```
bundle install
```
- Install pods

```
bundle exec pod install
```

## Troubleshooting

- After running pod install if it fails with the following error

```
Unable to add a source with url `git@github.com:ride-austin/ios-podspecs.git` named `ride-austin`
```
check SSH configuration  check guide [SSH Help](https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent)  

## Environmental Variables

This project is configured with Fastlane to work with CLI tools  here are the environmental variables available in the fastlane that can be provided in `/fastlane/.env.default` file 

### Required

- __FASTLANE_USERNAME:__ This name is shown in the messages for example  `RideAustin Version 5.1.0b (708) uploaded by:xyz@rideaustin.com`  in this message `xyz@rideaustin.com` is through this variable.  Also used in built in fastlane actions for example  `match` , `pilot`  

- __FASTLANE_PASSWORD:__ Password used in fastlane for built in fastlane actions used. 

- __FASTLANE_TEAM_ID:__ The ID of your Developer Portal team if you're in multiple teams e.g. XXXXXXYVXX

- __GOOGLE_MAP_KEY:__ To use the Maps SDK for iOS you must have an API key. The API key is a unique identifier that is used to authenticate requests associated with your project for usage and billing purposes. To learn more see the [guide](https://developers.google.com/maps/documentation/ios-sdk/get-api-key) and [API Key Best Practices](https://developers.google.com/maps/api-key-best-practices) 

- __GOOGLE_MAP_DIRECTIONS_KEY:__ To use the Directions API, you must get an API key which you can then add to your mobile app, website, or web server. The API key is used to track API requests associated with your project for usage and billing. To learn more about API keys, see the [API Key Best Practices](https://developers.google.com/maps/api-key-best-practices) 

- __MATCH_GIT_FULL_NAME:__ git user full name to commit

- __MATCH_GIT_URL:__ URL to the git repo containing all the certificates

- __MATCH_GIT_USER_EMAIL:__ git user email to commit

- __MATCH_PASSWORD:__ Provide the password for the match in this variable. Here is the guideline for configuring the match [guide](https://docs.fastlane.tools/actions/match/)

- __MATCH_USERNAME:__ Your Apple ID Username

- __MD5_PASSWORD_SALT:__  Provide MD5 salt for encryption of password which matches the one used in RideAustin/Server  get more information [here](https://www.md5online.org/blog/md5-salt-hash/) 

- __PEM_TEAM_ID:__ Team ID for the your provisioning profile

- __PEM_USERNAME:__ Your Apple ID Username for provisioning profile 

- __PILOT_TEAM_ID:__ Team ID for uploading to Appstore Connect

- __PILOT_USERNAME:__ Your Apple ID Username for uploading to Appstore Connect

- __PRODUCTION_SERVER_URL:__ Provide production server url for the apis. 

### Optional

- __APPCENTER_OWNER_NAME:__ Add owner name of the app to be uploaded on Appcenter to get App owner name find at `https://appcenter.ms/orgs/<APPCENTER_OWNER_NAME>`

- __APPCENTER_API_TOKEN:__ Add Api token for Appcenter.  Goto. `https://appcenter.ms/orgs/<organization-name>/applications?os=iOS` then in account settings, you can create token.  `Settings / API tokens`

- __BUG_FENDER_KEY:__  Add bugfender key for configuring bugfender check [guide](http://support.bugfender.com/getting-started/first-steps-with-bugfender)  

- __CRASHLYTICS_API_TOKEN:__ Get the api token from   [organization settings](https://www.fabric.io/settings/organizations) page

- __CRASHLYTICS_BUILD_SECRET:__ Get the build secret from   [organization settings](https://www.fabric.io/settings/organizations) page

- __DEV_SERVER_URL:__  If you have a Dev environment you can provide Dev server url for the apis. 

- __ENTERPRISE_APP_IDENTIFIER_PROD:__ App ID for Enterprise app distribution to distribute the production build 

- __ENTERPRISE_APP_IDENTIFIER_QA:__ App ID for Enterprise app distribution to distribute the QA build

- __ENTERPRISE_APPCENTER_APP_NAME_PROD:__ Add your app name to be uploaded on Appcenter to get App name find at `https://appcenter.ms/orgs/<APPCENTER_OWNER_NAME>/apps/<APPCENTER_APP_NAME>`

- __ENTERPRISE_APPCENTER_APP_NAME_QA:__ Add your app name to be uploaded on Appcenter to get App name find at `https://appcenter.ms/orgs/<APPCENTER_OWNER_NAME>/apps/<APPCENTER_APP_NAME>`

- __ENTERPRISE_FASTLANE_TEAM_ID:__ Team ID for Enterprise app distribution 

- __ENTERPRISE_MATCH_APP_IDENTIFIER_PROD:__ App ID for Match for production enterprise distribution.

- __ENTERPRISE_MATCH_APP_IDENTIFIER_QA:__ App ID for Match for QA enterprise distribution

- __ENTERPRISE_MATCH_APP_IDENTIFIERS:__ Give the list of APP IDs for the match e.g  "com.xyz.ride.beta ,com.driver,com.driver.test"

- __ENTERPRISE_MATCH_GIT_URL:__ URL to the git repo containing all the enterprise certificates

- __ENTERPRISE_MATCH_USERNAME:__ git user email to commit

- __ENTERPRISE_PEM_TEAM_ID:__ Team ID for the your enterprise provisioning profile

- __ENTERPRISE_PEM_USERNAME:__ Your Apple ID Username for enterprise provisioning profile 

- __GOOGLE_SERVICE_INFO_PLIST_PRODUCTION:__ When using circleci, run ```base64 GoogleService-Info-Production.plist``` and use the output as environment variable. Otherwise, just add the file FuelMeDriver/support/Plist/GoogleService-Info-Production.plist to enable firebase services in production for app store distribution

- __GOOGLE_SERVICE_INFO_PLIST_PRODUCTION_ENTERPRISE:__ When using circleci, run ```base64 GoogleService-Info-ProductionEnterprise.plist``` and use the output as environment variable. Otherwise, just add the file FuelMeDriver/support/Plist/GoogleService-Info-ProductionEnterprise.plist to enable firebase services in production for enterprise distribution

- __GOOGLE_SERVICE_INFO_PLIST_QA:__ When using circleci, run ```base64 GoogleService-Info-QA.plist``` and use the output as environment variable. Otherwise, just add the file FuelMeDriver/support/Plist/GoogleService-Info-QA.plist to enable firebase services in QA environment for enterprise distribution

- __QA_SERVER_URL:__ If you have a QA environment you can provide QA server url for the apis. 

- __SLACK_URL:__ Provide webhook url for the slack to post the updates on the slack. Follow these steps to add webhook in your slack channel  [guide](https://api.slack.com/incoming-webhooks)

- __STAGE_SERVER_URL:__  If you have a Stage environment you can provide Stage server url for the apis. 

## Contribute 

We would love you for the contribution to **RideAustin Driver**, check the  [LICENSE](LICENSE) file for more info.

## Meta

Distributed under the MIT License. See  [LICENSE](LICENSE) for more information.
