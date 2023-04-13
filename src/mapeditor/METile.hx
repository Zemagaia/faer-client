package mapeditor;

class METile {
	public var types: Array<Int>;
	public var objName = "";

	public function new() {
		this.types = [-1, -1, -1];
	}

	public function clone() {
		var tile = new METile();
		if (this.types.length > 0)
			tile.types = this.types.copy();
		tile.objName = this.objName;
		return tile;
	}

	public function isEmpty() {
		for (i in 0...Layer.NUM_LAYERS)
			if (this.types[i] != -1)
				return false;

		return true;
	}
}
