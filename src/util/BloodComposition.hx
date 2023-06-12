package util;
import openfl.display.BitmapData;
import util.NativeTypes;

class BloodComposition {
	private static var imageDict: Map<BitmapData, Array<Int32>> = new Map<BitmapData, Array<Int32>>();

	public static function getBloodComposition(id: Int32, image: BitmapData, bloodProb: Float32, bloodColor: Int32) {
		var comp = new Array<Int32>();
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
		var color: Int32 = 0;
		var colors = new Array<Int32>();
		for (x in 0...image.width)
			for (y in 0...image.height) {
				color = image.getPixel32(x, y);
				if ((color & 0xFF000000) != 0)
					colors.push(color);
			}

		return colors;
	}
}