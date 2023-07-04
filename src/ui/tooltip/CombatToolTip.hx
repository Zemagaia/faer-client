package ui.tooltip;

import openfl.text.TextFormatAlign;
import openfl.display.Bitmap;
import openfl.filters.DropShadowFilter;
import ui.LineBreakDesign;
import ui.SimpleText;

using util.Utils;

class CombatToolTip extends ToolTip {
	private static inline var MAX_WIDTH: Int = 330;

	private var icon: Bitmap;
	private var nameText: SimpleText;
	private var miscText: SimpleText;
	private var descText: SimpleText;
	private var line: LineBreakDesign;

	public function new() {
		super(0, 0, 0, 0);

		this.nameText = new SimpleText(16, 0xCCB4AF, false, Std.int(MAX_WIDTH - 20), 0);
		this.nameText.setBold(true);
		this.nameText.setItalic(true);
		this.nameText.setAlignment(TextFormatAlign.CENTER);
		this.nameText.wordWrap = true;
		this.nameText.text = 'In Combat';
		this.nameText.updateMetrics();
		this.nameText.filters = [new DropShadowFilter(0, 0, 0, 0.5, 12, 12)];
		this.nameText.x = 10;
		this.nameText.y = 10;
		addChild(this.nameText);

		this.line = new LineBreakDesign(MAX_WIDTH - 12, 0);
		this.line.x = 8;
		this.line.y = this.nameText.y + this.nameText.height + 14;
		addChild(this.line);

		this.descText = new SimpleText(14, 0xB09C99, false, Std.int(MAX_WIDTH), 0);
		this.descText.wordWrap = true;
		this.descText.htmlText = 'You are unable to return to the Hub, teleport or enter portals until you exit combat.';
		this.descText.useTextDimensions();
		this.descText.filters = [new DropShadowFilter(0, 0, 0, 0.5, 12, 12)];
		this.descText.x = 10;
		this.descText.y = this.line.y + 14;
		addChild(this.descText);
	}
}