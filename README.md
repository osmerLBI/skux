# skux
skux and tern combined project

## TestFlight
1. run `flutter build ios --release --obfuscate --split-debug-info=./symbols`
2. open `ios/Runner.xcworkspace` with Xcode
3. modify `Build` version on `Targets-General-Identity-Build`
4. select `product/archive`
> if not available, choose `Any ios Device` on the top
5. select `Distribute App` after building
6. select `App Store Connect` and click `next`
7. select `Upload` and click `next`
8. login in the `https://appstoreconnect.apple.com/`
9. select `Skux->TestFlight->Internal Testers` and add the latest version if available#   s k u x  
 