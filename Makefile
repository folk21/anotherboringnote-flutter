.PHONY: bootstrap check web macos android ios
bootstrap:
	bash scripts/bootstrap.sh
check:
	bash scripts/run_checks.sh
web:
	flutter run -d chrome
macos:
	flutter run -d macos
android:
	flutter run -d android
ios:
	flutter run -d ios
