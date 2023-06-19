package screens.charrects;

import openfl.Assets;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

class CharacterRect extends Sprite {
	public var selectContainer: Sprite;

	private var baseTex: BitmapData;
	private var hoverTex: BitmapData;
	private var pressedTex: BitmapData;
	
	private var decor: Bitmap;

	private var hovering = false;
	private var pressed = false;

	public function new(boxType: String = "") {
		super();

		this.baseTex = Assets.getBitmapData('assets/ui/screens/charSelect/characterBox$boxType.png');
		this.hoverTex = Assets.getBitmapData('assets/ui/screens/charSelect/characterBox${boxType}Hover.png');
		this.pressedTex = Assets.getBitmapData('assets/ui/screens/charSelect/characterBox${boxType}Press.png');

		this.decor = new Bitmap(this.baseTex);
		addChild(this.decor);

		// for mouse events
		this.selectContainer = new Sprite();
		this.selectContainer.graphics.beginFill(0, 0);
		this.selectContainer.graphics.drawRect(0, 0, width, height);
		addChild(this.selectContainer);

		addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
		addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
		addEventListener(MouseEvent.MOUSE_DOWN, this.onClick);
		addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, this.onClick);
		addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, this.onClick);
		addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		addEventListener(MouseEvent.MIDDLE_MOUSE_UP, this.onMouseUp);
		addEventListener(MouseEvent.RIGHT_MOUSE_UP, this.onMouseUp);
	}

	private function onRollOver(_: MouseEvent) {
		this.hovering = true;
		this.decor.bitmapData = this.hoverTex;
	}

	private function onMouseUp(_: MouseEvent) {
		this.pressed = false;

		if (this.hovering)
			this.onRollOver(null);
		else
			this.decor.bitmapData = this.baseTex;
	}

	private function onRollOut(_: MouseEvent) {
		this.hovering = false;

		if (this.pressed)
			this.onClick(null);
		else
			this.decor.bitmapData = this.baseTex;
	}

	private function onClick(_: MouseEvent) {
		this.pressed = true;
		this.decor.bitmapData = this.pressedTex;
	}
}
