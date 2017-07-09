# React Native Store Photos Album
React-native camera roll extension to store photos in specific album

## Installation
```sh
npm install francisco-sanchez-molina/react-native-store-photos-album --save
```


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
