package ui.panels.itemgrids.itemtiles;

import constants.ItemConstants;
import objects.ObjectLibrary;
import objects.Player;
import openfl.display.Bitmap;
import openfl.display.GraphicsPath;
import openfl.display.GraphicsSolidFill;
import openfl.display.IGraphicsData;
import openfl.display.Sprite;
import openfl.Vector;
import ui.panels.itemgrids.ItemGrid;
import util.AssetLibrary;
import util.BitmapUtil;
import util.GraphicsUtil;
import util.Utils;
import util.TextureRedrawer;

class ItemTile extends Sprite {
	public static inline var WIDTH: Int = 40;
	public static inline var HEIGHT: Int = 40;

	public var restrictionBitmap: Bitmap;
	public var itemSprite: ItemTileSprite;
	public var tileId = 0;
	public var ownerGrid: ItemGrid;

	private var fill: GraphicsSolidFill = new GraphicsSolidFill(0x545454, 1);
	private var path: GraphicsPath = new GraphicsPath();
	private var graphicsData: Vector<IGraphicsData> = new Vector<IGraphicsData>(0, false,
		[new GraphicsSolidFill(0x545454, 1), new GraphicsPath(), GraphicsUtil.END_FILL]);
	private var cuts: Array<Int>;

	public function new(id: Int, parentGrid: ItemGrid) {
		super();

		this.restrictionBitmap = new Bitmap(TextureRedrawer.redraw(BitmapUtil.trimAlpha(AssetLibrary.getImageFromSet("misc", 30)), 60, false, 0));
		this.restrictionBitmap.x = WIDTH - this.restrictionBitmap.width / 1.4 - 5;
		this.restrictionBitmap.y = HEIGHT - this.restrictionBitmap.height - 2;
		this.restrictionBitmap.visible = false;

		this.tileId = id;
		this.ownerGrid = parentGrid;
		this.setItemSprite(new ItemTileSprite());
	}

	public function drawBackground(cuts: Array<Int>) {
		this.cuts = cuts;
		var itemId: Int = this.itemSprite != null ? this.itemSprite.itemId : -1;
		var fill: GraphicsSolidFill = new GraphicsSolidFill(0x545454, 1);
		if (itemId != -1) {
			var xml = ObjectLibrary.xmlLibrary.get(itemId);
			if (xml?.elementsNamed("Tier").hasNext()) {
				this.fill.color = fill.color = ColorUtils.getRarityColor(xml.elementsNamed("Tier").next().firstChild().nodeValue, 0x545454);
				this.graphicsData[0] = this.fill;
			}
		} else {
			this.fill.color = fill.color = 0x545454;
			this.graphicsData[0] = this.fill;
		}
		GraphicsUtil.clearPath(this.path);
		GraphicsUtil.drawCutEdgeRect(0, 0, WIDTH, HEIGHT, 4, this.cuts, this.path);
		this.graphicsData[1] = this.path;
		graphics.clear();
		graphics.drawGraphicsData(this.graphicsData);
	}

	public function setItem(itemId: Int) {
		if (itemId == this.itemSprite.itemId)
			return false;

		this.itemSprite.setType(itemId);
		if (this.cuts != null)
			this.drawBackground(this.cuts);
		this.updateUseability(this.ownerGrid.curPlayer);
		return true;
	}

	public function setItemSprite(itemTileSprite: ItemTileSprite) {
		this.itemSprite = itemTileSprite;
		this.itemSprite.x = WIDTH / 2;
		this.itemSprite.y = HEIGHT / 2;

		if (this.cuts != null)
			this.drawBackground(this.cuts);

		addChild(this.itemSprite);
		addChild(this.restrictionBitmap);
	}

	public function updateUseability(player: Player) {
		if (this.itemSprite.itemId != ItemConstants.NO_ITEM)
			this.restrictionBitmap.visible = !ObjectLibrary.isUsableByPlayer(this.itemSprite.itemId, player);
		else
			this.restrictionBitmap.visible = false;
	}

	public function canHoldItem(itemType: Int) {
		return true;
	}

	public function resetItemPosition() {
		this.setItemSprite(this.itemSprite);
	}

	public function getItemId() {
		return this.itemSprite.itemId;
	}
}
