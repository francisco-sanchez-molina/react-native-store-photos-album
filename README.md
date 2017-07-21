# React Native Store Photos Album
React-native camera roll extension to store photos in specific album

## Installation
```sh
npm install francisco-sanchez-molina/react-native-store-photos-album --save
react-native link react-native-store-photos-album
```

Before using this you must link the RCTCameraRoll library. You can refer to [Linking](https://facebook.github.io/react-native/docs/linking-libraries-ios.html) for help.

## Usage

```JavaScript
import CameraRollExtended from 'react-native-store-photos-album'

CameraRollExtended.saveToCameraRoll({uri: photoPath, album: 'Test'}, 'photo')
```
or with additional `fileName` parameter (it could rename image, works only on Android):

```JavaScript
CameraRollExtended.saveToCameraRoll({uri: photoPath, album: 'Test', fileName: 'greatPicture.jpg'}, 'photo')
```

version 0.1.0 add react-native 0.40 support
