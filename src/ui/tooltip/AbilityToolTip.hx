package ui.tooltip;

import openfl.display.BitmapData;
import network.NetworkHandler.StatType;
import constants.ActivationType;
import objects.ObjectLibrary;
import objects.Player;
import openfl.display.Bitmap;
import openfl.filters.DropShadowFilter;
import ui.LineBreakDesign;
import ui.SimpleText;
import util.BitmapUtil;
import util.Utils;
import constants.ItemConstants;

using util.Utils;

class AbilityToolTip extends ToolTip {
	private static inline var MAX_WIDTH: Int = 330;

	private var icon: Bitmap;
	private var nameText: SimpleText;
	private var miscText: SimpleText;
	private var descText: SimpleText;
	private var line: LineBreakDesign;

	public function new(iconTex: BitmapData, manaCost: Int, healthCost: Int, cooldown: Float, desc: String, name: String, abilityKey: String) {
		super(0, 0, 0, 0);

		this.icon = new Bitmap(iconTex);
		this.icon.x = 12;
		this.icon.y = 12;
		addChild(this.icon);

		this.nameText = new SimpleText(16, 0xCCB4AF, false, Std.int(MAX_WIDTH - this.icon.width - 4 - 30), 0);
		this.nameText.setBold(true);
		this.nameText.setItalic(true);
		this.nameText.wordWrap = true;
		this.nameText.text = '[$abilityKey] $name';
		this.nameText.updateMetrics();
		this.nameText.filters = [new DropShadowFilter(0, 0, 0, 0.5, 12, 12)];
		this.nameText.x = this.icon.width + 16;
		this.nameText.y = 10;
		addChild(this.nameText);

		this.miscText = new SimpleText(13, 0xCCB4AF, false, Std.int(MAX_WIDTH - this.icon.width - 4 - 30), 0);
		this.miscText.filters = [new DropShadowFilter(0, 0, 0, 0.5, 12, 12)];
		this.miscText.x = this.icon.width + 16;
		this.miscText.y = this.nameText.y + this.nameText.actualHeight;
		var costText = manaCost != 0 ? '$manaCost Mana' : '';
		costText += (manaCost != 0 && healthCost != 0 ? ', ' : '') + (healthCost != 0 ? '$healthCost Health' : '');
		if (costText == '')
			costText = 'No Cost';
		this.miscText.setText(costText + ', ${cooldown}s');
		this.miscText.updateMetrics();
		addChild(this.miscText);

		this.line = new LineBreakDesign(MAX_WIDTH - 12, 0);
		this.line.x = 8;
		this.line.y = this.miscText.y + this.miscText.height + 14;
		addChild(this.line);

		this.descText = new SimpleText(14, 0xB09C99, false, Std.int(MAX_WIDTH - this.icon.width - 4), 0);
		this.descText.wordWrap = true;
		this.descText.htmlText = desc;
		this.descText.useTextDimensions();
		this.descText.filters = [new DropShadowFilter(0, 0, 0, 0.5, 12, 12)];
		this.descText.x = 10;
		this.descText.y = this.line.y + 14;
		addChild(this.descText);
	}
}