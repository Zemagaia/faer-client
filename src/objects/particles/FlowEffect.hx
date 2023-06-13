package objects.particles;

import util.PointUtil;
import util.NativeTypes;
import objects.GameObject;
import objects.particles.Particle;

class FlowEffect extends ParticleEffect {
	public var startX: Float32 = 0.0;
	public var startY: Float32 = 0.0;
	public var go: GameObject = null;
	public var color: UInt = 0;

	public function new(startX: Float32, startY: Float32, go: GameObject, color: UInt) {
		super();
		this.startX = startX;
		this.startY = startY;
		this.go = go;
		this.color = color;
	}

	override public function update(time: Int, dt: Int) {
		mapX = this.startX;
		mapY = this.startY;
        for (i in 0...5)
			map.addGameObject(new FlowParticle(0.5, 0.3 + Std.int(Math.random() * 0.5) * 2, this.color, this.startX, this.startY, this.go), mapX, mapY);
        
		return false;
	}
}

class FlowParticle extends Particle {
	public var startX: Float32 = 0.0;
	public var startY: Float32 = 0.0;
	public var go: GameObject = null;
	public var maxDist: Float32 = 0.0;
	public var flowSpeed: Float32 = 0.0;

	public function new(z: Float32, size: Float32, color: UInt, startX: Float32, startY: Float32, go: GameObject) {
		super(color, z, size);
		this.startX = startX;
		this.startY = startY;
		this.go = go;
		this.maxDist = PointUtil.distanceXY(mapX, mapY, this.go.mapX, this.go.mapY);
		this.flowSpeed = Math.random() * 5;
	}

	override public function update(time: Int32, dt: Int16) {
		var dist = PointUtil.distanceXY(mapX, mapY, this.go.mapX, this.go.mapY);
		this.maxDist -= this.flowSpeed * dt / 1000;
		var flowDist = dist - this.flowSpeed * dt / 1000;
		if (flowDist > this.maxDist)
			flowDist = this.maxDist;
		
		var dX = this.go.mapX - mapX;
		var dY = this.go.mapY - mapY;
		dX *= flowDist / dist;
		dY *= flowDist / dist;
		moveTo(this.go.mapX - dX, this.go.mapY - dY);
		return true;
	}
}