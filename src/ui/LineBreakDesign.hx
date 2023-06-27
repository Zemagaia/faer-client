package ui;

import openfl.display.Shape;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;

class LineBreakDesign extends Sprite {
	public function new(width: Int, color: Int) {
		super();

		var rightDecor = new Bitmap(Assets.getBitmapData("assets/ui/tooltips/linebreakDecorRight.png"));
		var leftDecor = new Bitmap(Assets.getBitmapData("assets/ui/tooltips/linebreakDecorLeft.png"));

		// jank
		var line1 = new Shape();
		line1.graphics.lineStyle(1, 0x170704);
		line1.graphics.beginFill(0x66401E);
		line1.graphics.drawRect(leftDecor.width / 2, -1, width - rightDecor.width / 2 - leftDecor.width / 2, 3); 
		line1.graphics.endFill();
		addChild(line1);

		var line2 = new Shape();
		line2.graphics.beginFill(0xA4653A);
		line2.graphics.drawRect(line1.x, line1.y + 1, line1.width, 1);
		line2.graphics.endFill();
		addChild(line2);

		leftDecor.y = -leftDecor.height / 2;
		addChild(leftDecor);

		rightDecor.x = width - rightDecor.width;
		rightDecor.y = -rightDecor.height / 2;
		addChild(rightDecor);

		// extreme jank
		var pad = new Shape();
		pad.graphics.beginFill(0, 0);
		pad.graphics.drawRect(width, 0, 16, 1);
		pad.graphics.endFill();
		addChild(pad);
	}
}
