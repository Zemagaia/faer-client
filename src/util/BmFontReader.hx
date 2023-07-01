package util;

import util.NativeTypes;
import haxe.ds.Vector.Vector;

class CharacterDef {
	public var id: Int32;
	public var x: Float32;
	public var y: Float32;
	public var width: Float32;
	public var height: Float32;
	public var xOffset: Float32;
	public var yOffset: Float32;
	public var xAdvance: Float32;

	public function new() {}
}

class BmFontReader {
	public static function read(str: String): Vector<CharacterDef> {
		var currentFont = new Vector<CharacterDef>(256);
		var lines = str.split("\n");
        for (i in 0...lines.length) {
			var split = StringTools.trim(lines[i]).split(" ");
            if (split[0] == "char") {
				var char = new CharacterDef();
                for (j in 1...split.length) {
                    var data = split[j].split("=");
					switch (data[0]) {
						case "id":
							char.id = Std.parseInt(data[1]);
						case "x":
							char.x = Std.parseFloat(data[1]);
						case "y":
							char.y = Std.parseFloat(data[1]);
						case "width":
							char.width = Std.parseFloat(data[1]);
						case "height":
							char.height = Std.parseFloat(data[1]);
						case "xoffset":
							char.xOffset = Std.parseFloat(data[1]);
						case "yoffset":
							char.yOffset = Std.parseFloat(data[1]);
						case "xadvance":
							char.xAdvance = Std.parseFloat(data[1]);
					}
                }
				currentFont[char.id] = char;
            }
        }

		return currentFont;
	}
}