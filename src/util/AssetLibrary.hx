package util;

import util.BinPacker.Rect;
import haxe.ds.StringMap;
import openfl.display.BitmapData;

class AssetLibrary {
	private static var images: StringMap<BitmapData> = new StringMap<BitmapData>();
	private static var imageSets: StringMap<ImageSet> = new StringMap<ImageSet>();

	public static function addImageSet(name: String, data: BitmapData, width: Int, height: Int, ignoreAtlas: Bool = false) {
		images.set(name, data);
		var imageSet = new ImageSet();
		imageSet.addFromBitmapData(data, width, height, ignoreAtlas);
		imageSets.set(name, imageSet);
		data.dispose();
		data = null;
	}

	public static function getImage(name: String) {
		return images.get(name);
	}

	public static function getImageSet(name: String) {
		return imageSets.get(name);
	}

	public static function getImageFromSet(name: String, id: Int) {
		if (id < 0 || !imageSets.exists(name) || id >= imageSets.get(name).images.length) {
			trace('Could not parse image: $name (id: $id, exists: ${imageSets.exists(name)}, imagesLen: ${imageSets.get(name)?.images.length})');
			return new BitmapData(8, 8, false, 0);
		}

		return imageSets.get(name).images[id];
	}

	public static function getRectFromSet(name: String, id: Int) {
		if (id < 0 || !imageSets.exists(name) || id >= imageSets.get(name).rects.length) {
			trace('Could not parse rect: $name (id: $id, exists: ${imageSets.exists(name)}, rectsLen: ${imageSets.get(name)?.rects.length})');
			return new Rect(4096, 4096, 8, 8);
		}

		return imageSets.get(name).rects[id];
	}
}
