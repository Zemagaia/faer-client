package ui;

import openfl.geom.ColorTransform;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

class TextButton extends Sprite {
	public var text: SimpleText;
	public var decor: Bitmap;

	private static var baseCT = new ColorTransform();
	private static var hoverCT = new ColorTransform(1.3);
	private static var pressedCT = new ColorTransform(1, 1.3);

	public function new(size: Int, text: String) {
		super();

		this.decor = new Bitmap(Assets.getBitmapData("assets/ui/elements/buttonBg.png"));
		addChild(this.decor);
		this.text = new SimpleText(size, 0xB3B3B3, false, 0, 0);
		this.text.setBold(true);
		this.text.text = text;
		this.text.updateMetrics();
		this.text.x = (width - this.text.width) / 2;
		this.text.y = (height - this.text.height) / 2;
		addChild(this.text);
		addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
		addEventListener(MouseEvent.MOUSE_DOWN, this.onClick);
		addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, this.onClick);
		addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, this.onClick);
		addEventListener(MouseEvent.ROLL_OUT, this.onBase);
		addEventListener(MouseEvent.MOUSE_UP, this.onBase);
		addEventListener(MouseEvent.MIDDLE_MOUSE_UP, this.onBase);
		addEventListener(MouseEvent.RIGHT_MOUSE_UP, this.onBase);
	}

	private function onMouseOver(_: MouseEvent) {
		this.decor.transform.colorTransform = hoverCT;
	}

	private function onBase(_: MouseEvent) {
		this.decor.transform.colorTransform = baseCT;
	}

	private function onClick(_: MouseEvent) {
		this.decor.transform.colorTransform = hoverCT;
	}
}
