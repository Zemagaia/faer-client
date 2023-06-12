package objects.particles;

import util.NativeTypes;

class SparkParticle extends Particle {
	public var lifetime = 0;
	public var timeLeft = 0;
	public var initialSize: Float32 = 0.0;
	public var dx: Float32 = 0.0;
	public var dy: Float32 = 0.0;

	public function new(size: Float32, color: Int32, lifetime: Int32, z: Float32, dx: Float32, dy: Float32) {
		super(color, z, size);
		this.initialSize = size;
		this.lifetime = this.timeLeft = lifetime;
		this.dx = dx;
		this.dy = dy;
	}

	override public function update(time: Int32, dt: Int16) {
		this.timeLeft -= dt;
		if (this.timeLeft <= 0)
			return false;
		
		mapX += this.dx * (dt / 1000);
		mapY += this.dy * (dt / 1000);
		this.size = this.timeLeft / this.lifetime * this.initialSize;
		return true;
	}
}
