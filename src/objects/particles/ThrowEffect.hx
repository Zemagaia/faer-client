package objects.particles;

import util.Utils.MathUtil;
import util.NativeTypes;
import objects.particles.Particle;
import objects.particles.SparkParticle;
import openfl.geom.Point;

class ThrowEffect extends ParticleEffect {
	public var startX: Float32;
	public var startY: Float32;
	public var endX: Float32;
	public var endY: Float32;
	public var color: UInt32 = 0;
	public var duration: Int32 = 0;

	public function new(startX: Float32, startY: Float32, endX: Float32, endY: Float32, color: UInt32, duration: Int32 = 1000) {
		super();
		this.startX = startX;
		this.startY = startY;
		this.endX = endX;
		this.endY = endY;
		this.color = color;
		this.duration = duration;
	}

	override public function update(time: Int32, dt: Int16) {
		mapX = this.startX;
		mapY = this.startY;
		var particle = this.duration == 0 ? new ThrowParticle(2, this.color, 1500, this.startX, this.startY,
			this.endX, this.endY) : new ThrowParticle(2, this.color, this.duration, this.startX, this.startY, this.endX, this.endY);
		map.addGameObject(particle, mapX, mapY);
		return false;
	}
}

class ThrowParticle extends Particle {
	public var lifetime = 0;
	public var timeLeft = 0;
	public var initialSize: Float32 = 0.0;
	public var dx: Float32 = 0;
	public var dy: Float32 = 0;
	public var pathX: Float32 = 0;
	public var pathY: Float32 = 0;
	public var color: UInt32 = 0;

	public function new(size: Float32, color: UInt32, lifetime: Int32, startX: Float32, startY: Float32, endX: Float32, endY: Float32) {
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
		
		mapZ = Math.sin(this.timeLeft / this.lifetime * MathUtil.PI) * 2;
		this.pathX += this.dx * dt;
		this.pathY += this.dy * dt;
		moveTo(this.pathX, this.pathY);
		map.addGameObject(new SparkParticle(Std.int(100 * (mapZ + 1)), this.color, 400, mapZ, MathUtil.plusMinus(1), MathUtil.plusMinus(1)), this.pathX, this.pathY);
		return true;
	}
}
