package ui;

import openfl.text.TextFormatAlign;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.CapsStyle;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.filters.DropShadowFilter;

class TextInputField extends Sprite {
	public static inline var HEIGHT: Int = 88;

	public var decor: Bitmap;
	public var nameText: SimpleText;
	public var inputText: SimpleText;
	public var errorText: SimpleText;

	public function new(name: String, isPassword: Bool, error: String) {
		super();

		this.nameText = new SimpleText(22, 0xB3B3B3, false, 330, 0);
		this.nameText.setBold(true);
		this.nameText.setAlignment(TextFormatAlign.CENTER);
		this.nameText.text = name;
		this.nameText.updateMetrics();
		this.nameText.filters = [new DropShadowFilter(0, 0, 0)];
		addChild(this.nameText);
		this.decor = new Bitmap(Assets.getBitmapData("assets/ui/elements/textBoxBg.png"));
		this.decor.y = 30;
		addChild(this.decor);
		this.inputText = new SimpleText(20, 0xB3B3B3, true, 310, 30);
		this.inputText.y = 42;
		this.inputText.x = 10;
		this.inputText.border = false;
		this.inputText.displayAsPassword = isPassword;
		this.inputText.updateMetrics();
		this.inputText.addEventListener(Event.CHANGE, this.onInputChange);
		addChild(this.inputText);
		this.errorText = new SimpleText(12, 0xFC8642, false, 0, 0);
		this.errorText.y = this.inputText.y + 32;
		this.errorText.text = error;
		this.errorText.updateMetrics();
		this.errorText.filters = [new DropShadowFilter(0, 0, 0)];
		addChild(this.errorText);
	}

	public function text() {
		return this.inputText.text;
	}

	public function setError(error: String) {
		this.errorText.text = error;
		this.errorText.updateMetrics();
	}

	public function onInputChange(event: Event) {
		this.setError("");
	}
}
