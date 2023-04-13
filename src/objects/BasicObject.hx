package objects;

import util.NativeTypes;
import map.Camera;
import map.Map;
import map.Square;

class BasicObject {
	private static var nextFakeObjectId = 0;

	public var map: Map;
	public var curSquare: Square;
	public var objectId: Int32 = 0;
	public var mapX: Float32 = 0.0;
	public var mapY: Float32 = 0.0;
	public var mapZ: Float32 = 0.0;
	public var screenX: Float32 = 0.0;
	public var screenY: Float32 = 0.0;
	public var screenYNoZ: Float32 = 0.0;
	public var sortVal: Int16 = 0;

	public static function getNextFakeObjectId() {
		return 0x7F000000 | nextFakeObjectId++;
	}

	public function new() {
		this.clear();
	}

	public function clear() {
		this.map = null;
		this.curSquare = null;
		this.objectId = -1;
		this.mapX = this.mapY = this.mapZ = 0;
	}

	public function dispose() {
		this.map = null;
		this.curSquare = null;
	}

	public function update(time: Int32, dt: Int16) {
		return true;
	}

	public function draw(time: Int32) {}

	public function calcScreenCoords() {
		this.screenX = this.mapX * Camera.cos + this.mapY * Camera.sin + Camera.csX;
		this.screenYNoZ = this.mapX * -Camera.sin + this.mapY * Camera.cos + Camera.csY;
		this.screenY = this.screenYNoZ + this.mapZ * -Camera.PX_PER_TILE;
		this.sortVal = Std.int(this.screenY);
	}

	public function addTo(map: Map, x: Float32, y: Float32) {
		this.map = map;
		this.curSquare = this.map.lookupSquare(Std.int(x), Std.int(y));
		this.mapX = x;
		this.mapY = y;
		return true;
	}

	public function removeFromMap() {
		this.map = null;
		this.curSquare = null;
	}
}
