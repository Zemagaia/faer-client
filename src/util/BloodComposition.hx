package util;

import openfl.display.BitmapData;
import util.NativeTypes;

class BloodComposition {
	private static var imageDict: Map<BitmapData, Array<UInt>> = new Map<BitmapData, Array<UInt>>();

	public static function getBloodComposition(id: Int32, image: BitmapData, bloodProb: Float32, bloodColor: UInt) {
		var comp = new Array<UInt>();
		if (image == null)
			return comp;

		var colors = getColors(image);
		for (i in 0...colors.length) {
			if (Math.random() < bloodProb)
				comp.push(bloodColor);
			else
				comp.push(colors[Math.round(colors.length * Math.random())]);
		}

		return comp;
	}

	public static function getColors(image: BitmapData) {
		var colors = imageDict.get(image);
		if (colors == null) {
			colors = buildColors(image);
			imageDict.set(image, colors);
		}

		return colors;
	}

	private static function buildColors(image: BitmapData) {
		var colors = new Array<UInt>();
		for (x in 0...image.width)
			for (y in 0...image.height) {
				var color: UInt = image.getPixel32(x, y);
				if ((color & 0xFF000000) != 0)
					colors.push(color - 0xFF000000);
			}

		return colors;
	}
}
