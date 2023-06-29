package game;

import util.TextureRedrawer;
import ui.tooltip.StatToolTip;
import openfl.text.TextFormatAlign;
import ui.tooltip.AbilityToolTip;
import objects.ObjectLibrary;
import openfl.events.MouseEvent;
import openfl.display.BlendMode;
import util.AssetLibrary;
import openfl.display.Shape;
import openfl.display.BitmapData;
import lime.tools.AssetEncoding;
import openfl.Assets;
import openfl.display.Bitmap;
import util.Utils.MathUtil;
import util.Utils.StringUtils;
import util.Settings;
#if !disable_rpc
import hxdiscord_rpc.Types;
import hxdiscord_rpc.Discord;
#end
import map.Camera;
import network.NetworkHandler;
import openfl.display.OpenGLRenderer;
import openfl.events.RenderEvent;
import util.NativeTypes;
import lime.system.System;
import screens.CharacterSelectionScreen;
import map.Map;
import ui.MiniMap;
import objects.Player;
import objects.Projectile;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.filters.DropShadowFilter;
import servers.Server;
import ui.SimpleText;
import ui.TextBox;
import ui.view.Inventory;
import util.PointUtil;
import openfl.utils.ByteArray;

using StringTools;

class StatView extends Sprite {
	private var statText: SimpleText;
	private var lastValue = -1;
	private var lastBoost = -1;
	private var lastMax = -1;
	private var toolTip: StatToolTip;

	public function new(iconSheet: String, iconIdx: Int32, name: String, desc: String) {
		super();

		var tex = TextureRedrawer.redraw(AssetLibrary.getImageFromSet(iconSheet, iconIdx), 40, false, 0);
		this.toolTip = new StatToolTip(tex, name, desc);

		// hitbox
		graphics.beginFill(0, 0);
		graphics.drawRect(0, 0, 69, 26);
		graphics.endFill();

		this.statText = new SimpleText(14, 0xD9D9D9);
		this.statText.setBold(true);
		addChild(this.statText);

		addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
		addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
	}

	public function setBreakdownText(breakdown: String) {
		this.toolTip.setBreakdownText(breakdown);
	}

	public function onRollOver(_: MouseEvent) {
		if (this.toolTip != null && !stage.contains(this.toolTip)) {
			this.toolTip.attachToTarget(this);
			stage.addChild(this.toolTip);
		}
	}

	public function onRollOut(_: MouseEvent) {
		if (this.toolTip != null && this.toolTip.parent != null)
			this.toolTip.detachFromTarget();
	}

	public function draw(value: Int32, boost: Int32, max: Int32) {
		if (value != this.lastValue || boost != this.lastBoost || max != this.lastMax) {
			var color = 0xD9D9D9;
			if (value - boost >= max)
				color = 0xFFE770;
			else if (boost < 0)
				color = 0xFF7070;
			else if (boost > 0)
				color = 0xE69865;

			this.statText.setText(Std.string(value));
			this.statText.setColor(color);
			this.statText.updateMetrics();
			this.statText.x = 27 + (38 - this.statText.width) / 2;
			this.statText.y = 2 + (34 - this.statText.height) / 2;

			this.toolTip.updateBreakdown(value, boost, max);

			this.lastValue = value;
			this.lastBoost = boost;
			this.lastMax = max;
		}
	}
}

class GameSprite extends Sprite {
	public var map: Map;
	public var inputHandler: InputHandler;
	public var decor: Bitmap;
	public var textBox: TextBox;
	public var miniMap: MiniMap;
	public var inventory: Inventory;
	public var lastUpdate: Int32 = 0;
	public var lastFixedUpdate: Int32 = 0;
	public var moveRecords: MoveRecords;
	public var fpsView: SimpleText;
	public var lastFrameUpdate: Int32 = 0;
	public var frames: Int32 = 0;
	public var fps: Int32 = 0;

	private var focus: Player;

	public var isGameStarted = false;

	private var ability1Container: Sprite;
	private var ability1Tooltip: AbilityToolTip;
	private var ability2Container: Sprite;
	private var ability2Tooltip: AbilityToolTip;
	private var ability3Container: Sprite;
	private var ability3Tooltip: AbilityToolTip;
	private var ultimateAbilityContainer: Sprite;
	private var ultimateAbilityTooltip: AbilityToolTip;
	private var levelText: SimpleText;
	private var xpBarContainer: Sprite;
	private var xpBar: Bitmap;
	private var xpBarMask: Bitmap;
	private var hpBarContainer: Sprite;
	private var hpBar: Bitmap;
	private var hpBarMask: Bitmap;
	private var hpBarText: SimpleText;
	private var mpBarContainer: Sprite;
	private var mpBar: Bitmap;
	private var mpBarMask: Bitmap;
	private var mpBarText: SimpleText;
	private var baseDecorTex: BitmapData;
	private var statsDecorTex: BitmapData;
	private var baseStatsBtnTex: BitmapData;
	private var hoverStatsBtnTex: BitmapData;
	private var pressStatsBtnTex: BitmapData;
	private var statsButton: Sprite;
	private var statsButtonBitmap: Bitmap;
	private var strView: StatView;
	private var resView: StatView;
	private var intView: StatView;
	private var hstView: StatView;
	private var witView: StatView;
	private var spdView: StatView;
	private var penView: StatView;
	private var tenView: StatView;
	private var defView: StatView;
	private var staView: StatView;
	private var prcView: StatView;
	private var lastXpPerc = 0.0;
	private var lastHpPerc = 0.0;
	private var lastMpPerc = 0.0;
	private var lastLevel = 1;
	private var uiInited = false;
	private var inited = false;
	private var fromEditor = false;
	private var statsOpen = false;

	public function new(server: Server, createCharacter: Bool, charId: Int, fmMap: ByteArray) {
		super();

		NetworkHandler.reset(server, createCharacter, charId, fmMap);

		this.moveRecords = new MoveRecords();
		this.map = new Map();
		this.fromEditor = fmMap?.length > 0;
		this.inputHandler = new InputHandler(this);

		addEventListener(Event.ADDED_TO_STAGE, this.onAdded);
	}

	private function onAdded(_: Event) {
		removeEventListener(Event.ADDED_TO_STAGE, this.onAdded);

		this.map.initialize();

		this.textBox = new TextBox(this, 400, 250);
		this.textBox.cacheAsBitmap = true;
		this.textBox.y = Math.max(0, Main.stageHeight - this.textBox.height);
		addChild(this.textBox);

		this.baseDecorTex = Assets.getBitmapData("assets/ui/playerInterfaceDecor.png");
		this.statsDecorTex = Assets.getBitmapData("assets/ui/playerInterfaceStatView.png");
		this.decor = new Bitmap(this.baseDecorTex);
		this.decor.cacheAsBitmap = true;
		this.decor.x = (Main.stageWidth - this.decor.width) / 2;
		this.decor.y = Main.stageHeight - this.decor.height;
		addChild(this.decor);

		this.levelText = new SimpleText(20, 0xD9D9D9);
		this.levelText.setBold(true);
		this.levelText.setText("1");
		this.levelText.updateMetrics();
		this.levelText.x = this.decor.x + 211 + (32 - this.levelText.width) / 2;
		this.levelText.y = this.decor.y + 30 + (32 - this.levelText.height) / 2;
		addChild(this.levelText);

		this.hpBarContainer = new Sprite();
		this.hpBarContainer.x = this.decor.x + 32;
		this.hpBarContainer.y = this.decor.y + 3;
		this.hpBar = new Bitmap(Assets.getBitmapData("assets/ui/playerInterfaceHealthBar.png"));
		this.hpBar.cacheAsBitmap = true;
		this.hpBarContainer.addChild(this.hpBar);
		this.hpBarMask = new Bitmap(new BitmapData(8, 8, true));
		this.hpBarMask.cacheAsBitmap = true;
		this.hpBarMask.scaleX = 0;
		this.hpBarMask.scaleY = this.hpBar.height / 8;
		this.hpBarMask.blendMode = BlendMode.SUBTRACT;
		this.hpBarContainer.addChild(this.hpBarMask);
		addChild(this.hpBarContainer);

		this.hpBarText = new SimpleText(14, 0xD9D9D9);
		this.hpBarText.setBold(true);
		this.hpBarText.setItalic(true);
		addChild(this.hpBarText);

		this.mpBarContainer = new Sprite();
		this.mpBarContainer.x = this.decor.x + 32;
		this.mpBarContainer.y = this.decor.y + 25;
		this.mpBar = new Bitmap(Assets.getBitmapData("assets/ui/playerInterfaceManaBar.png"));
		this.mpBar.cacheAsBitmap = true;
		this.mpBarContainer.addChild(this.mpBar);
		this.mpBarMask = new Bitmap(new BitmapData(8, 8, true));
		this.mpBarMask.cacheAsBitmap = true;
		this.mpBarMask.scaleX = 0;
		this.mpBarMask.scaleY = this.mpBar.height / 8;
		this.mpBarMask.blendMode = BlendMode.SUBTRACT;
		this.mpBarContainer.addChild(this.mpBarMask);
		addChild(this.mpBarContainer);

		this.mpBarText = new SimpleText(14, 0xD9D9D9);
		this.mpBarText.setBold(true);
		this.mpBarText.setItalic(true);
		addChild(this.mpBarText);

		this.xpBarContainer = new Sprite();
		this.xpBarContainer.x = this.decor.x + 36;
		this.xpBarContainer.y = this.decor.y + 47;
		this.xpBar = new Bitmap(Assets.getBitmapData("assets/ui/playerInterfaceXPBar.png"));
		this.xpBar.cacheAsBitmap = true;
		this.xpBarContainer.addChild(this.xpBar);
		this.xpBarMask = new Bitmap(new BitmapData(8, 8, true));
		this.xpBarMask.scaleX = this.xpBar.width / 8;
		this.xpBarMask.scaleY = this.xpBar.height / 8;
		this.xpBarMask.blendMode = BlendMode.SUBTRACT;
		this.xpBarContainer.addChild(this.xpBarMask);
		addChild(this.xpBarContainer);

		this.miniMap = new MiniMap(200, 200);
		this.miniMap.x = Main.stageWidth - this.miniMap.decor.width / 2;
		this.miniMap.y = this.miniMap.decor.height / 2 - 11;
		addChild(this.miniMap);

		this.inventory = new Inventory();
		this.inventory.cacheAsBitmap = true;
		this.inventory.x = Main.stageWidth - this.inventory.decor.width;
		this.inventory.y = Main.stageHeight - this.inventory.decor.height;
		addChild(this.inventory);

		this.baseStatsBtnTex = Assets.getBitmapData("assets/ui/playerInterfaceStatViewButtonBase.png");
		this.hoverStatsBtnTex = Assets.getBitmapData("assets/ui/playerInterfaceStatViewButtonHover.png");
		this.pressStatsBtnTex = Assets.getBitmapData("assets/ui/playerInterfaceStatViewButtonPress.png");
		this.statsButtonBitmap = new Bitmap(this.baseStatsBtnTex);
		this.statsButton = new Sprite();
		this.statsButton.cacheAsBitmap = true;
		this.statsButton.x = this.decor.x;
		this.statsButton.y = this.decor.y + 27;
		this.statsButton.addChild(this.statsButtonBitmap);
		this.statsButton.addEventListener(MouseEvent.ROLL_OVER, this.onStatsRollOver);
		this.statsButton.addEventListener(MouseEvent.ROLL_OUT, this.onStatsRollOut);
		this.statsButton.addEventListener(MouseEvent.MOUSE_DOWN, this.onStatsMouseDown);
		this.statsButton.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, this.onStatsMouseDown);
		this.statsButton.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, this.onStatsMouseDown);
		this.statsButton.addEventListener(MouseEvent.MOUSE_UP, this.onStatsMouseUp);
		this.statsButton.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, this.onStatsMouseUp);
		this.statsButton.addEventListener(MouseEvent.RIGHT_MOUSE_UP, this.onStatsMouseUp);
		addChild(this.statsButton);

		this.strView = new StatView("misc16", 32, "Strength", "Increases your Physical Damage");
		this.strView.visible = false;
		this.strView.x = this.decor.x + 32;
		this.strView.y = this.decor.y + 123;
		addChild(this.strView);

		this.resView = new StatView("misc16", 57, "Resistance", "Decreases incoming Magic Damage");
		this.resView.visible = false;
		this.resView.x = this.decor.x + 103;
		this.resView.y = this.decor.y + 123;
		addChild(this.resView);

		this.intView = new StatView("misc16", 59, "Intelligence", "Increases mana regeneration");
		this.intView.visible = false;
		this.intView.x = this.decor.x + 174;
		this.intView.y = this.decor.y + 123;
		addChild(this.intView);

		this.hstView = new StatView("misc16", 58, "Haste", "Decreases ability cooldowns");
		this.hstView.visible = false;
		this.hstView.x = this.decor.x + 245;
		this.hstView.y = this.decor.y + 123;
		addChild(this.hstView);

		this.witView = new StatView("misc16", 35, "Wit", "Increases your Magic Damage");
		this.witView.visible = false;
		this.witView.x = this.decor.x + 32;
		this.witView.y = this.decor.y + 151;
		addChild(this.witView);

		this.spdView = new StatView("misc16", 34, "Speed", "Increases your Move Speed");
		this.spdView.visible = false;
		this.spdView.x = this.decor.x + 103;
		this.spdView.y = this.decor.y + 151;
		addChild(this.spdView);

		this.penView = new StatView("misc16", 38, "Penetration", "Decreases the effect of the enemy's Defense");
		this.penView.visible = false;
		this.penView.x = this.decor.x + 174;
		this.penView.y = this.decor.y + 151;
		addChild(this.penView);

		this.tenView = new StatView("misc16", 37, "Tenacity", "Decreases the length of Debuffs afflicting you");
		this.tenView.visible = false;
		this.tenView.x = this.decor.x + 245;
		this.tenView.y = this.decor.y + 151;
		addChild(this.tenView);

		this.defView = new StatView("misc16", 33, "Defense", "Decreases incoming Physical Damage");
		this.defView.visible = false;
		this.defView.x = this.decor.x + 32;
		this.defView.y = this.decor.y + 179;
		addChild(this.defView);

		this.staView = new StatView("misc16", 36, "Stamina", "Increases health regeneration");
		this.staView.visible = false;
		this.staView.x = this.decor.x + 103;
		this.staView.y = this.decor.y + 179;
		addChild(this.staView);

		this.prcView = new StatView("misc16", 60, "Piercing", "Decreases the effect of the enemy's Resistance");
		this.prcView.visible = false;
		this.prcView.x = this.decor.x + 174;
		this.prcView.y = this.decor.y + 179;
		addChild(this.prcView);

		if (Settings.perfStatsOpen)
			this.addFpsView();
		this.lastFrameUpdate = System.getTimer();

		this.inited = true;

		NetworkHandler.connect();
	}

	private function onStatsRollOver(_: MouseEvent) {
		this.statsButtonBitmap.bitmapData = this.hoverStatsBtnTex;
	}

	public function toggleStats() {
		this.statsOpen = !this.statsOpen;
		this.decor.bitmapData = this.statsOpen ? this.statsDecorTex : this.baseDecorTex;
		this.decor.x = (Main.stageWidth - this.decor.width) / 2;
		this.decor.y = Main.stageHeight - this.decor.height;

		this.statsButton.x = this.decor.x + (this.statsOpen ? (this.statsDecorTex.width - this.baseDecorTex.width) / 2 : 0);
		this.statsButton.y = this.decor.y + 27;

		this.levelText.x = this.decor.x
			+ 211
			+ (32 - this.levelText.width) / 2
			+ (this.statsOpen ? (this.statsDecorTex.width - this.baseDecorTex.width) / 2 : 0);
		this.levelText.y = this.decor.y + 30 + (32 - this.levelText.height) / 2;

		this.hpBarContainer.x = this.decor.x + 32 + (this.statsOpen ? (this.statsDecorTex.width - this.baseDecorTex.width) / 2 : 0);
		this.hpBarContainer.y = this.decor.y + 3;
		this.hpBarText.x = this.hpBarContainer.x + (180 - this.hpBarText.width) / 2;
		this.hpBarText.y = this.hpBarContainer.y + (16 - this.hpBarText.height) / 2;

		this.mpBarContainer.x = this.decor.x + 32 + (this.statsOpen ? (this.statsDecorTex.width - this.baseDecorTex.width) / 2 : 0);
		this.mpBarContainer.y = this.decor.y + 25;
		this.mpBarText.x = this.mpBarContainer.x + (180 - this.mpBarText.width) / 2;
		this.mpBarText.y = this.mpBarContainer.y + (16 - this.mpBarText.height) / 2;

		this.xpBarContainer.x = this.decor.x + 36 + (this.statsOpen ? (this.statsDecorTex.width - this.baseDecorTex.width) / 2 : 0);
		this.xpBarContainer.y = this.decor.y + 47;

		this.ability1Container.x = this.decor.x + 37 + (this.statsOpen ? (this.statsDecorTex.width - this.baseDecorTex.width) / 2 : 0);
		this.ability1Container.y = this.decor.y + 64;
		this.ability2Container.x = this.ability1Container.x + 44;
		this.ability2Container.y = this.decor.y + 64;
		this.ability3Container.x = this.ability2Container.x + 44;
		this.ability3Container.y = this.decor.y + 64;
		this.ultimateAbilityContainer.x = this.ability3Container.x + 44;
		this.ultimateAbilityContainer.y = this.decor.y + 64;

		this.strView.x = this.decor.x + 32;
		this.strView.y = this.decor.y + 123;

		this.resView.x = this.decor.x + 103;
		this.resView.y = this.decor.y + 123;

		this.intView.x = this.decor.x + 174;
		this.intView.y = this.decor.y + 123;

		this.hstView.x = this.decor.x + 245;
		this.hstView.y = this.decor.y + 123;

		this.witView.x = this.decor.x + 32;
		this.witView.y = this.decor.y + 151;

		this.spdView.x = this.decor.x + 103;
		this.spdView.y = this.decor.y + 151;

		this.penView.x = this.decor.x + 174;
		this.penView.y = this.decor.y + 151;

		this.tenView.x = this.decor.x + 245;
		this.tenView.y = this.decor.y + 151;

		this.defView.x = this.decor.x + 32;
		this.defView.y = this.decor.y + 179;

		this.staView.x = this.decor.x + 103;
		this.staView.y = this.decor.y + 179;

		this.prcView.x = this.decor.x + 174;
		this.prcView.y = this.decor.y + 179;

		this.strView.visible = this.resView.visible = this.intView.visible = this.hstView.visible = this.witView.visible = this.spdView.visible = this.penView.visible = this.tenView.visible = this.defView.visible = this.staView.visible = this.prcView.visible = this.statsOpen;
	}

	private function onStatsMouseUp(_: MouseEvent) {
		this.toggleStats();
		this.statsButtonBitmap.bitmapData = this.baseStatsBtnTex;
	}

	private function onStatsRollOut(_: MouseEvent) {
		this.statsButtonBitmap.bitmapData = this.baseStatsBtnTex;
	}

	private function onStatsMouseDown(_: MouseEvent) {
		this.statsButtonBitmap.bitmapData = this.pressStatsBtnTex;
	}

	public function close() {
		stage.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		stage.removeEventListener(Event.RESIZE, this.onResize);
		if (contains(this.miniMap))
			removeChild(this.miniMap);
		if (this.map != null)
			this.map.dispose();
		if (this.miniMap != null)
			this.miniMap.dispose();
		Projectile.disposeBullId();
		Global.layers.dialogs.closeDialogs();
		Global.layers.screens.setScreen(fromEditor ? Global.currentEditor : new CharacterSelectionScreen());
	}

	public function setFocus(focus: Player) {
		focus = focus != null ? focus : this.map.player;
		this.focus = focus;
	}

	public function addFpsView() {
		if (this.fpsView != null)
			return;

		this.fpsView = new SimpleText(14, 0xB3B3B3);
		this.fpsView.cacheAsBitmap = true;
		this.fpsView.setText("FPS: -1\nMemory: -1 MB");
		this.fpsView.filters = [new DropShadowFilter()];
		this.fpsView.setBold(true);
		this.fpsView.setAlignment(TextFormatAlign.RIGHT);
		this.fpsView.updateMetrics();
		this.fpsView.x = Main.stageWidth - this.fpsView.width - 5;
		this.fpsView.y = this.miniMap.y + this.miniMap.decor.height / 2 + 25;
		addChild(this.fpsView);
	}

	public function updateFPSView(time: Int32) {
		this.frames++;
		var dt = time - this.lastFrameUpdate;
		if (dt >= 1000) {
			this.lastFrameUpdate = time;
			this.fpsView.text = 'FPS: ${this.frames}\nMemory: ${Math.round((untyped __global__.__hxcpp_gc_used_bytes()) / (1024 * 1024))} MB';
			this.fpsView.updateMetrics();
			this.fpsView.x = Main.stageWidth - this.fpsView.width - 5;
			this.frames = 0;
		}
	}

	public function initialize() {
		if (this.inited) {
			this.miniMap.update();
			for (go in this.map.gameObjects)
				go.dispose();
			this.map.gameObjects.resize(0);
			this.map.gameObjectsLen = 0;

			this.map.speechBalloons.clear();
			this.map.statusTexts.resize(0);
			this.connect();
			return;
		}

		this.connect();
	}

	public function connect() {
		if (!this.isGameStarted) {
			this.isGameStarted = true;
			this.lastFrameUpdate = -1;
			this.frames = -1;
			this.lastUpdate = System.getTimer();
			stage.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
			stage.addEventListener(Event.RESIZE, this.onResize);
		}
	}

	public function disconnect() {
		if (this.isGameStarted) {
			this.isGameStarted = false;
			this.uiInited = false;
			stage.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
			stage.removeEventListener(Event.RESIZE, this.onResize);
			// this.map.dispose();
			// this.miniMap.dispose();
			Projectile.disposeBullId();

			resetAbilitiesUI();
		}
	}

	private function onResize(_: Event) {
		if (this.decor != null) {
			this.decor.x = (Main.stageWidth - this.decor.width) / 2;
			this.decor.y = Main.stageHeight - this.decor.height;
		}

		if (this.hpBarContainer != null) {
			this.hpBarContainer.x = this.decor.x + 32 + (this.statsOpen ? (this.statsDecorTex.width - this.baseDecorTex.width) / 2 : 0);
			this.hpBarContainer.y = this.decor.y + 3;

			if (this.hpBarText != null) {
				this.hpBarText.x = this.hpBarContainer.x + (180 - this.hpBarText.width) / 2;
				this.hpBarText.y = this.hpBarContainer.y + (16 - this.hpBarText.height) / 2;
			}
		}

		if (this.mpBarContainer != null) {
			this.mpBarContainer.x = this.decor.x + 32 + (this.statsOpen ? (this.statsDecorTex.width - this.baseDecorTex.width) / 2 : 0);
			this.mpBarContainer.y = this.decor.y + 25;

			if (this.mpBarText != null) {
				this.mpBarText.x = this.mpBarContainer.x + (180 - this.mpBarText.width) / 2;
				this.mpBarText.y = this.mpBarContainer.y + (16 - this.mpBarText.height) / 2;
			}
		}

		if (this.xpBarContainer != null) {
			this.xpBarContainer.x = this.decor.x + 36 + (this.statsOpen ? (this.statsDecorTex.width - this.baseDecorTex.width) / 2 : 0);
			this.xpBarContainer.y = this.decor.y + 47;
		}

		if (this.statsButton != null) {
			this.statsButton.x = this.decor.x + (this.statsOpen ? (this.statsDecorTex.width - this.baseDecorTex.width) / 2 : 0);
			this.statsButton.y = this.decor.y + 27;
		}

		if (this.levelText != null) {
			this.levelText.x = this.decor.x
				+ 211
				+ (32 - this.levelText.width) / 2
				+ (this.statsOpen ? (this.statsDecorTex.width - this.baseDecorTex.width) / 2 : 0);
			this.levelText.y = this.decor.y + 30 + (32 - this.levelText.height) / 2;
		}

		if (this.ability1Container != null) {
			this.ability1Container.x = this.decor.x + 37 + (this.statsOpen ? (this.statsDecorTex.width - this.baseDecorTex.width) / 2 : 0);
			this.ability1Container.y = this.decor.y + 64;

			if (this.ability2Container != null) {
				this.ability2Container.x = this.ability1Container.x + 44;
				this.ability2Container.y = this.decor.y + 64;

				if (this.ability3Container != null) {
					this.ability3Container.x = this.ability2Container.x + 44;
					this.ability3Container.y = this.decor.y + 64;

					// love to see it
					if (this.ultimateAbilityContainer != null) {
						this.ultimateAbilityContainer.x = this.ability3Container.x + 44;
						this.ultimateAbilityContainer.y = this.decor.y + 64;
					}
				}
			}
		}

		if (this.statsOpen) {
			this.strView.x = this.decor.x + 32;
			this.strView.y = this.decor.y + 123;

			this.resView.x = this.decor.x + 103;
			this.resView.y = this.decor.y + 123;

			this.intView.x = this.decor.x + 174;
			this.intView.y = this.decor.y + 123;

			this.hstView.x = this.decor.x + 245;
			this.hstView.y = this.decor.y + 123;

			this.witView.x = this.decor.x + 32;
			this.witView.y = this.decor.y + 151;

			this.spdView.x = this.decor.x + 103;
			this.spdView.y = this.decor.y + 151;

			this.penView.x = this.decor.x + 174;
			this.penView.y = this.decor.y + 151;

			this.tenView.x = this.decor.x + 245;
			this.tenView.y = this.decor.y + 151;

			this.defView.x = this.decor.x + 32;
			this.defView.y = this.decor.y + 179;

			this.staView.x = this.decor.x + 103;
			this.staView.y = this.decor.y + 179;

			this.prcView.x = this.decor.x + 174;
			this.prcView.y = this.decor.y + 179;
		}

		if (this.inventory != null) {
			this.inventory.x = Main.stageWidth - this.inventory.decor.width;
			this.inventory.y = Main.stageHeight - this.inventory.decor.height;
		}

		if (this.miniMap != null) {
			this.miniMap.x = Main.stageWidth - this.miniMap.decor.width / 2;
			this.miniMap.y = this.miniMap.decor.height / 2 - 11;
		}

		if (this.fpsView != null) {
			this.fpsView.x = Main.stageWidth - this.fpsView.width - 5;
			this.fpsView.y = this.miniMap.y + this.miniMap.decor.height / 2 + 25;
		}

		if (this.textBox != null)
			this.textBox.y = Math.max(0, Main.stageHeight - this.textBox.height);
	}

	private function resetAbilitiesUI() {
		if (this.ability1Container != null && contains(this.ability1Container))
			removeChild(this.ability1Container);

		if (this.ability2Container != null && contains(this.ability2Container))
			removeChild(this.ability2Container);

		if (this.ability3Container != null && contains(this.ability3Container))
			removeChild(this.ability3Container);

		if (this.ultimateAbilityContainer != null && contains(this.ultimateAbilityContainer))
			removeChild(this.ultimateAbilityContainer);
	}

	private function updatePlayerUI(player: Player) {
		var xpPerc = player.xp / player.xpTarget;
		if (xpPerc != this.lastXpPerc) {
			this.xpBarMask.x = this.xpBar.width * xpPerc;
			this.xpBarMask.scaleX = this.xpBar.width * (1 - xpPerc) / 8;
			this.lastXpPerc = xpPerc;
		}

		var mpPerc = player.mp / player.maxMP;
		if (mpPerc != this.lastMpPerc) {
			this.mpBarMask.x = this.mpBar.width * mpPerc;
			this.mpBarMask.scaleX = this.mpBar.width * (1 - mpPerc) / 8;

			var color = 0xD9D9D9;
			if (player.maxMP - player.maxHPBoost >= player.maxMPMax)
				color = 0xFFE770;
			else if (player.maxMPBoost < 0)
				color = 0xFF7070;
			else if (player.maxMPBoost > 0)
				color = 0xE69865;

			this.mpBarText.setText('${player.mp}/${player.maxMP}');
			this.mpBarText.setColor(color);
			this.mpBarText.updateMetrics();
			this.mpBarText.x = this.mpBarContainer.x + (180 - this.mpBarText.width) / 2;
			this.mpBarText.y = this.mpBarContainer.y + (16 - this.mpBarText.height) / 2;

			this.lastMpPerc = mpPerc;
		}

		var hpPerc = player.hp / player.maxHP;
		if (hpPerc != this.lastHpPerc) {
			this.hpBarMask.x = this.hpBar.width * hpPerc;
			this.hpBarMask.scaleX = this.hpBar.width * (1 - hpPerc) / 8;

			var color = 0xD9D9D9;
			if (player.maxHP - player.maxHPBoost >= player.maxHPMax)
				color = 0xFFE770;
			else if (player.maxHPBoost < 0)
				color = 0xFF7070;
			else if (player.maxHPBoost > 0)
				color = 0xE69865;

			this.hpBarText.setText('${player.hp}/${player.maxHP}');
			this.hpBarText.setColor(color);
			this.hpBarText.updateMetrics();
			this.hpBarText.x = this.hpBarContainer.x + (180 - this.hpBarText.width) / 2;
			this.hpBarText.y = this.hpBarContainer.y + (16 - this.hpBarText.height) / 2;

			this.lastHpPerc = hpPerc;
		}

		if (player.level != this.lastLevel) {
			this.levelText.setText(Std.string(player.level));
			this.levelText.updateMetrics();
			this.levelText.x = this.decor.x + 211 + (32 - this.levelText.width) / 2;
			this.levelText.y = this.decor.y + 30 + (32 - this.levelText.height) / 2;

			this.lastLevel = player.level;
		}

		this.strView.draw(player.strength, player.strengthBoost, player.strengthMax);
		this.resView.draw(player.resistance, player.resistanceBoost, player.resistanceMax);
		this.intView.draw(player.intelligence, player.intelligenceBoost, player.intelligenceMax);
		this.hstView.draw(player.haste, player.hasteBoost, player.hasteMax);
		this.witView.draw(player.wit, player.witBoost, player.witMax);
		this.spdView.draw(player.speed, player.speedBoost, player.speedMax);
		this.penView.draw(player.penetration, player.penetrationBoost, player.penetrationMax);
		this.tenView.draw(player.tenacity, player.tenacityBoost, player.tenacityMax);
		this.defView.draw(player.defense, player.defenseBoost, player.defenseMax);
		this.staView.draw(player.stamina, player.staminaBoost, player.staminaMax);
		this.prcView.draw(player.piercing, player.piercingBoost, player.piercingMax);
	}

	private function onAbility1RollOver(_: MouseEvent) {
		this.ability1Tooltip.attachToTarget(this.ability1Container);
		stage.addChild(this.ability1Tooltip);
	}

	private function onAbility1RollOut(_: MouseEvent) {
		this.ability1Tooltip.detachFromTarget();
		stage.removeChild(this.ability1Tooltip);
	}

	private function onAbility2RollOver(_: MouseEvent) {
		this.ability2Tooltip.attachToTarget(this.ability2Container);
		stage.addChild(this.ability2Tooltip);
	}

	private function onAbility2RollOut(_: MouseEvent) {
		this.ability2Tooltip.detachFromTarget();
		stage.removeChild(this.ability2Tooltip);
	}

	private function onAbility3RollOver(_: MouseEvent) {
		this.ability3Tooltip.attachToTarget(this.ability3Container);
		stage.addChild(this.ability3Tooltip);
	}

	private function onAbility3RollOut(_: MouseEvent) {
		this.ability3Tooltip.detachFromTarget();
		stage.removeChild(this.ability3Tooltip);
	}

	private function onUltimateAbilityRollOver(_: MouseEvent) {
		this.ultimateAbilityTooltip.attachToTarget(this.ultimateAbilityContainer);
		stage.addChild(this.ultimateAbilityTooltip);
	}

	private function onUltimateAbilityRollOut(_: MouseEvent) {
		this.ultimateAbilityTooltip.detachFromTarget();
		stage.removeChild(this.ultimateAbilityTooltip);
	}

	private function onEnterFrame(event: Event) {
		if (!this.isGameStarted)
			return;

		var time: Int32 = System.getTimer();
		if (time - this.lastFixedUpdate > 33) {
			if (this.map == null || this.map.player == null)
				return;

			var minDist = 1.0;
			var closestInteractive = -1;
			var playerX = this.map.player.mapX;
			var playerY = this.map.player.mapY;
			for (go in this.map.gameObjects)
				if (go?.props != null
					&& (go.objClass == "Portal" || go.objClass == "Container")
					&& (Math.abs(playerX - go.mapX) < 1 || Math.abs(playerY - go.mapY) < 1)) {
					var dist = PointUtil.distanceXY(go.mapX, go.mapY, playerX, playerY);
					if (dist < minDist) {
						minDist = dist;
						closestInteractive = go.objectId;
					}
				}

			Global.currentInteractiveTarget = closestInteractive;

			var player = this.map.player;
			if (player != null) {
				if (!this.uiInited) {
					this.inventory.init(player);

					final className = player.props.displayId;
					#if !disable_rpc
					if (Main.rpcReady) {
						var discordPresence = DiscordRichPresence.create();
						discordPresence.state = 'In ${this.map.mapName}';
						discordPresence.details = '';
						discordPresence.largeImageKey = 'logo';
						discordPresence.largeImageText = 'v${Settings.BUILD_VERSION}';
						discordPresence.smallImageKey = className.toLowerCase().replace(' ', '_');
						discordPresence.smallImageText = 'Tier ${StringUtils.toRoman(player.level)} $className';
						discordPresence.startTimestamp = Main.startTime;
						Discord.UpdatePresence(cpp.RawConstPointer.addressOf(discordPresence));
					}
					#end

					this.strView.setBreakdownText("Being a " + className + " grants you $base/$max Strength\nYou receive $boost Strength from Boosts");
					this.resView.setBreakdownText("Being a " + className + " grants you $base/$max Resistance\nYou receive $boost Resistance from Boosts");
					this.intView.setBreakdownText("Being a " + className + " grants you $base/$max Intelligence\nYou receive $boost Intelligence from Boosts");
					this.hstView.setBreakdownText("Being a " + className + " grants you $base/$max Haste\nYou receive $boost Haste from Boosts");
					this.witView.setBreakdownText("Being a " + className + " grants you $base/$max Wit\nYou receive $boost Wit from Boosts");
					this.spdView.setBreakdownText("Being a " + className + " grants you $base/$max Speed\nYou receive $boost Speed from Boosts");
					this.penView.setBreakdownText("Being a " + className + " grants you $base/$max Penetration\nYou receive $boost Penetration from Boosts");
					this.tenView.setBreakdownText("Being a " + className + " grants you $base/$max Tenacity\nYou receive $boost Tenacity from Boosts");
					this.defView.setBreakdownText("Being a " + className + " grants you $base/$max Defense\nYou receive $boost Defense from Boosts");
					this.staView.setBreakdownText("Being a " + className + " grants you $base/$max Stamina\nYou receive $boost Stamina from Boosts");
					this.prcView.setBreakdownText("Being a " + className + " grants you $base/$max Piercing\nYou receive $boost Piercing from Boosts");

					var abilProps = ObjectLibrary.typeToAbilityProps.get(player.objectType);

					var abilProps1 = abilProps.ability1;
					this.ability1Container = new Sprite();
					this.ability1Container.x = this.decor.x + 37 + (this.statsOpen ? (this.statsDecorTex.width - this.baseDecorTex.width) / 2 : 0);
					this.ability1Container.y = this.decor.y + 64;
					this.ability1Container.addChild(new Bitmap(abilProps1.icon));
					this.ability1Container.addEventListener(MouseEvent.ROLL_OVER, this.onAbility1RollOver);
					this.ability1Container.addEventListener(MouseEvent.ROLL_OUT, this.onAbility1RollOut);
					addChild(this.ability1Container);
					this.ability1Tooltip = new AbilityToolTip(abilProps1.icon, abilProps1.manaCost, abilProps1.healthCost, abilProps1.cooldown,
						abilProps1.description, abilProps1.name, '1');

					var abilProps2 = abilProps.ability2;
					this.ability2Container = new Sprite();
					this.ability2Container.x = this.ability1Container.x + 44;
					this.ability2Container.y = this.decor.y + 64;
					this.ability2Container.addChild(new Bitmap(abilProps2.icon));
					this.ability2Container.addEventListener(MouseEvent.ROLL_OVER, this.onAbility2RollOver);
					this.ability2Container.addEventListener(MouseEvent.ROLL_OUT, this.onAbility2RollOut);
					addChild(this.ability2Container);
					this.ability2Tooltip = new AbilityToolTip(abilProps2.icon, abilProps2.manaCost, abilProps2.healthCost, abilProps2.cooldown,
						abilProps2.description, abilProps2.name, '2');

					var abilProps3 = abilProps.ability3;
					this.ability3Container = new Sprite();
					this.ability3Container.x = this.ability2Container.x + 44;
					this.ability3Container.y = this.decor.y + 64;
					this.ability3Container.addChild(new Bitmap(abilProps3.icon));
					this.ability3Container.addEventListener(MouseEvent.ROLL_OVER, this.onAbility3RollOver);
					this.ability3Container.addEventListener(MouseEvent.ROLL_OUT, this.onAbility3RollOut);
					addChild(this.ability3Container);
					this.ability3Tooltip = new AbilityToolTip(abilProps3.icon, abilProps3.manaCost, abilProps3.healthCost, abilProps3.cooldown,
						abilProps3.description, abilProps3.name, '3');

					var ultimateAbilProps = abilProps.ultimateAbility;
					this.ultimateAbilityContainer = new Sprite();
					this.ultimateAbilityContainer.x = this.ability3Container.x + 44;
					this.ultimateAbilityContainer.y = this.decor.y + 64;
					this.ultimateAbilityContainer.addChild(new Bitmap(ultimateAbilProps.icon));
					this.ultimateAbilityContainer.addEventListener(MouseEvent.ROLL_OVER, this.onUltimateAbilityRollOver);
					this.ultimateAbilityContainer.addEventListener(MouseEvent.ROLL_OUT, this.onUltimateAbilityRollOut);
					addChild(this.ultimateAbilityContainer);
					this.ultimateAbilityTooltip = new AbilityToolTip(ultimateAbilProps.icon, ultimateAbilProps.manaCost, ultimateAbilProps.healthCost,
						ultimateAbilProps.cooldown, ultimateAbilProps.description, ultimateAbilProps.name, '4');

					this.uiInited = true;
				}

				this.miniMap.draw();
				this.inventory.draw(player);
				this.updatePlayerUI(player);
				this.moveRecords.addRecord(time, player.mapX, player.mapY);
			}

			this.lastFixedUpdate = time;
		}

		if (this.fpsView != null)
			this.updateFPSView(time);

		var dt: Int16 = time - this.lastUpdate;
		if (dt < 1)
			dt = 1;

		this.map.update(time, dt);
		Camera.update(dt);

		if (this.focus != null) {
			Camera.configureCamera(this.focus.mapX, this.focus.mapY);
			this.map.draw(time);
		}

		this.lastUpdate = time;
	}
}
