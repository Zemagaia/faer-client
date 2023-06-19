package screens.charrects;

import assets.IconFactory;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Shape;
import openfl.filters.DropShadowFilter;
import ui.SimpleText;

class BuyCharacterRect extends CharacterRect {
	private var classNameText: SimpleText;
	private var priceText: SimpleText;
	private var currency: Bitmap;

	private static function getOrdinalString(num: Int) {
		var str: String = Std.string(num);
		var ones: Int = num % 10;
		var tens: Int = Std.int(num / 10) % 10;
		if (tens == 1) {
			str = str + "th";
		} else if (ones == 1) {
			str = str + "st";
		} else if (ones == 2) {
			str = str + "nd";
		} else if (ones == 3) {
			str = str + "rd";
		} else {
			str = str + "th";
		}
		return str;
	}

	public function new() {
		super("Buy");
		this.classNameText = new SimpleText(18, 0xB3B3B3);
		this.classNameText.setBold(true);
		this.classNameText.text = "Buy Character Slot";
		this.classNameText.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8)];
		this.classNameText.updateMetrics();
		this.classNameText.x = (210 - this.classNameText.width) / 2 + 71;
		this.classNameText.y = (32 - this.classNameText.height) / 2 + 17;
		addChild(this.classNameText);
		this.priceText = new SimpleText(10, 0xB3B3B3);
		this.priceText.text = Std.string(Global.playerModel.getNextCharSlotPrice());
		this.priceText.updateMetrics();
		this.priceText.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8)];
		this.priceText.x = (32 - this.priceText.width) / 2 + 282;
		this.priceText.y = (14 - this.priceText.height) / 2 + 33;
		addChild(this.priceText);
		var bd = Global.playerModel.isNextCharSlotCurrencyGems() ? IconFactory.makeGold(20) : IconFactory.makeGems(20);
		this.currency = new Bitmap(bd);
		this.currency.x = width - 39;
		this.currency.y = this.classNameText.y - 2;
		addChild(this.currency);
	}
}
