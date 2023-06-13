package objects.particles;

import util.NativeTypes;
import objects.GameObject;
import openfl.geom.Point;

class NovaEffect extends ParticleEffect {
	public var startX: Float32 = 0.0;
    public var startY: Float32 = 0.0;
	public var novaRadius: Float32 = 0.0;
	public var color: UInt = 0;

	public function new(startX: Float32, startY: Float32, radius: Float32, color: UInt) {
		super();
		this.startX = startX;
        this.startY = startY;
		this.novaRadius = radius;
		this.color = color;
	}

	override public function update(time: Int32, dt: Int16) {
		mapX = this.startX;
		mapY = this.startY;
		var prtCount = Std.int(4 + this.novaRadius * 2);
        for (i in 0...prtCount) {
			var angle = i * 2 * Math.PI / prtCount;
			map.addGameObject(new SparkerParticle(2, this.color, 200, this.startX, this.startY, this.startX + this.novaRadius * Math.cos(angle),
				this.startY + this.novaRadius * Math.sin(angle)),
				mapX, mapY);
        }

		return false;
	}
}