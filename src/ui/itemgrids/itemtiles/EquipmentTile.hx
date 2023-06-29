package ui.itemgrids.itemtiles;

import util.BitmapUtil;
import constants.ItemConstants;
import objects.ObjectLibrary;
import objects.Player;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.filters.ColorMatrixFilter;
import ui.itemgrids.ItemGrid;
import util.AssetLibrary;
import util.Utils;

class EquipmentTile extends InteractiveItemTile {
	private static var greyColorFilter = new ColorMatrixFilter(ColorUtils.singleColorFilterMatrix(0x363636));

	public var backgroundDetail: Bitmap;
	public var slotType = 0;

	public function new(id: Int, parentGrid: ItemGrid, isInteractive: Bool) {
		super(id, parentGrid, isInteractive);
	}

	override public function canHoldItem(itemType: Int) {
		return itemType <= 0 || ObjectLibrary.slotsMatching(this.slotType, ObjectLibrary.getSlotTypeFromType(itemType));
	}

	override public function setItem(itemId: Int) {
		var itemChanged = super.setItem(itemId);
		if (itemChanged)
			this.backgroundDetail.visible = itemSprite.itemId <= 0;

		return itemChanged;
	}

	override public function beginDragCallback() {
		this.backgroundDetail.visible = true;
	}

	override public function endDragCallback() {
		this.backgroundDetail.visible = itemSprite.itemId <= 0;
	}

	public function setType(slotType: Int) {
		var sheetId: Int = 16; // empty, todo
		switch (slotType) {
			case ItemConstants.BOOTS_TYPE:
				sheetId = 161;
			case ItemConstants.RELIC_TYPE:
				sheetId = 12;

			case ItemConstants.ANY_WEAPON_TYPE:
				sheetId = 48;
			case ItemConstants.SWORD_TYPE:
				sheetId = 1;
			case ItemConstants.BOW_TYPE:
				sheetId = 65;
			case ItemConstants.STAFF_TYPE:
				sheetId = 81;

			case ItemConstants.ANY_ARMOR_TYPE:
				sheetId = 49;
			case ItemConstants.VEST_TYPE:
				sheetId = 33;
			case ItemConstants.HIDE_TYPE:
				sheetId = 17;
			case ItemConstants.ROBE_TYPE:
				sheetId = 97;
		}

		var bd = BitmapUtil.trimAlpha(AssetLibrary.getImageFromSet("tieredItems", sheetId));
		if (bd != null) {
			this.backgroundDetail = new Bitmap(bd);
			this.backgroundDetail.scaleX = 4;
			this.backgroundDetail.scaleY = 4;
			this.backgroundDetail.x = (40 - this.backgroundDetail.width) / 2;
			this.backgroundDetail.y = (40 - this.backgroundDetail.height) / 2;
			this.backgroundDetail.filters = [greyColorFilter];
			addChildAt(this.backgroundDetail, 0);
		}

		this.slotType = slotType;
	}
}
