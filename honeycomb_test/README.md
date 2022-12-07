# How to build Honeycomb

### 1. [Install Xcode](https://apps.apple.com/us/app/xcode/id497799835?mt=12)
Make sure to agree to the licensing and install the iOS emulator <br>
If you plan on distributing your build, add an iCloud account and add that team to the Runner's signing settings

### 2. [Install Flutter](https://docs.flutter.dev/get-started/install/macos)
Download the SDK and [add it to your path](https://docs.flutter.dev/get-started/install/macos#update-your-path) <br>
#### If using zsh shell ⤵
  1. Open terminal and run the following line:

    nano ~/.zshrc
    
  2. Add this line:

    export PATH="$PATH:[PATH_OF_FLUTTER_GIT_DIRECTORY]/bin"

<br>
Close and re-open terminal to reset the terminal instance <br>
Run flutter doctor to make sure it is installed properly

    flutter doctor
    
#### Note: You won't need a Chrome executable, Android SDK, or Android Studio for this

### 3. [Install CocoaPods](https://guides.cocoapods.org/using/getting-started.html#installation)
Run the following:

    sudo gem install cocoapods

I would recommend running ' flutter doctor ' again here to make sure CocoaPods installed properly

### 4. Add secret files
We've kept files containing API keys hidden from our repo <br>
  #### [For our UW advisors](https://drive.google.com/drive/folders/1VkhKXAiUUY4NAtTsSqyQHP_2u-uILRXT?usp=share_link)
  #### [For anyone else](https://drive.google.com/drive/folders/1--5c8sVqeD1T9PjwUEeIeOzYvnfSHHgO?usp=share_link)

### 5. Install dependencies with pub get
Open terminal at honeycomb_test and run the following:

    flutter pub get
    
### 6. Setup backend APIs with Firestore

```bash
# Install the CLI if not already done so
dart pub global activate flutterfire_cli

# Run the `configure` command, select a Firebase project and platforms
flutterfire configure
``` 

### 7. Build!

Open ios/runner.xcodeproj in Xcode <br>
