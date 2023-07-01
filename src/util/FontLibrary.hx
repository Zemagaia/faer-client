package util;

import openfl.geom.Point;
import util.BmFontReader.CharacterDef;
import openfl.utils.Assets;
import openfl.geom.Rectangle;
import haxe.ds.Vector.Vector;

class FontLibrary {
	public static var charMap = new Vector<CharacterDef>(256);

    public static function textWidth(text: String, size: Float) {
		var w = 0.0;
		var scale = size / 64;
		for (i in 0...text.length) {
			var code = text.charCodeAt(i);
			var char = charMap[code];
			if (char == null) {
				w += 28 * scale; // assume space
				continue;
			}

			w += (char.xAdvance + char.xOffset) * scale * 2;
		}

        return w;
    }

    public static function textHeight(text: String, size: Float) {
        var minStart = 0.0, maxEnd = 0.0;
		var scale = size / 64;
		for (i in 0...text.length) {
			var code = text.charCodeAt(i);
			var char = charMap[code];
			if (char == null)
				continue;

            var yOffsetScaled = char.yOffset * scale;
            if (minStart > yOffsetScaled)
                minStart = yOffsetScaled;

			var h = yOffsetScaled + char.height * scale;
            if (maxEnd < h)
                maxEnd = h;
		}

        return maxEnd - minStart;
    }

    public static function parse() {
		var fontData = BmFontReader.read(Assets.getText("assets/fonts/ubuntu.fnt"));
		var fontAtlas = Assets.getBitmapData("assets/fonts/ubuntu.png");
		for (charData in fontData) {
			if (charData == null || charData.width == 0 || charData.height == 0)
				continue;

			var rect = Main.atlasPacker.insert(charData.width, charData.height);
			Main.tempAtlas.copyPixels(fontAtlas, new Rectangle(charData.x, charData.y, charData.width, charData.height), new Point(rect.x, rect.y));

			charData.x = rect.x;
			charData.y = rect.y;
			charData.width = rect.width;
			charData.height = rect.height;

			charMap[charData.id] = charData;
		}
    }
}