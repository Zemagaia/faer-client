package objects.particles;

import util.NativeTypes;
import objects.GameObject;

class HealEffect extends ParticleEffect {
	public var go: GameObject = null;
	public var color: UInt = 0;

	public function new(go: GameObject, color: UInt) {
		super();
		this.go = go;
		this.color = color;
	}

	override public function update(time: Int32, dt: Int16) {
		if (this.go.map == null)
			return false;
		
		mapX = this.go.mapX;
		mapY = this.go.mapY;
        for (i in 0...10) {
			var angle = 2 * Math.PI * (i / 10);
			var radius = 0.3 + 0.4 * Math.random();
			map.addGameObject(new HealParticle(this.color, Math.random() * 0.3, 0.3 + Std.int(Math.random() * 0.5) * 2,
                1000, 0.1 + Math.random() * 0.1, this.go, angle, radius),
                this.mapX + radius * Math.cos(angle), this.mapY + radius * Math.sin(angle));
        }

		return false;
	}
}

class HealParticle extends Particle {
	public var timeLeft = 0;
	public var go: GameObject = null;
	public var angle: Float32 = 0.0;
	public var dist: Float32 = 0.0;
	public var zDir: Float32 = 0.0;

	public function new(color: UInt, z: Float32, size: Float32, lifetime: Int32, zDir: Float32, go: GameObject, angle: Float32, dist: Float32) {
		super(color, z, size);
		this.zDir = zDir;
		this.timeLeft = lifetime;
		this.go = go;
		this.angle = angle;
		this.dist = dist;
	}

	override public function update(time: Int32, dt: Int16) {
		this.timeLeft -= dt;
		if (this.timeLeft <= 0)
			return false;
		
		mapX = this.go.mapX + this.dist * Math.cos(this.angle);
		mapY = this.go.mapY + this.dist * Math.sin(this.angle);
		mapZ += this.zDir * dt * 0.008;
		return true;
	}
}