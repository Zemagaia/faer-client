package;

import discord_rpc.DiscordRpc;
import engine.GLTextureData;
import util.BinPacker;
import openfl.display.BitmapData;
import network.NetworkHandler;
import map.Camera;
import util.Utils;
import game.model.VialModel;
import appengine.RequestHandler;
import util.AssetLoader;
import openfl.display.Bitmap;
import openfl.ui.Mouse;
import util.AssetLibrary;
import openfl.display.Sprite;
import openfl.display.Stage3D;
import openfl.display.Stage;
import openfl.display.StageQuality;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.events.MouseEvent;
import util.Settings;

class Main extends Sprite {
	public static inline final PADDING = 2;
	public static inline final ATLAS_WIDTH = 1024;
	public static inline final ATLAS_HEIGHT = 1024;

	public static var stageWidth = 1024;
	public static var stageHeight = 768;
	public static var primaryStage: Stage;
	public static var primaryStage3D: Stage3D;
	public static var tempAtlas: BitmapData;
	public static var atlasPacker: BinPacker;
	public static var atlas: GLTextureData;
	public static var startTime: Int;
	public static var rpcReady: Bool;

	private static var baseCursorSprite: Bitmap;
	private static var clickCursorSprite: Bitmap;
	private static var mouseDown = false;

	public function new() {
		super();

		tempAtlas = new BitmapData(ATLAS_WIDTH, ATLAS_HEIGHT, true, 0);
		atlasPacker = new BinPacker(ATLAS_WIDTH, ATLAS_HEIGHT);
		primaryStage3D = stage.stage3Ds[0];
		primaryStage = stage;

		Settings.load();
		AssetLoader.load();

		startTime = Std.int(Date.now().getTime() / 1000);
		DiscordRpc.start({
			clientID: "1095646272171552811",
			onReady: () -> {
				rpcReady = true;
			},
			onError: (code: Int, message: String) -> {
				trace('Discord RPC Error (code $code): $message');
			},
			onDisconnected: (code: Int, message: String) -> {
				trace('Discord RPC Disconnected (code $code): $message');
			}
		});

		refreshCursor();

		Camera.init();
		NetworkHandler.init();
		RequestHandler.init();
		MathUtil.init();
		VialModel.init();

		Global.init(this);

		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.quality = StageQuality.LOW;

		stage.addEventListener(Event.RESIZE, this.onResize);
		stage.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
		stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMouseUp);
	}

	public static function refreshCursor() {
		if (Settings.selectedCursor == -1) {
			Mouse.show();
			return;
		}

		Mouse.hide();
		if (primaryStage.contains(baseCursorSprite))
			primaryStage.removeChild(baseCursorSprite);
		baseCursorSprite = new Bitmap(AssetLibrary.getImageFromSet("cursors", Settings.selectedCursor * 2 + 1));
		primaryStage.addChild(baseCursorSprite);
		if (primaryStage.contains(clickCursorSprite))
			primaryStage.removeChild(clickCursorSprite);
		clickCursorSprite = new Bitmap(AssetLibrary.getImageFromSet("cursors", Settings.selectedCursor * 2));
		primaryStage.addChild(clickCursorSprite);
	}

	private final function onResize(_: Event) {
		stageHeight = stage.stageHeight;
		stageWidth = stage.stageWidth;
	}

	private final function onEnterFrame(_: Event) {
		DiscordRpc.process();

		if (baseCursorSprite == null)
			return;

		clickCursorSprite.visible = mouseDown;
		baseCursorSprite.visible = !mouseDown;

		clickCursorSprite.x = baseCursorSprite.x = stage.mouseX - 32 / 2;
		clickCursorSprite.y = baseCursorSprite.y = stage.mouseY - 32 / 2;
	}

	private static function onMouseDown(_: MouseEvent) {
		mouseDown = true;
	}

	private static function onMouseUp(_: MouseEvent) {
		mouseDown = false;
	}
}
