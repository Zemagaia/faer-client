package objects.particles;

import util.Utils;
import openfl.display.BitmapData;
import engine.TextureFactory;
import objects.BasicObject;
import util.TextureRedrawer;

class Particle extends BasicObject {
	public var size = 0;
	public var color = 0;

	private var texture: BitmapData;
	private var halfW = 0;
	private var halfH = 0;

	public function new(color: Int, z: Float, size: Float) {
		super();

		this.setZ(z);
		objectId = BasicObject.getNextFakeObjectId();
		this.color = color;
		this.size = Std.int(size * 0.05);
		updateTexture();
	}

	override public function draw(time: Int) {
		/*var textureData = TextureFactory.make(this.texture);
			RenderUtils.baseRender(textureData.width, textureData.height, this.screenX - this.halfW, this.screenY - this.halfH - textureData.yOffset,
				textureData.texture, 0); */
	}

	public function moveTo(x: Float, y: Float) {
		mapX = x;
		mapY = y;
		curSquare = map.lookupSquare(Std.int(x), Std.int(y));
		return true;
	}

	public function setColor(color: Int) {
		if (this.color == color)
			return;

		this.color = color;
		updateTexture();
	}

	public function setZ(z: Float) {
		mapZ = z;
	}

	public function setSize(size: Int) {
		if (this.size == size)
			return;

		this.size = size;
		updateTexture();
	}

	private function updateTexture() {
		this.texture = TextureRedrawer.redrawSolidSquare(this.color, this.size);
		this.halfW = this.halfH = Math.round(this.size / 2 + 1);
	}
}
