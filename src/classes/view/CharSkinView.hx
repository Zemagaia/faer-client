package classes.view;

import ui.ClickableText;
import appengine.SavedCharacter;
import util.Settings;
import game.model.GameInitData;
import game.view.CurrencyDisplay;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import screens.NewCharacterScreen;
import ui.view.ScreenBase;

class CharSkinView extends Sprite {
	private var playBtn: ClickableText;
	private var backBtn: ClickableText;
	private static var playerXML: Xml;

	public function new(_playerXML: Xml) {
		super();
		
		playerXML = _playerXML;

		addChild(new ScreenBase());

		var shape: Shape = new Shape();
		shape.graphics.clear();
		shape.graphics.lineStyle(2, 0x545454);
		shape.graphics.moveTo(0, 105);
		shape.graphics.lineTo(800, 105);
		shape.graphics.moveTo(346, 105);
		shape.graphics.lineTo(346, 526);
		addChild(shape);

		var display: CurrencyDisplay = new CurrencyDisplay(CurrencyDisplay.RIGHT_TO_LEFT);
		display.x = Main.stageWidth - 5;
		display.y = 25;
		addChild(display);

		this.playBtn = new ClickableText(36, false, "play");
		this.playBtn.x = 400 - this.playBtn.width / 2;
		this.playBtn.y = 520;
		addChild(this.playBtn);
		var hasSlot: Bool = Global.playerModel.hasAvailableCharSlot();
		this.setPlayButtonEnabled(hasSlot);
		if (hasSlot)
			this.playBtn.addEventListener(MouseEvent.CLICK, onPlay);

		this.backBtn = new ClickableText(22, false, "back");
		this.backBtn.x = 30;
		this.backBtn.y = 534;
		addChild(this.backBtn);
		this.backBtn.addEventListener(MouseEvent.CLICK, onBack);

		var classView: ClassDetailView = new ClassDetailView();
		classView.x = 5;
		classView.y = 110;
		addChild(classView);

		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}

	private function onAdded(_: Event) {
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
	}

	private function onRemoved(_: Event) {
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
		this.playBtn.removeEventListener(MouseEvent.CLICK, onPlay);
		this.backBtn.removeEventListener(MouseEvent.CLICK, onBack);
	}

	private static function onBack(_: MouseEvent) {
		Global.layers.screens.setScreen(new NewCharacterScreen());
	}

	private static function onPlay(_: MouseEvent) {
		var game: GameInitData = new GameInitData();
		game.createCharacter = true;
		game.charId = Global.playerModel.getNextCharId();
		game.gameId = Settings.HUB_GAMEID;
		//Global.playerModel.addCharacter(new SavedCharacter(playerXML, Global.playerModel.getName()));
		Global.playGame(game);
	}

	public function setPlayButtonEnabled(activate: Bool) {
		
	}
}
