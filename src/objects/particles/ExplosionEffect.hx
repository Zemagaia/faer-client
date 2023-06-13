package objects.particles;

import objects.particles.Particle;
import util.NativeTypes;

class ExplosionEffect extends ParticleEffect {
	public var colors: Array<UInt>;
	public var numParts: Int = 0;

	public function new(colors: Array<UInt>, size: Float32, numParts: Int32) {
		super();
		this.colors = colors;
		this.size = size;
		this.numParts = numParts;
	}

	override public function update(time: Int32, dt: Int16) {
		if (this.colors.length == 0)
			return false;

		for (i in 0...this.numParts) {
			map.addGameObject(new ExplosionParticle(this.colors[Std.int((this.colors.length * Math.random()))], 0.5, this.size,
				Std.int(200 + (Math.random() * 100)), (Math.random() - 0.5), (Math.random() - 0.5), 0),
				mapX, mapY);
		}

		return false;
	}
}

class ExplosionParticle extends Particle {
	public var lifetime = 0;
	public var timeLeft = 0;
	public var xDir: Float32 = 0.0;
	public var yDir: Float32 = 0.0;
	public var zDir: Float32 = 0.0;

	public function new(color: UInt, z: Float32, size: Float32, lifetime: Int32, xDir: Float32, yDir: Float32, zDir: Float32) {
		super(color, z, size);
		this.timeLeft = this.lifetime = lifetime;
		this.xDir = xDir;
		this.yDir = yDir;
		this.zDir = zDir;
	}

	override public function update(time: Int32, dt: Int16) {
		this.timeLeft -= dt;
		if (this.timeLeft <= 0)
			return false;

		mapX += this.xDir * dt * 0.008;
		mapY += this.yDir * dt * 0.008;
		mapZ += this.zDir * dt * 0.008;
		return true;
	}
}
