package ui.view;

import openfl.Assets;
import openfl.display.Bitmap;
import constants.GeneralConstants;
import game.view.TabView;
import objects.Player;
import openfl.display.Graphics;
import openfl.display.Sprite;
import ui.model.TabStripModel;
import ui.panels.itemgrids.EquippedGrid;
import ui.panels.itemgrids.InventoryGrid;

class Inventory extends Sprite {
	public var invGrid: InventoryGrid;
	public var invVialView: VialInventoryView;

	private var decor: Bitmap;
	private var equippedGrid: EquippedGrid;

	public function new() {
		super();

		this.decor = new Bitmap(Assets.getBitmapData("assets/ui/inventoryInterface.png"));
		addChild(this.decor);
	}

	public function init(player: Player) {
		this.equippedGrid = new EquippedGrid(player, player.slotTypes, player, 0, true);
		this.equippedGrid.cacheAsBitmap = true;
		this.equippedGrid.x = 9;
		this.equippedGrid.y = 9;
		addChild(this.equippedGrid);

		this.invGrid = new InventoryGrid(player, player, 4, false, true);
		this.invGrid.cacheAsBitmap = true;
		this.invGrid.x = 9;
		this.invGrid.y = 69;
		addChild(this.invGrid);

		this.invVialView = new VialInventoryView(false);
		this.invVialView.x = 61;
		this.invVialView.y = 260;
		addChild(this.invVialView);

		this.invVialView?.leftSlot?.init(player);
		this.invVialView?.rightSlot?.init(player);
	}

	public inline function draw(player: Player) {
		this.equippedGrid?.draw();
		this.invGrid?.draw();
		this.invVialView?.leftSlot?.draw(player);
		this.invVialView?.rightSlot?.draw(player);
	}
}
