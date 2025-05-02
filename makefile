BASE_URL := $(shell cat ./.env)

default: web

web:
	flutter run -d chrome --dart-define=BASE_URL=$(BASE_URL)

android:
	flutter run -d emulator-5554 --dart-define=BASE_URL=$(BASE_URL)

emu:
	flutter emulators --launch Pixel

build_web:
	flutter build web --dart-define=BASE_URL=$(BASE_URL)

build_android:
	flutter build apk --dart-define=BASE_URL=$(BASE_URL)

.PHONY: default web android build_web build_android
