package objects.particles;

import util.AssetLibrary;
import util.NativeTypes;

class Particle extends GameObject {
	private static var nextFakeObjectId: Int32 = 0;

	public function new(color: UInt, z: Float32, size: Float32, particleIdx: Int32 = 0) {
		super(null, "Particle");
		objectId = 0x7F000000 | nextFakeObjectId++;
		this.mapZ = z;

		var rect = AssetLibrary.getRectFromSet("particles", particleIdx);
		this.uValue = rect.x / Main.ATLAS_WIDTH;
		this.vValue = rect.y / Main.ATLAS_HEIGHT;
		this.width = rect.width / Main.ATLAS_WIDTH;
		this.height = rect.height / Main.ATLAS_HEIGHT;

		this.setColor(color);
		this.setOutlineSize(1);
		this.size = size;
	}

	public function setColor(color: Float32) {
		this.flashPeriodMs = 0;
		this.flashRepeats = -1;
		this.flashColor = color;
	}

	public function setGlowColor(glowColor: Float32) {
		this.glowColor = glowColor;
	}

	public function setOutlineSize(outlineSize: Float32) {
		this.outlineSize = outlineSize;
	}
}
