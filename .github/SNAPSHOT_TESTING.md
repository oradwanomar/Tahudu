# Snapshot testing

The DesignSystem, Search, and Settings packages use SnapshotTesting with Swift Testing. Their reference PNGs live beside the test files in `__Snapshots__` directories and are tracked by Git LFS.

Install Git LFS and run `git lfs install` before checking out the repository. Run the image tests on an iPhone 17 Pro simulator with iOS 26.5, the device and runtime used to record the references:

```sh
xcodebuild test -project Tahudu.xcodeproj -scheme DesignSystemTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' -testLanguage en -testRegion US
xcodebuild test -project Tahudu.xcodeproj -scheme Search -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' -testLanguage en -testRegion US
xcodebuild test -project Tahudu.xcodeproj -scheme Settings -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' -testLanguage en -testRegion US
```

When adding a snapshot, the first test run records its reference and fails. Review the PNG, then rerun the test. To approve a visual change, update the reference with SnapshotTesting's `record: .all` setting, review the new image, remove the setting, and rerun the tests.
