package util;

import util.BinPacker.Rect;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;

class ImageSet {
	public final images: Array<BitmapData>;
	public final rects: Array<Rect>;
	public var allowsAtlas = true;

	public final function new() {
		this.images = [];
		this.rects = [];
	}

	public final function add(bitmapData: BitmapData) {
		this.images.push(bitmapData);
	}

	public final function random() {
		return this.images[Std.int(Math.random() * this.images.length)];
	}

	public final function addFromBitmapData(bitmapData: BitmapData, width: Int, height: Int, ignoreAtlas: Bool = false) {
		this.allowsAtlas = !ignoreAtlas;

		var maxX = Std.int(bitmapData.width / width),
			maxY = Std.int(bitmapData.height / height);
		for (y in 0...maxY)
			for (x in 0...maxX) {
				var tex = BitmapUtil.cropToBitmapData(bitmapData, x * width, y * height, width, height);
				this.images.push(tex);

				if (!ignoreAtlas && BitmapUtil.amountTransparent(tex) < 1) {
					var rect = Main.atlasPacker.insert(width + Main.PADDING * 2, height + Main.PADDING * 2);
					this.rects.push(rect);
					Main.tempAtlas.copyPixels(tex, new Rectangle(0, 0, rect.width, rect.height), new Point(rect.x + Main.PADDING, rect.y + Main.PADDING));
				} else
					this.rects.push(new Rect(4096, 4096, 8, 8));
			}
	}
}
