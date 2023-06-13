package objects.particles;

import util.NativeTypes;
import objects.GameObject;
import openfl.geom.Point;

class RingEffect extends ParticleEffect {
	public var startX: Float32 = 0.0;
	public var startY: Float32 = 0.0;
	public var novaRadius: Float32 = 0.0;
	public var color: UInt = 0;
	public var cooldown = 0;
	private var lastActivate = 0;

	public function new(go: GameObject, radius: Float32, color: UInt, cooldown: Int32) {
		super();
		this.startX = go.mapX;
		this.startY = go.mapY;
		this.novaRadius = radius;
		this.color = color;
		this.cooldown = cooldown;
	}

	override public function update(time: Int32, dt: Int16) {
		if (this.cooldown > 0 && time < this.lastActivate + this.cooldown)
			return true;

		mapX = this.startX;
		mapY = this.startY;
		for (i in 0...12) {
			var angle = (i * 2 * Math.PI) / 12;
			map.addGameObject(new SparkerParticle(0, this.color, 200, this.startX + this.novaRadius * 0.9 * Math.cos(angle),
				this.startY + this.novaRadius * 0.9 * Math.sin(angle),
				this.startX + this.novaRadius * Math.cos(angle),
				this.startY + this.novaRadius * Math.sin(angle)), mapX, mapY);
		}

		this.lastActivate = time;
		return this.cooldown > 0;
	}
}
