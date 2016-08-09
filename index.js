import {
	Platform,
	NativeModules,
	CameraRoll
} from 'react-native'

var RCTCameraRollManager = NativeModules.CameraRollExtendedManager;

class CameraRollExtended {

	static saveImageWithTag(tag: Object): Promise<Object> {
		console.warn('CameraRoll.saveImageWithTag is deprecated. Use CameraRoll.saveToCameraRoll instead');
		return this.saveToCameraRoll(tag, 'photo');
	}

	static saveToCameraRoll(tag: Object, type?: 'photo' | 'video'): Promise<Object> {
		let mediaType = 'photo';
		if (type) {
			mediaType = type;
		} else if (['mov', 'mp4'].indexOf(tag.split('.').slice(-1)[0]) >= 0) {
			mediaType = 'video';
		}

		return RCTCameraRollManager.saveToCameraRoll(tag, mediaType);
	}

	static getPhotos(params) {
		return CameraRoll.getPhotos(params)
	}
}


module.exports = CameraRollExtended

