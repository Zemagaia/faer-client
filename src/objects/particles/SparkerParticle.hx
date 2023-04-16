package objects.particles;

import util.Utils;
import util.NativeTypes;

class SparkerParticle extends Particle {
	public var lifetime = 0;
	public var endTime = 0.0;
	public var initialSize = 0;
	public var lastUpdate = 0;
	public var dx = 0.0;
	public var dy = 0.0;
	public var pathX = 0.0;
	public var pathY = 0.0;

	public function new() {
		super(0, 0, 0);
	}

	public function init(size: Int, color: Int, lifetime: Int, startX: Float, startY: Float, endX: Float, endY: Float) {
		this.color = color;
		this.size = size;
		this.updateTexture();
		this.lifetime = lifetime;
		this.lastUpdate = Global.gameSprite != null ? Global.gameSprite.lastUpdate : Std.int(Sys.time() * 1000);
		this.endTime = this.lastUpdate + lifetime;
		this.initialSize = size;
		this.dx = (endX - startX) / lifetime;
		this.dy = (endY - startY) / lifetime;
		this.pathX = this.mapX = startX;
		this.pathY = this.mapY = startY;
	}

	override public function update(time: Int32, dt: Int16) {
		if (time >= this.endTime)
			return false;

		var trueDt = time - this.lastUpdate;
		if (trueDt < 16)
			return true;

		this.pathX += this.dx * trueDt;
		this.pathY += this.dy * trueDt;
		// moveTo(this.pathX += this.dx * trueDt, this.pathY += this.dy * trueDt);
		var prt = Global.sparkParticlePool.get();
		prt.init(5, color, 600, 0, MathUtil.plusMinus(1), MathUtil.plusMinus(1));
		// map.addObj(prt, this.pathX, this.pathY);
		this.lastUpdate = time;
		return true;
	}

	override public function removeFromMap() {
		super.removeFromMap();
		// Global.sparkerParticlePool.release(this);
	}
}
