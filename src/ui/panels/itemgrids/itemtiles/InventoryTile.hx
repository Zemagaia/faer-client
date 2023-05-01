package ui.panels.itemgrids.itemtiles;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import ui.panels.itemgrids.ItemGrid;
import ui.SimpleText;

class InventoryTile extends InteractiveItemTile {
	public var hotKey = 0;

	private var hotKeyBMP: Bitmap;

	public function new(id: Int, parentGrid: ItemGrid, isInteractive: Bool) {
		super(id, parentGrid, isInteractive);
	}

	override public function setItemSprite(newItemSprite: ItemTileSprite) {
		super.setItemSprite(newItemSprite);
		newItemSprite.setDim(false);
	}

	override public function setItem(itemId: Int) {
		var changed: Bool = super.setItem(itemId);
		if (changed)
			this.hotKeyBMP.visible = itemSprite.itemId <= 0;
		return changed;
	}

	override public function beginDragCallback() {
		this.hotKeyBMP.visible = true;
	}

	override public function endDragCallback() {
		this.hotKeyBMP.visible = itemSprite.itemId <= 0;
	}

	public function addTileNumber(tileNumber: Int) {
		this.hotKey = tileNumber;
		this.buildHotKeyBMP();
	}

	public function buildHotKeyBMP() {
		var tempText: SimpleText = new SimpleText(26, 0x363636, false, 0, 0);
		tempText.text = Std.string(this.hotKey);
		tempText.setBold(true);
		tempText.updateMetrics();
		var bmpData: BitmapData = new BitmapData(26, 30, true, 0);
		bmpData.draw(tempText);
		this.hotKeyBMP = new Bitmap(bmpData);
		this.hotKeyBMP.x = ItemTile.WIDTH / 2 - tempText.width / 2;
		this.hotKeyBMP.y = ItemTile.HEIGHT / 2 - 18;
		addChildAt(this.hotKeyBMP, 0);
	}
}
