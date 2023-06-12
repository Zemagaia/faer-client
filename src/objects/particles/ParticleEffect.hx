package objects.particles;

import objects.GameObject;
import util.NativeTypes;

class ParticleEffect extends GameObject {
	private static var nextFakeObjectId: Int32 = 0;

	public function new() {
		super(null, "ParticleEffect");
		objectId = 0x7F000000 | nextFakeObjectId++;
	}
}
