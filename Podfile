platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

xcodeproj 'FuelMeDriver/RideDriver.xcodeproj'
source 'https://github.com/ride-austin/ios-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

abstract_target 'driver_pods' do
    pod 'BugfenderSDK/ObjC'
    pod 'Crashlytics'
    pod 'CZPhotoPickerController'
    pod 'Fabric'
    pod 'FBSDKCoreKit'
    pod 'FBSDKLoginKit'
    pod 'FBSDKShareKit'
    pod 'Firebase/Analytics'
    pod 'Firebase/Core'
    pod 'Firebase/InAppMessagingDisplay'
    pod 'Firebase/Messaging'
    pod 'Firebase/RemoteConfig'
    pod 'GoogleMaps'
    pod 'GooglePlaces'
    pod 'LGRefreshView', '~> 1'
    pod 'Mantle'
    pod 'NSString+RemoveEmoji'
    pod 'REFormattedNumberField'
    pod 'RestKit'
    pod 'RxCocoa'
    pod 'SAMKeychain'
    pod 'SDWebImage'
    pod 'SinchVerification'
    pod 'SVProgressHUD'
    pod 'TTTAttributedLabel'
    pod 'UIActivityIndicator-for-SDWebImage', :git => 'https://github.com/tedgonzalez/UIActivityIndicator-for-SDWebImage.git'
    pod 'XLForm'
    
    #swift
#    pod 'MRCountryPicker', :git => 'https://github.com/tedgonzalez/MRCountryPicker.git' #swift 3
#    pod 'TrueTime', '~> 4.1.5' #swift 3
    pod 'MRCountryPicker', :git => 'https://github.com/tedgonzalez/MRCountryPicker.git', :branch => 'objc' #swift 4
    pod 'TrueTime', :git => 'https://github.com/instacart/TrueTime.swift.git', :commit => '8aadebabe2590d6ab295c390df5bbc109b346348' #swift 4

    #for testing
    pod 'OHHTTPStubs'

    target 'RideDriverTest - Enterprise'
    target 'DriverUnitTests'
    target 'DriverUnitTestsSwift'
end
