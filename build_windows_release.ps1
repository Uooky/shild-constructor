flutter config --enable-windows-desktop
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter build windows
Write-Host "Windows build complete."
Write-Host "Output: build/windows/x64/runner/Release"
