package ui.view;

import util.Utils;
import network.NetworkHandler;
import constants.ItemConstants;
import game.model.VialModel;
import map.Map;
import objects.ObjectLibrary;
import objects.Player;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.GraphicsPath;
import openfl.display.GraphicsSolidFill;
import openfl.display.IGraphicsData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.DropShadowFilter;
import openfl.geom.Point;
import openfl.utils.Timer;
import openfl.Vector;
import ui.model.VialData;
import ui.panels.itemgrids.itemtiles.InteractiveItemTile;
import ui.SimpleText;
import util.GraphicsUtil;

class VialSlotView extends Sprite {
	private static inline var DOUBLE_CLICK_PAUSE = 250;
	private static inline var DRAG_DIST = 3;

	public var buttonWidth = 84;
	public var position = 0;
	public var objectType = 0;

	private var lightGrayFill: GraphicsSolidFill;
	private var midGrayFill: GraphicsSolidFill;
	private var darkGrayFill: GraphicsSolidFill;
	private var outerPath: GraphicsPath;
	private var innerPath: GraphicsPath;
	private var useGraphicsData: Vector<IGraphicsData>;
	private var buyOuterGraphicsData: Vector<IGraphicsData>;
	private var buyInnerGraphicsData: Vector<IGraphicsData>;
	private var text: SimpleText;
	private var vialIconDraggableSprite: Sprite;
	private var vialIcon: Bitmap;
	private var bg: Sprite;
	private var grayscaleMatrix: ColorMatrixFilter;
	private var doubleClickTimer: Timer;
	private var dragStart: Point;
	private var pendingSecondClick = false;
	private var isDragging = false;
	private var showVials = false;

	public function new(cuts: Array<Int>, position: Int, fillWhole: Bool) {
		super();

		this.lightGrayFill = new GraphicsSolidFill(0x545454, 1);
		this.midGrayFill = new GraphicsSolidFill(4078909, 1);
		this.darkGrayFill = new GraphicsSolidFill(2368034, 1);
		this.outerPath = new GraphicsPath();
		this.innerPath = new GraphicsPath();
		this.useGraphicsData = new Vector<IGraphicsData>(0, false, [this.lightGrayFill, this.outerPath, GraphicsUtil.END_FILL]);
		this.buyOuterGraphicsData = new Vector<IGraphicsData>(0, false, [this.midGrayFill, this.outerPath, GraphicsUtil.END_FILL]);
		this.buyInnerGraphicsData = new Vector<IGraphicsData>(0, false, [this.darkGrayFill, this.innerPath, GraphicsUtil.END_FILL]);
		mouseChildren = false;
		this.position = position;
		this.grayscaleMatrix = new ColorMatrixFilter(ColorUtils.greyscaleFilterMatrix);
		var BUTTON_HEIGHT: Int = 24;
		if (fillWhole)
			buttonWidth = buttonWidth * 2 + 5;
		this.text = new SimpleText(13, 0xFFFFFF, false, buttonWidth, BUTTON_HEIGHT);
		this.text.filters = [new DropShadowFilter(0, 0, 0, 1, 4, 4, 2)];
		this.text.y = 2;
		this.bg = new Sprite();
		this.bg.cacheAsBitmap = true;
		GraphicsUtil.clearPath(this.outerPath);
		GraphicsUtil.drawCutEdgeRect(0, 0, buttonWidth, BUTTON_HEIGHT, 4, cuts, this.outerPath);
		var SMALL_SIZE: Int = 4;
		GraphicsUtil.drawCutEdgeRect(2, 2, buttonWidth - SMALL_SIZE, BUTTON_HEIGHT - SMALL_SIZE, 4, cuts, this.innerPath);
		this.bg.graphics.drawGraphicsData(this.buyOuterGraphicsData);
		this.bg.graphics.drawGraphicsData(this.buyInnerGraphicsData);
		addChild(this.bg);
		addChild(this.text);
		this.vialIconDraggableSprite = new Sprite();
		this.vialIconDraggableSprite.cacheAsBitmap = true;
		this.doubleClickTimer = new Timer(DOUBLE_CLICK_PAUSE, 1);
		this.doubleClickTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.onDoubleClickTimerComplete);
		addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
		addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
		addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
	}

	public function init(player: Player) {
		var vialModel = VialModel.vialData.get(this.position);
		var count = player.getVialCount(vialModel.objectId);
		this.setData(count, vialModel.objectId);
	}

	public function draw(player: Player) {
		var potModel: VialData = null;
		var count = 0;
		if (this.objectType == VialModel.HEALTH_VIAL_ID || this.objectType == VialModel.MAGIC_VIAL_ID) {
			potModel = VialModel.getVialData(this.objectType);
			count = player.getVialCount(potModel.objectId);
			this.setData(count);
		}
	}

	public function setData(vials: Int, objectType: Int = -1) {
		var iconX = 0;
		var iconBD: BitmapData = null;
		var vialIconBig: Bitmap = null;
		if (objectType != -1) {
			this.objectType = objectType;
			if (this.vialIcon != null)
				removeChild(this.vialIcon);

			iconBD = ObjectLibrary.getRedrawnTextureFromType(objectType, 40, false);
			this.vialIcon = new Bitmap(iconBD);
			this.vialIcon.cacheAsBitmap = true;
			this.vialIcon.y = -3;
			addChild(this.vialIcon);
			iconBD = ObjectLibrary.getRedrawnTextureFromType(objectType, 80, true);
			vialIconBig = new Bitmap(iconBD);
			vialIconBig.cacheAsBitmap = true;
			vialIconBig.x -= 22;
			vialIconBig.y -= 22;
			this.vialIconDraggableSprite.addChild(vialIconBig);
		}
		showVials = vials > 0;
		var CENTER_ICON_X: Int = Std.int(buttonWidth / 2 - 30);
		if (showVials) {
			this.text.text = vials + "/4";
			iconX = CENTER_ICON_X;
			this.bg.graphics.clear();
			this.bg.graphics.drawGraphicsData(this.useGraphicsData);
			this.text.x = buttonWidth / 2 - 4;
		} else {
			this.text.text = "0/4";
			iconX = CENTER_ICON_X;
			this.bg.graphics.clear();
			this.bg.graphics.drawGraphicsData(this.buyOuterGraphicsData);
			this.bg.graphics.drawGraphicsData(this.buyInnerGraphicsData);
			this.text.x = buttonWidth / 2 - 4;
		}
		if (this.vialIcon != null)
			this.vialIcon.x = iconX;
	}

	private function setPendingDoubleClick(isPending: Bool) {
		this.pendingSecondClick = isPending;
		if (this.pendingSecondClick) {
			this.doubleClickTimer.reset();
			this.doubleClickTimer.start();
		} else
			this.doubleClickTimer.stop();
	}

	private function beginDrag() {
		this.isDragging = true;
		this.vialIconDraggableSprite.startDrag(true);
		stage.addChild(this.vialIconDraggableSprite);
		this.vialIconDraggableSprite.addEventListener(MouseEvent.MOUSE_UP, this.endDrag);
	}

	private function onMouseOut(e: MouseEvent) {
		this.setPendingDoubleClick(false);
	}

	private function onMouseUp(e: MouseEvent) {
		if (this.isDragging)
			return;

		if (e.shiftKey) {
			this.setPendingDoubleClick(false);
			Global.useVial(VialModel.vialData.get(this.position).objectId);
		} else if (!this.pendingSecondClick)
			this.setPendingDoubleClick(true);
		else {
			this.setPendingDoubleClick(false);
			Global.useVial(VialModel.vialData.get(this.position).objectId);
		}
	}

	private function onMouseDown(e: MouseEvent) {
		if (showVials)
			this.beginDragCheck(e);
	}

	private function beginDragCheck(e: MouseEvent) {
		this.dragStart = new Point(e.stageX, e.stageY);
		addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveCheckDrag);
		addEventListener(MouseEvent.MOUSE_OUT, this.cancelDragCheck);
		addEventListener(MouseEvent.MOUSE_UP, this.cancelDragCheck);
	}

	private function cancelDragCheck(e: MouseEvent) {
		removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveCheckDrag);
		removeEventListener(MouseEvent.MOUSE_OUT, this.cancelDragCheck);
		removeEventListener(MouseEvent.MOUSE_UP, this.cancelDragCheck);
	}

	private function onMouseMoveCheckDrag(e: MouseEvent) {
		var dx = e.stageX - this.dragStart.x;
		var dy = e.stageY - this.dragStart.y;
		var distance = Math.sqrt(dx * dx + dy * dy);
		if (distance > DRAG_DIST) {
			this.cancelDragCheck(null);
			this.setPendingDoubleClick(false);
			this.beginDrag();
		}
	}

	private function onDoubleClickTimerComplete(e: TimerEvent) {
		this.setPendingDoubleClick(false);
	}

	private function endDrag(e: MouseEvent) {
		this.isDragging = false;
		this.vialIconDraggableSprite.stopDrag();
		this.vialIconDraggableSprite.x = this.dragStart.x;
		this.vialIconDraggableSprite.y = this.dragStart.y;
		stage.removeChild(this.vialIconDraggableSprite);
		this.vialIconDraggableSprite.removeEventListener(MouseEvent.MOUSE_UP, this.endDrag);

		var tile: InteractiveItemTile = null;
		var player = Global.gameSprite.map.player;
		var target = this.vialIconDraggableSprite.dropTarget;
		if (Std.isOfType(target, Map) || target == null)
			NetworkHandler.invDrop(player, VialModel.getVialSlot(this.objectType), this.objectType);
		else if (Std.isOfType(target, InteractiveItemTile)) {
			tile = cast(target, InteractiveItemTile);
			if (tile.getItemId() == ItemConstants.NO_ITEM && tile.ownerGrid.owner != player)
				NetworkHandler.invSwapVial(player, player, VialModel.getVialSlot(this.objectType), this.objectType, tile.ownerGrid.owner, tile.tileId,
					ItemConstants.NO_ITEM);
		}
	}

	private function onRemovedFromStage(e: Event) {
		this.setPendingDoubleClick(false);
		this.cancelDragCheck(null);
		if (this.isDragging)
			this.vialIconDraggableSprite.stopDrag();
	}
}
