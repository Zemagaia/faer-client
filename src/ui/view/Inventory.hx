package ui.view;

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
	public var tabs: Array<TabView>;
	public var currentTabIndex = 0;
	public var invGrid: InventoryGrid;
	public var invVialView: VialInventoryView;
	public var bpGrid: InventoryGrid;
	public var bpVialView: VialInventoryView;

	private var contents: Array<Sprite>;
	private var bgSprite: Sprite;
	private var containerSprite: Sprite;
	private var equippedGrid: EquippedGrid;

	public function new() {
		super();

		this.tabs = new Array<TabView>();
		this.contents = new Array<Sprite>();
		this.containerSprite = new Sprite();
		this.containerSprite.cacheAsBitmap = true;
		addChild(this.containerSprite);

		this.bgSprite = new Sprite();
		this.bgSprite.cacheAsBitmap = true;
		var g = this.bgSprite.graphics;
		g.clear();
		g.lineStyle(4, 0x666666);
		g.beginFill(0x1B1B1B);
		g.drawRoundRect(0, 0, 200, 200, 20);
		this.containerSprite.addChild(this.bgSprite);
	}

	public function init(player: Player) {
		this.addEquippedGrid(player);

		var storageContent: Sprite = new Sprite();
		storageContent.name = TabStripModel.MAIN_INVENTORY;
		storageContent.x = 15;
		storageContent.y = 70;
		this.invGrid = new InventoryGrid(player, player, 4);
		storageContent.addChild(this.invGrid);
		this.invVialView = new VialInventoryView(player.maxMP < 0);
		this.invVialView.y = this.invGrid.y + this.invGrid.height + 4;
		storageContent.addChild(this.invVialView);
		this.addTab(storageContent);

		this.invVialView?.leftSlot?.init(player);
		this.invVialView?.rightSlot?.init(player);
	}

	public function addBackpackTab(player: Player) {
		var backpackContent = new Sprite();
		backpackContent.cacheAsBitmap = true;
		backpackContent.name = TabStripModel.BACKPACK;
		backpackContent.x = 15;
		backpackContent.y = 70;
		this.bpGrid = new InventoryGrid(Global.gameSprite.map.player, Global.gameSprite.map.player,
			GeneralConstants.NUM_EQUIPMENT_SLOTS + GeneralConstants.NUM_INVENTORY_SLOTS, true);
		this.bpGrid.cacheAsBitmap = true;
		backpackContent.addChild(this.bpGrid);
		this.bpVialView = new VialInventoryView(Global.gameSprite.map.player.maxMP < 0);
		this.bpVialView.cacheAsBitmap = true;
		this.bpVialView.y = this.bpGrid.y + this.bpGrid.height + 4;
		backpackContent.addChild(this.bpVialView);
		this.addTab(backpackContent);

		this.bpVialView?.leftSlot?.init(player);
		this.bpVialView?.rightSlot?.init(player);
	}

	public inline function draw(player: Player) {
		this.equippedGrid?.draw();

		if (this.currentTabIndex == 0) {
			this.invGrid?.draw();
			this.invVialView?.leftSlot?.draw(player);
			this.invVialView?.rightSlot?.draw(player);
		} else {
			this.bpGrid?.draw();
			this.bpVialView?.leftSlot?.draw(player);
			this.bpVialView?.rightSlot?.draw(player);
		}
	}

	public function addEquippedGrid(player: Player) {
		this.equippedGrid = new EquippedGrid(player, player.slotTypes, player, 0);
		this.equippedGrid.cacheAsBitmap = true;
		this.equippedGrid.x = this.equippedGrid.y = 15;
		this.containerSprite.addChild(this.equippedGrid);
	}

	public function addTab(content: Sprite) {
		var index = this.tabs.length;
		var tabView = new TabView(index);
		tabView.cacheAsBitmap = true;
		this.tabs.push(tabView);
		this.contents.push(content);
		this.containerSprite.addChild(content);
		if (index > 0)
			content.visible = false;
		else {
			this.showContent(0);
			Global.tabStripModel.currentSelection = content.name;
		}
	}

	public function setSelectedTab(index: Int) {
		this.selectTab(this.tabs[index]);
	}

	private function selectTab(view: TabView) {
		if (view != null) {
			var tabFromIndex = this.tabs[this.currentTabIndex];
			if (tabFromIndex.index != view.index) {
				this.showContent(view.index);
				Global.tabStripModel.currentSelection = this.contents[view.index].name;
			}
		}
	}

	private function showContent(index: Int) {
		var previousContent: Sprite = null;
		var currentContent: Sprite = null;
		if (index != this.currentTabIndex) {
			previousContent = this.contents[this.currentTabIndex];
			previousContent.visible = false;
			currentContent = this.contents[index];
			currentContent.visible = true;
			this.currentTabIndex = index;
		}
	}
}
