package objects.particles;

import util.NativeTypes;
import util.Utils.MathUtil;

class LineEffect extends ParticleEffect {
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
        for (i in 0...30) {
            var f = i / 30;
			map.addGameObject(new SparkParticle(0.2, this.color, 700, 0.5, MathUtil.plusMinus(1), MathUtil.plusMinus(1)), 
			    endX + f * (startX - endX), endY + f * (startY - endY));
        }

		return false;
	}
}