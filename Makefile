APP_NAME        := StickyNotes
DISPLAY_NAME    := Sticky Notes
BUNDLE_ID       := com.stickynotes.app
VERSION         := 1.0.0
BUILD_NUMBER    := 1
MIN_MACOS       := 14.0
CONFIGURATION   := release

BUILD_DIR       := .build/$(CONFIGURATION)
DIST_DIR        := dist
APP_BUNDLE      := $(DIST_DIR)/$(APP_NAME).app
DMG_STAGING     := $(DIST_DIR)/dmg
DMG_OUT         := $(DIST_DIR)/$(APP_NAME).dmg
RESOURCE_BUNDLE := $(APP_NAME)_$(APP_NAME).bundle
ICON_NAME       := AppIcon

# Ad-hoc by default. Override for distribution:
#   make dmg SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"
SIGN_IDENTITY   ?= -

.DEFAULT_GOAL := dmg
.PHONY: all build app sign dmg verify clean clean-all run test open

all: dmg

## Compile the SwiftPM targets.
build:
	swift build -c $(CONFIGURATION)

## Assemble the .app bundle (SwiftPM only produces a bare executable).
app: build
	rm -rf $(APP_BUNDLE)
	mkdir -p $(APP_BUNDLE)/Contents/MacOS $(APP_BUNDLE)/Contents/Resources
	cp $(BUILD_DIR)/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)
	cp $(BUILD_DIR)/$(RESOURCE_BUNDLE)/$(ICON_NAME).icns $(APP_BUNDLE)/Contents/Resources/$(ICON_NAME).icns
	cp -R $(BUILD_DIR)/$(RESOURCE_BUNDLE) $(APP_BUNDLE)/Contents/Resources/$(RESOURCE_BUNDLE)
	printf '%s\n' \
		'<?xml version="1.0" encoding="UTF-8"?>' \
		'<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
		'<plist version="1.0">' \
		'<dict>' \
		'	<key>CFBundleDevelopmentRegion</key>' \
		'	<string>en</string>' \
		'	<key>CFBundleExecutable</key>' \
		'	<string>$(APP_NAME)</string>' \
		'	<key>CFBundleIdentifier</key>' \
		'	<string>$(BUNDLE_ID)</string>' \
		'	<key>CFBundleInfoDictionaryVersion</key>' \
		'	<string>6.0</string>' \
		'	<key>CFBundleName</key>' \
		'	<string>$(DISPLAY_NAME)</string>' \
		'	<key>CFBundleDisplayName</key>' \
		'	<string>$(DISPLAY_NAME)</string>' \
		'	<key>CFBundlePackageType</key>' \
		'	<string>APPL</string>' \
		'	<key>CFBundleShortVersionString</key>' \
		'	<string>$(VERSION)</string>' \
		'	<key>CFBundleVersion</key>' \
		'	<string>$(BUILD_NUMBER)</string>' \
		'	<key>CFBundleIconFile</key>' \
		'	<string>$(ICON_NAME)</string>' \
		'	<key>LSMinimumSystemVersion</key>' \
		'	<string>$(MIN_MACOS)</string>' \
		'	<key>NSHighResolutionCapable</key>' \
		'	<true/>' \
		'	<key>NSPrincipalClass</key>' \
		'	<string>NSApplication</string>' \
		'</dict>' \
		'</plist>' > $(APP_BUNDLE)/Contents/Info.plist
	plutil -lint $(APP_BUNDLE)/Contents/Info.plist
	@echo "Assembled $(APP_BUNDLE)"

## Sign the bundle. Ad-hoc by default; set SIGN_IDENTITY for a Developer ID.
sign: app
	codesign --force --options runtime --sign "$(SIGN_IDENTITY)" $(APP_BUNDLE)
	codesign --verify --deep --strict --verbose=2 $(APP_BUNDLE)

## Build the DMG from the signed bundle.
dmg: sign
	@command -v create-dmg >/dev/null 2>&1 || { echo "create-dmg not found. Install with: brew install create-dmg"; exit 1; }
	rm -rf $(DMG_STAGING) $(DMG_OUT)
	mkdir -p $(DMG_STAGING)
	cp -R $(APP_BUNDLE) $(DMG_STAGING)/$(APP_NAME).app
	create-dmg \
		--volname "$(DISPLAY_NAME)" \
		--volicon "$(APP_BUNDLE)/Contents/Resources/$(ICON_NAME).icns" \
		--window-pos 200 120 \
		--window-size 640 400 \
		--icon-size 120 \
		--icon "$(APP_NAME).app" 160 190 \
		--hide-extension "$(APP_NAME).app" \
		--app-drop-link 480 190 \
		--no-internet-enable \
		"$(DMG_OUT)" \
		"$(DMG_STAGING)"
	@echo "Created $(DMG_OUT)"

## Check the integrity of the generated DMG.
verify:
	hdiutil verify $(DMG_OUT)

## Remove build and distribution artifacts.
clean:
	rm -rf $(DIST_DIR)

clean-all: clean
	swift package clean

run:
	swift run $(APP_NAME)

test:
	swift test

open: dmg
	open $(DMG_OUT)
