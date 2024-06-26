package ui.view;

import ui.itemgrids.ContainerGrid;
import openfl.text.TextFormatAlign;
import util.TextureRedrawer;
import util.AssetLibrary;
import openfl.Assets;
import openfl.display.Bitmap;
import objects.Player;
import openfl.display.Graphics;
import openfl.display.Sprite;
import ui.itemgrids.EquippedGrid;
import ui.itemgrids.InventoryGrid;
import objects.ObjectLibrary;

class Inventory extends Sprite {
	public var invGrid: InventoryGrid;
	public var bpGrid: InventoryGrid;
	public var decor: Bitmap;

	private var containerDecor: Bitmap;
	private var containerName: SimpleText;
	private var containerBitmapLeft: Bitmap;
	private var containerBitmapRight: Bitmap;
	private var containerGrid: ContainerGrid;
	private var equippedGrid: EquippedGrid;

	public function new() {
		super();

		this.decor = new Bitmap(Assets.getBitmapData("assets/ui/playerInterfaceInventory.png"));
		this.decor.cacheAsBitmap = true;
		addChild(this.decor);

		this.containerDecor = new Bitmap(Assets.getBitmapData("assets/ui/containerInterface.png"));
		this.containerDecor.cacheAsBitmap = true;
		this.containerDecor.x = -this.containerDecor.width - 5;
		this.containerDecor.y = this.decor.height - this.containerDecor.height;
		this.containerDecor.visible = false;
		addChild(this.containerDecor);

		this.containerName = new SimpleText(14, 0xB3B3B3, 85);
		this.containerName.cacheAsBitmap = true;
		this.containerName.x = this.containerDecor.x + 51;
		this.containerName.y = this.containerDecor.y + 156;
		this.containerName.setBold(true);
		this.containerName.setItalic(true);
		this.containerName.setAlignment(TextFormatAlign.CENTER);
		this.containerName.visible = false;
		addChild(this.containerName);

		this.containerBitmapLeft = new Bitmap(null);
		this.containerBitmapLeft.cacheAsBitmap = true;
		this.containerBitmapLeft.x = this.containerDecor.x + 7;
		this.containerBitmapLeft.y = this.containerDecor.y + 154;
		this.containerBitmapLeft.visible = false;
		addChild(this.containerBitmapLeft);

		this.containerBitmapRight = new Bitmap(null);
		this.containerBitmapRight.cacheAsBitmap = true;
		this.containerBitmapRight.x = this.containerDecor.x + 157;
		this.containerBitmapRight.y = this.containerDecor.y + 154;
		this.containerBitmapRight.visible = false;
		addChild(this.containerBitmapRight);
	}

	public function init(player: Player) {
		this.equippedGrid = new EquippedGrid(player, player.slotTypes, player, 0, true);
		this.equippedGrid.cacheAsBitmap = true;
		this.equippedGrid.x = 53;
		this.equippedGrid.y = 9;
		addChild(this.equippedGrid);

		this.invGrid = new InventoryGrid(player, player, 4, false, true);
		this.invGrid.cacheAsBitmap = true;
		this.invGrid.x = 9;
		this.invGrid.y = 69;
		addChild(this.invGrid);
	}

	public inline function draw(player: Player) {
		if (Global.currentInteractiveTarget != -1) {
			var go = player.map.getGameObject(Global.currentInteractiveTarget);
			if (go.objClass == "Container") {
				if (this.containerGrid == null) {
					this.containerGrid = new ContainerGrid(go, player, true);
					this.containerGrid.cacheAsBitmap = true;
					this.containerGrid.x = this.containerDecor.x + 31;
					this.containerGrid.y = this.containerDecor.y + 9;
					addChild(this.containerGrid);

					this.containerName.visible = this.containerDecor.visible = this.containerBitmapLeft.visible = this.containerBitmapRight.visible = true;

					this.containerName.setText(go.props.displayId);
					this.containerName.updateMetrics();

					var textureData = ObjectLibrary.typeToTextureData.get(go.objectType);
					var tex = TextureRedrawer.redraw(textureData.texture, Std.int(16 / (textureData.texture.width / 16)), false, 0);
					this.containerBitmapLeft.bitmapData = this.containerBitmapRight.bitmapData = tex;
				}

				this.containerGrid.draw();
			} else {
				this.containerName.visible = this.containerDecor.visible = this.containerBitmapLeft.visible = this.containerBitmapRight.visible = false;
				if (this.containerGrid != null && contains(this.containerGrid)) {
					removeChild(this.containerGrid);
					this.containerGrid = null;
				}
			}
		} else {
			this.containerName.visible = this.containerDecor.visible = this.containerBitmapLeft.visible = this.containerBitmapRight.visible = false;
			if (this.containerGrid != null && contains(this.containerGrid)) {
				removeChild(this.containerGrid);
				this.containerGrid = null;
			}
		}

		this.equippedGrid?.draw();
		this.invGrid?.draw();
	}
}
