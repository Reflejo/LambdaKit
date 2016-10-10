PROJECT?=LambdaKit.xcodeproj

.PHONY: build project

build: $(PROJECT)
	xcodebuild -project LambdaKit.xcodeproj -configuration Release clean build

project: $(PROJECT)

$(PROJECT):
	swift package generate-xcodeproj \
		--xcconfig-overrides settings.xcconfig \
		--output $(PROJECT)
