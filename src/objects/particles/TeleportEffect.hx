package objects.particles;

import util.NativeTypes;
import objects.particles.Particle;

class TeleportEffect extends ParticleEffect {
	override public function update(time: Int32, dt: Int16) {
        for (i in 0...20) {
            var rand = Math.random();
			var angle = 2 * Math.PI * rand;
			var radius = 0.7 * rand;
			map.addGameObject(new TeleportParticle(0x0000FF, 0.2, 0.1, Std.int(500 + 1000 * rand)), 
                mapX + radius * Math.cos(angle), mapY + radius * Math.sin(angle));
        }

		return false;
	}
}

class TeleportParticle extends Particle {
	public var timeLeft = 0;
	public var zDir: Float32 = 0.0;

	public function new(color: UInt, size: Float32, zDir: Float32, lifetime: Int32) {
		super(color, 0, size);
		this.zDir = zDir;
		this.timeLeft = lifetime;
	}

	override public function update(time: Int32, dt: Int16) {
		this.timeLeft -= dt;
		if (this.timeLeft <= 0)
			return false;
		
		mapZ += this.zDir * dt * 0.008;
		return true;
	}
}