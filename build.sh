#!/bin/sh

# create folder where we place built frameworks
mkdir build
mkdir build/devices

### build framework for simulators
xcodebuild  clean build -scheme WoosmapGeofencing -configuration Release -sdk iphoneos -derivedDataPath derived_data build SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

## copy compiled framework for simulator into our build folder
cp -r derived_data/Build/Products/Release-iphoneos/WoosmapGeofencing.framework build/devices

##build framework for devices
mkdir build/simulator
xcodebuild -scheme WoosmapGeofencing -configuration Release -sdk iphonesimulator -derivedDataPath derived_data build ONLY_ACTIVE_ARCH=NO SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

cp -r derived_data/Build/Products/Release-iphonesimulator/WoosmapGeofencing.framework build/simulator

######################## Create universal framework #############################
xcodebuild -create-xcframework -allow-internal-distribution -output build/WoosmapGeofencing.xcframework \
        -framework build/devices/WoosmapGeofencing.framework -framework build/simulator/WoosmapGeofencing.framework

