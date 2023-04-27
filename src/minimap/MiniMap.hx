package minimap;

import map.Camera;
import network.NetworkHandler;
import haxe.ds.IntMap;
import map.GroundLibrary;
import map.Map;
import objects.GameObject;
import objects.Player;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import ui.IconButton;
import ui.menu.PlayerGroupMenu;
import ui.options.Options;
import ui.tooltip.PlayerGroupToolTip;
import util.AssetLibrary;
import util.Utils;
import util.PointUtil;
import util.Settings;

class MiniMap extends Sprite {
	public static inline var MOUSE_DIST_SQ = 5 * 5;
	public static inline var HUB_BUTTON = "HUB_BUTTON";
	public static inline var OPTIONS_BUTTON = "OPTIONS_BUTTON";
	private static var objectTypeColorDict: IntMap<Int> = new IntMap<Int>();

	public var map: Map;
	public var mapWidth = 0;
	public var mapHeight = 0;
	public var zoomIndex = 0;
	public var windowRect: Rectangle;
	public var maxWH: Point;
	public var miniMapData: BitmapData;
	public var zoomLevels: Array<Float>;
	public var blueArrow: BitmapData;
	public var groundLayer: Shape;
	public var characterLayer: Shape;

	private var button: IconButton;
	private var zoomButtons: MiniMapZoomButtons;
	private var isMouseOver = false;
	private var tooltip: PlayerGroupToolTip = null;
	private var menu: PlayerGroupMenu = null;
	private var mapMatrix: Matrix;
	private var arrowMatrix: Matrix;
	private var players: Array<Player>;
	private var tempPoint: Point;

	public static function gameObjectToColor(go: GameObject) {
		var objectType = go.objectType;
		if (!(objectTypeColorDict.exists(objectType)))
			objectTypeColorDict.set(objectType, go.getColor());

		return objectTypeColorDict.get(objectType);
	}

	private static function areSamePlayers(players0: Array<Player>, players1: Array<Player>) {
		var count = players0.length;
		if (count != players1.length)
			return false;

		for (i in 0...count)
			if (players0[i] != players1[i])
				return false;

		return true;
	}

	public function new(width: Int, height: Int) {
		super();

		this.zoomLevels = new Array<Float>();
		this.mapMatrix = new Matrix();
		this.arrowMatrix = new Matrix();
		this.players = new Array<Player>();
		this.tempPoint = new Point();
		this.mapWidth = width;
		this.mapHeight = height;
		this.makeVisualLayers();
		this.addMouseListeners();
		this.update();
	}

	public function update() {
		this.map = Global.gameSprite.map;
		this.zoomLevels.resize(0);
		this.makeViewModel();
		this.createButton(this.map.mapName == "Hub" ? "OPTIONS_BUTTON" : "HUB_BUTTON");
	}

	private static function onGotoHub() {
		NetworkHandler.escape();
	}

	private static function onGotoOptions() {
		Global.gameSprite.inputHandler.clearInput();
		var options = new Options(Global.gameSprite);
		options.x = (Main.stageWidth - 800) / 2;
		options.y = (Main.stageHeight - 600) / 2;
		Global.gameSprite.addChild(options);
	}

	public function onMiniMapZoom(direction: String) {
		if (direction == "in")
			this.zoomIn();
		else if (direction == "out")
			this.zoomOut();
	}

	private function onUpdateHUD(_: Player) {
		this.draw();
	}

	public function dispose() {
		if (this.miniMapData != null) {
			this.miniMapData.dispose();
			this.miniMapData = null;
		}

		if (this.blueArrow != null) {
			this.blueArrow.dispose();
			this.blueArrow = null;
		}

		if (this.tooltip != null) {
			if (this.tooltip.parent != null)
				this.tooltip.parent.removeChild(this.tooltip);
			this.tooltip = null;
		}

		if (this.menu != null) {
			if (this.menu.parent != null)
				this.menu.parent.removeChild(this.menu);
			this.menu = null;
		}

		if (this.zoomButtons != null)
			this.zoomButtons.zoom.off(this.onZoomChanged);
	}

	public function setGroundTile(x: Int, y: Int, tileType: Int) {
		var color = GroundLibrary.getColor(tileType);
		this.miniMapData.setPixel(x, y, color);
	}

	public function setGameObjectTile(x: Int, y: Int, go: GameObject) {
		var color = gameObjectToColor(go);
		if (color != 0)
			this.miniMapData.setPixel(x, y, color);
	}

	public inline function draw() {
		var g: Graphics = null;
		var fillColor = 0;
		var mmx = 0.0;
		var mmy = 0.0;
		var dx = 0.0;
		var dy = 0.0;
		var distSq = 0.0;
		this.groundLayer.graphics.clear();
		this.characterLayer.graphics.clear();
		this.players.resize(0);
		var focus = Global.gameSprite.map.player;
		if (focus == null)
			return;

		var zoom = this.zoomLevels[this.zoomIndex];
		this.mapMatrix.identity();
		this.mapMatrix.translate(-focus.mapX, -focus.mapY);
		this.mapMatrix.scale(zoom, zoom);
		var upLeft = this.mapMatrix.transformPoint(new Point(0, 0));
		var bottomRight = this.mapMatrix.transformPoint(this.maxWH);
		var tx = 0.0;
		if (upLeft.x > this.windowRect.left)
			tx = this.windowRect.left - upLeft.x;
		else if (bottomRight.x < this.windowRect.right)
			tx = this.windowRect.right - bottomRight.x;

		var ty = 0.0;
		if (upLeft.y > this.windowRect.top)
			ty = this.windowRect.top - upLeft.y;
		else if (bottomRight.y < this.windowRect.bottom)
			ty = this.windowRect.bottom - bottomRight.y;

		this.mapMatrix.translate(tx, ty);
		g = this.groundLayer.graphics;
		g.beginBitmapFill(this.miniMapData, this.mapMatrix, false);
		g.drawCircle(0, 0, 75);
		g.endFill();
		g = this.characterLayer.graphics;
		var mX = mouseX;
		var mY = mouseY;
		this.players.splice(this.players.length, 0);
		for (go in this.map.gameObjects) {
			if (!go.props.noMiniMap) {
				if (go.objClass == "Portal")
					fillColor = 0x0000FF;
				else if (go.props.isEnemy)
					fillColor = 0xFF0000;
				else
					continue;

				mmx = this.mapMatrix.a * go.mapX + this.mapMatrix.c * go.mapY + this.mapMatrix.tx;
				mmy = this.mapMatrix.b * go.mapX + this.mapMatrix.d * go.mapY + this.mapMatrix.ty;
				if (PointUtil.distanceSquaredXY(mmx, mmy, 0, 0) > 75 * 75)
					continue;

				g.beginFill(fillColor);
				g.drawRect(mmx - 2, mmy - 2, 4, 4);
				g.endFill();
			}
		}

		for (player in this.map.players) {
			if (player != focus) {
				fillColor = player.isFellowGuild ? 0x00FF00 : 0xFFFF00;

				mmx = this.mapMatrix.a * player.mapX + this.mapMatrix.c * player.mapY + this.mapMatrix.tx;
				mmy = this.mapMatrix.b * player.mapX + this.mapMatrix.d * player.mapY + this.mapMatrix.ty;
				if (PointUtil.distanceSquaredXY(mmx, mmy, 0, 0) > 75 * 75) {
					var angle: Float = Math.atan2(mmy, mmx);
					var cosAngle: Float = MathUtil.cos(angle),
						sinAngle: Float = MathUtil.sin(angle);
					var scaledWh: Float = Math.ceil(75 * 0.7); // Why man

					mmx = cosAngle * scaledWh - sinAngle * scaledWh;
					mmy = sinAngle * scaledWh + cosAngle * scaledWh;
				}

				if (this.isMouseOver && (this.menu == null || this.menu.parent == null)) {
					dx = mX - mmx;
					dy = mY - mmy;
					distSq = dx * dx + dy * dy;
					if (distSq < MOUSE_DIST_SQ)
						this.players.push(player);
				}

				g.beginFill(fillColor);
				g.drawRect(mmx - 2, mmy - 2, 4, 4);
				g.endFill();
			}
		}

		if (this.players.length != 0) {
			if (this.tooltip == null) {
				this.tooltip = new PlayerGroupToolTip(this.players);
				stage.addChild(this.tooltip);
			} else if (!areSamePlayers(this.tooltip.players, this.players))
				this.tooltip.setPlayers(this.players);
		} else if (this.tooltip != null) {
			if (this.tooltip.parent != null)
				this.tooltip.parent.removeChild(this.tooltip);
			this.tooltip = null;
		}

		var px = focus.mapX, py = focus.mapY;
		var ppx = this.mapMatrix.a * px + this.mapMatrix.c * py + this.mapMatrix.tx,
			ppy = this.mapMatrix.b * px + this.mapMatrix.d * py + this.mapMatrix.ty;
		this.arrowMatrix.identity();
		this.arrowMatrix.translate(-4, -5);
		this.arrowMatrix.scale(8 / this.blueArrow.width, 32 / this.blueArrow.height);
		this.arrowMatrix.rotate(Camera.angleRad);
		this.arrowMatrix.translate(ppx, ppy);
		g.beginBitmapFill(this.blueArrow, this.arrowMatrix, false);
		g.drawRect(ppx - 16, ppy - 16, 32, 32);
		g.endFill();
	}

	public function zoomIn() {
		this.zoomIndex = this.zoomButtons.setZoomLevel(this.zoomIndex - 1);
	}

	public function zoomOut() {
		this.zoomIndex = this.zoomButtons.setZoomLevel(this.zoomIndex + 1);
	}

	private function createButton(buttonType: String) {
		if (contains(this.button))
			removeChild(this.button);

		if (buttonType == HUB_BUTTON) {
			this.button = new IconButton(AssetLibrary.getImageFromSet("misc16", 31), "Hub", "escapeToHub");
			this.button.addEventListener(MouseEvent.CLICK, this.onHubClick);
		} else if (buttonType == OPTIONS_BUTTON) {
			this.button = new IconButton(AssetLibrary.getImageFromSet("misc16", 15), "Options", "options");
			this.button.addEventListener(MouseEvent.CLICK, this.onOptionsClick);
		}

		this.button.x = 66;
		this.button.y = 53;
		addChild(this.button);
	}

	private function makeViewModel() {
		this.windowRect = new Rectangle(-this.mapWidth / 2, -this.mapHeight / 2, this.mapWidth, this.mapHeight);
		this.maxWH = new Point(this.map.mapWidth, this.map.mapHeight);
		this.miniMapData = new BitmapData(Std.int(this.maxWH.x), Std.int(this.maxWH.y), false, 0);
		var minZoom = Math.max(this.mapWidth / this.maxWH.x, this.mapHeight / this.maxWH.y);
		var z = 4.0;
		while (z > minZoom) {
			this.zoomLevels.push(z);
			z /= 2;
		}

		this.zoomLevels.push(minZoom);
		if (this.zoomButtons != null)
			this.zoomButtons.setZoomLevels(this.zoomLevels.length);
		this.zoomIndex = this.zoomButtons.setZoomLevel(Std.int(Math.min(this.zoomLevels.length, this.zoomIndex)));
	}

	private function makeVisualLayers() {
		this.blueArrow = AssetLibrary.getImageFromSet("misc", 26).clone();
		this.blueArrow.colorTransform(this.blueArrow.rect, new ColorTransform(0, 0, 1));
		graphics.clear();

		graphics.lineStyle(3, 0x666666);
		graphics.beginFill(0x1B1B1B);
		graphics.drawCircle(0, 0, 85);
		graphics.endFill();

		graphics.lineStyle(2, 0x666666);
		graphics.beginFill(0x1B1B1B);
		graphics.drawCircle(-70, 60, 15);
		graphics.endFill();
		graphics.lineStyle(2, 0x666666);
		graphics.beginFill(0x1B1B1B);
		graphics.drawCircle(70, 60, 15);
		graphics.endFill();

		this.groundLayer = new Shape();
		addChild(this.groundLayer);
		this.characterLayer = new Shape();
		addChild(this.characterLayer);

		this.zoomButtons = new MiniMapZoomButtons();
		this.zoomButtons.x = -78;
		this.zoomButtons.y = 42;
		this.zoomButtons.zoom.on(this.onZoomChanged);
		this.zoomButtons.setZoomLevels(this.zoomLevels.length);
		addChild(this.zoomButtons);
	}

	private function addMouseListeners() {
		addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
		addEventListener(MouseEvent.CLICK, this.onMapClick);
	}

	private function onZoomChanged(zoomLevel: Int) {
		this.zoomIndex = zoomLevel;
	}

	private function addMenu() {
		this.menu = new PlayerGroupMenu(this.map, this.tooltip.players);
		this.menu.x = this.tooltip.x + 12;
		this.menu.y = this.tooltip.y;
		stage.addChild(this.menu);
	}

	private function onHubClick(event: MouseEvent) {
		NetworkHandler.escape();
	}

	private function onOptionsClick(event: MouseEvent) {
		Global.gameSprite.inputHandler.clearInput();
		var options = new Options(Global.gameSprite);
		options.x = (Main.stageWidth - 800) / 2;
		options.y = (Main.stageHeight - 600) / 2;
		Global.gameSprite.addChild(options);
	}

	private function onMouseOver(event: MouseEvent) {
		this.isMouseOver = true;
	}

	private function onMouseOut(event: MouseEvent) {
		this.isMouseOver = false;
	}

	private function onMapClick(event: MouseEvent) {
		if (this.tooltip == null || this.tooltip.parent == null || this.tooltip.players == null || this.tooltip.players.length == 0)
			return;

		if (this.menu != null) {
			if (this.menu.parent != null)
				this.menu.parent.removeChild(this.menu);
			this.menu = null;
		}

		this.addMenu();

		if (this.tooltip != null) {
			if (this.tooltip.parent != null)
				this.tooltip.parent.removeChild(this.tooltip);
			this.tooltip = null;
		}
	}
}
