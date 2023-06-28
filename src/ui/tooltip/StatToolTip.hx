package ui.tooltip;

import util.NativeTypes.Int32;
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
using StringTools;

class StatToolTip extends ToolTip {
	private static inline var MAX_WIDTH: Int = 330;

	private var icon: Bitmap;
	private var nameText: SimpleText;
	private var descText: SimpleText;
	private var breakdownText: SimpleText;
	private var line: LineBreakDesign;
	private var breakdownBase: String;

	public function new(iconTex: BitmapData, name: String, desc: String) {
		super(0, 0, 0, 0);

		this.icon = new Bitmap(iconTex);
		this.icon.x = 12;
		this.icon.y = 12;
		addChild(this.icon);

		this.nameText = new SimpleText(16, 0xCCB4AF, false, Std.int(MAX_WIDTH - this.icon.width - 4 - 30), 0);
		this.nameText.setBold(true);
		this.nameText.setItalic(true);
		this.nameText.wordWrap = true;
		this.nameText.text = name;
		this.nameText.updateMetrics();
		this.nameText.filters = [new DropShadowFilter(0, 0, 0, 0.5, 12, 12)];
		this.nameText.x = this.icon.width + 16;
		this.nameText.y = 10;
		addChild(this.nameText);

		this.descText = new SimpleText(12, 0xCCB4AF, false, Std.int(MAX_WIDTH - this.icon.width - 4 - 30), 0);
		this.descText.filters = [new DropShadowFilter(0, 0, 0, 0.5, 12, 12)];
		this.descText.wordWrap = true;
		this.descText.x = this.icon.width + 16;
		this.descText.y = this.nameText.y + this.nameText.actualHeight;
		this.descText.setText(desc);
		this.descText.updateMetrics();
		addChild(this.descText);

		this.line = new LineBreakDesign(MAX_WIDTH - 12, 0);
		this.line.x = 8;
		this.line.y = this.descText.y + this.descText.height + 14;
		addChild(this.line);
	}

	public function setBreakdownText(breakdown: String) {
		this.breakdownBase = breakdown;

		this.breakdownText = new SimpleText(12, 0xB09C99, false, Std.int(MAX_WIDTH - this.icon.width - 4), 0);
		this.breakdownText.wordWrap = true;
		this.breakdownText.text = breakdown;
		this.breakdownText.useTextDimensions();
		this.breakdownText.filters = [new DropShadowFilter(0, 0, 0, 0.5, 12, 12)];
		this.breakdownText.x = 10;
		this.breakdownText.y = this.line.y + 14;

		if (!contains(this.breakdownText)) // this is needeed otherwise it will start to stack xd
			addChild(this.breakdownText);
	}

	public function updateBreakdown(value: Int32, boost: Int32, max: Int32) {
		var newText = this.breakdownBase.replace("$base", Std.string(value - boost));
		newText = newText.replace("$boost", Std.string(boost));
		newText = newText.replace("$max", Std.string(max));
		this.breakdownText.text = newText;
		this.breakdownText.useTextDimensions();
	}
}
