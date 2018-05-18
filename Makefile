all:
	xcodegen

clean:
	rm -rf Logger.xcodeproj/project.xcworkspace/xcuserdata
	rm -rf Logger.xcodeproj/xcuserdata

profile:
	xcodebuild -destination 'platform=iOS Simulator,name=iPhone X' \
  		-sdk iphonesimulator -project Logger.xcodeproj \
  		-scheme Logger -configuration Debug \
  		clean build \
  		OTHER_SWIFT_FLAGS="-driver-time-compilation \
    	-Xfrontend -debug-time-function-bodies \
    	-Xfrontend -debug-time-compilation" | \
		tee profile.log

profile-log:
	awk '/Driver Compilation Time/,/Total$/ { print }' profile.log | \
		grep compile | \
		cut -c 55- | \
		sed -e 's/^ *//;s/ (.*%)  compile / /;s/ [^ ]*Bridging-Header.h$//' | \
		sed -e "s|$(pwd)/||" | \
		sort -rn | \
		tee slowest.log

