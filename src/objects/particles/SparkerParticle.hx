package objects.particles;

import util.NativeTypes;
import util.Utils.MathUtil;
import openfl.geom.Point;

class SparkerParticle extends Particle {
	public var lifetime = 0;
	public var timeLeft = 0;
	public var initialSize: Float32 = 0.0;
	public var dx: Float32 = 0.0;
	public var dy: Float32 = 0.0;
	public var pathX: Float32 = 0.0;
	public var pathY: Float32 = 0.0;
	public var color: UInt = 0;

	private var lastActivate = 0;

	public function new(size: Float32, color: UInt, lifetime: Int32, startX: Float32, startY: Float32, endX: Float32, endY: Float32) {
		super(color, 0, size);
		this.color = color;
		this.lifetime = this.timeLeft = lifetime;
		this.initialSize = size;
		this.dx = (endX - startX) / this.timeLeft;
		this.dy = (endY - startY) / this.timeLeft;
		this.pathX = this.mapX = startX;
		this.pathY = this.mapY = startY;
	}

	override public function update(time: Int32, dt: Int16) {
		this.timeLeft -= dt;
		if (this.timeLeft <= 0)
			return false;

		if (time < this.lastActivate + 16)
			return true;
		
		this.pathX += this.dx * dt;
		this.pathY += this.dy * dt;
		moveTo(this.pathX, this.pathY);
		map.addGameObject(new SparkParticle(mapZ + 0.5, this.color, 600, mapZ, MathUtil.plusMinus(1), MathUtil.plusMinus(1)), this.pathX,
			this.pathY);

		this.lastActivate = time;
		return true;
	}
}
