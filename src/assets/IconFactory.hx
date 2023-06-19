package assets;

import openfl.display.BitmapData;
import util.AssetLibrary;
import util.BitmapUtil;
import util.GlowRedrawer;
import util.TextureRedrawer;

class IconFactory {
	public static function makeGems(size: Int = 40) {
		return cropAndGlowIcon(TextureRedrawer.resize(AssetLibrary.getImageFromSet("misc", 21), size, true));
	}

	public static function makeGold(size: Int = 40) {
		return cropAndGlowIcon(TextureRedrawer.resize(AssetLibrary.getImageFromSet("misc", 20), size, true));
	}

	private static function cropAndGlowIcon(data: BitmapData) {
		data = GlowRedrawer.outlineGlow(data, 0xFFFFFFFF);
		data = BitmapUtil.cropToBitmapData(data, 10, 10, data.width - 20, data.height - 20);
		return data;
	}
}
