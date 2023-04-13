package objects.particles;
import util.NativeTypes;

class SparkParticle extends Particle {
	public var lifetime = 0.0;
	public var timeLeft = 0.0;
	public var initialSize = 0.0;
	public var dx = 0.0;
	public var dy = 0.0;

	public function new() {
		super(0, 0, 0);
	}

	public function init(size: Int, color: Int, lifetime: Int, z: Float, dx: Float, dy: Float) {
		this.color = color;
		this.size = size;
		this.mapZ = z;
		this.initialSize = size;
		this.lifetime = this.timeLeft = lifetime;
		this.dx = dx;
		this.dy = dy;
	}

	override public function update(time: Int32, dt: Int16) {
		this.timeLeft -= dt;
		if (this.timeLeft <= 0)
			return false;

		var dtFrac = dt * 0.001;
		mapX += this.dx * dtFrac;
		mapY += this.dy * dtFrac;
		setSize(Std.int(this.timeLeft / this.lifetime * this.initialSize));
		return true;
	}

	override public function removeFromMap() {
		super.removeFromMap();
		//Global.sparkParticlePool.release(this);
	}
}
