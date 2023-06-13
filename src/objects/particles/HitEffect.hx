package objects.particles;

import util.NativeTypes;
import objects.particles.Particle;

class HitEffect extends ParticleEffect {
	public var colors: Array<UInt>;
	public var numParts = 0;
	public var angle: Float32 = 0.0;
	public var speed: Float32 = 0.0;

	public function new(colors: Array<UInt>, size: Float32, numParts: Int32, angle: Float32, speed: Float32) {
		super();
		this.colors = colors;
		this.size = size;
		this.numParts = numParts;
		this.angle = angle;
		this.speed = speed;
	}

	override public function update(time: Int32, dt: Int16) {
		if (this.colors.length == 0)
			return false;
		
		var cosAngle: Float32 = this.speed / 600 * -Math.cos(this.angle);
		var sinAngle: Float32 = this.speed / 600 * -Math.sin(this.angle);

		for (i in 0...this.numParts) {
			var rand = Math.random();
			map.addGameObject(new HitParticle(this.colors[Std.int(this.colors.length * rand)], 0.5, this.size, Std.int(200 + (rand * 100)),
				cosAngle + (Math.random() - 0.5) * 0.4, sinAngle + (Math.random() - 0.5) * 0.4, 0),
				mapX, mapY);
		}
			

		return false;
	}
}

class HitParticle extends Particle {
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
