package ui;

import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

class TextButton extends Sprite {
	public var text: SimpleText;
	public var decor: Bitmap;
	public var decorContainer: Sprite;

	private var baseTex: BitmapData;
	private var hoverTex: BitmapData;
	private var pressedTex: BitmapData;

	private var hovering = false;
	private var pressed = false;

	public function new(size: Int, text: String, forcedW: Float = -1.0, forcedH: Float = -1.0) {
		super();

		this.baseTex = Assets.getBitmapData("assets/ui/elements/buttonBgBase.png");
		this.hoverTex = Assets.getBitmapData("assets/ui/elements/buttonBgHover.png");
		this.pressedTex = Assets.getBitmapData("assets/ui/elements/buttonBgPress.png");

		this.text = new SimpleText(size, 0xB3B3B3, false, 0, 0);
		this.text.text = text;
		this.text.updateMetrics();

		this.decorContainer = new Sprite();
		this.decorContainer.scale9Grid = new Rectangle(7, 7, 34, 34);
		this.decorContainer.graphics.beginBitmapFill(this.baseTex);
		this.decorContainer.graphics.drawRect(0, 0, this.baseTex.width, this.baseTex.height);
		this.decorContainer.graphics.endFill();
		this.decorContainer.width = forcedW == -1.0 ? this.text.width + 30 : forcedW;
		this.decorContainer.height = forcedH == -1.0 ? this.text.height + 20 : forcedH;
		addChild(this.decorContainer);

		this.text.setBold(true);
		this.text.x = (width - this.text.width) / 2;
		this.text.y = (height - this.text.height) / 2;
		addChild(this.text); // intentionally detached, for ordering

		addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
		addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
		addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
		addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, this.onMouseDown);
		addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, this.onMouseDown);
		addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		addEventListener(MouseEvent.MIDDLE_MOUSE_UP, this.onMouseUp);
		addEventListener(MouseEvent.RIGHT_MOUSE_UP, this.onMouseUp);
	}

	private function onRollOver(_: MouseEvent) {
		this.hovering = true;

		this.text.setColor(0xFFF9BF);

		this.decorContainer.graphics.clear();
		this.decorContainer.graphics.beginBitmapFill(this.hoverTex);
		this.decorContainer.graphics.drawRect(0, 0, this.hoverTex.width, this.hoverTex.height);
		this.decorContainer.graphics.endFill();
	}

	private function onMouseUp(_: MouseEvent) {
		this.pressed = false;

		this.text.setColor(0xB3B3B3);

		if (this.hovering)
			this.onRollOver(null);
		else {
			this.decorContainer.graphics.clear();
			this.decorContainer.graphics.beginBitmapFill(this.baseTex);
			this.decorContainer.graphics.drawRect(0, 0, this.baseTex.width, this.baseTex.height);
			this.decorContainer.graphics.endFill();
		}
	}

	private function onRollOut(_: MouseEvent) {
		this.hovering = false;

		this.text.setColor(0xB3B3B3);

		if (this.pressed)
			this.onMouseDown(null);
		else {
			this.decorContainer.graphics.clear();
			this.decorContainer.graphics.beginBitmapFill(this.baseTex);
			this.decorContainer.graphics.drawRect(0, 0, this.baseTex.width, this.baseTex.height);
			this.decorContainer.graphics.endFill();
		}
	}

	private function onMouseDown(_: MouseEvent) {
		this.pressed = true;

		this.text.setColor(0xFFF7AB);

		this.decorContainer.graphics.clear();
		this.decorContainer.graphics.beginBitmapFill(this.pressedTex);
		this.decorContainer.graphics.drawRect(0, 0, this.pressedTex.width, this.pressedTex.height);
		this.decorContainer.graphics.endFill();
	}
}
