package objects.particles;

import util.PointUtil;
import util.Utils.MathUtil;
import util.NativeTypes;
import openfl.geom.Point;
import objects.particles.Particle;
import openfl.geom.Point;
import openfl.geom.Vector3D;

class StreamEffect extends ParticleEffect {
	public var startX: Float32 = 0.0;
	public var startY: Float32 = 0.0;
	public var endX: Float32 = 0.0;
	public var endY: Float32 = 0.0;
	public var color: UInt = 0;

	public function new(startX: Float32, startY: Float32, endX: Float32, endY: Float32, color: UInt) {
		super();
		this.startX = startX;
		this.startY = startY;
		this.endX = endX;
		this.endY = endY;
		this.color = color;
	}

	override public function update(time: Int32, dt: Int16) {
		mapX = this.startX;
		mapY = this.startY;
        for (i in 0...5) {
			var rand = Math.random();
			map.addGameObject(new StreamParticle(1.85, 0.3 + Std.int(rand * 0.5) * 2, 
                this.color, Std.int(1500 + rand * 3000), this.startX, this.startY, this.endX, this.endY), mapX, mapY);
        }

		return false;
	}
}

class StreamParticle extends Particle {
	public var timeLeft = 0;
	public var dx: Float32 = 0.0;
	public var dy: Float32 = 0.0;
	public var pathX: Float32 = 0.0;
	public var pathY: Float32 = 0.0;
	public var xDeflect: Float32 = 0.0;
	public var yDeflect: Float32 = 0.0;
	public var period: Float32 = 0.0;

	public function new(z: Float32, size: Float32, color: UInt32, lifetime: Int32, startX: Float32, startY: Float32, endX: Float32, endY: Float32) {
		super(color, z, size);
		this.timeLeft = lifetime;
		this.dx = (endX - startX) / this.timeLeft;
		this.dy = (endY - startY) / this.timeLeft;
		var dist = PointUtil.distanceXY(startX, startY, endX, endY) / this.timeLeft;
		this.xDeflect = this.dy / dist * 0.25;
		this.yDeflect = -this.dx / dist * 0.25;
		this.pathX = this.mapX = startX;
		this.pathY = this.mapY = startY;
		this.period = 0.25 + Math.random() * 0.5;
	}

	override public function update(time: Int32, dt: Int16) {
		this.timeLeft -= dt;
		if (this.timeLeft <= 0)
			return false;
		
		this.pathX += this.dx * dt;
		this.pathY += this.dy * dt;
		var angle = MathUtil.sin(this.timeLeft / 1000 / this.period);
		moveTo(this.pathX + this.xDeflect * angle, this.pathY + this.yDeflect * angle);
		return true;
	}
}