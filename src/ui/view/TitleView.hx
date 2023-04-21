package ui.view;

#if !disable_rpc
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
#end
import mapeditor.MapEditor;
import account.Account;
import util.Settings;
import account.view.AccountDetailDialog;
import account.view.RegisterDialog;
import game.model.GameInitData;
import openfl.display.Sprite;
import openfl.events.Event;
import screens.AccountScreen;
import screens.CharacterSelectionScreen;
import screens.ServersScreen;
import screens.TitleMenuOption;
import ui.dialogs.Dialog;
import ui.SoundIcon;
import ui.view.MapBackground;
import util.Signal;

class TitleView extends Sprite {
	public var playClicked: EmptySignal;
	public var serversClicked: EmptySignal;
	public var accountClicked: EmptySignal;
	public var editorClicked: EmptySignal;

	private var container: Sprite;
	private var playButton: TitleMenuOption;
	private var serversButton: TitleMenuOption;
	private var accountButton: TitleMenuOption;
	private var editorButton: TitleMenuOption;

	public function new() {
		super();

		addChild(new MapBackground());
		addChild(new AccountScreen());
		this.makeChildren();
		addChild(new SoundIcon());
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}

	private function onAdded(_: Event) {
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);

		#if !disable_rpc
		if (Main.rpcReady) {
			var discordPresence = DiscordRichPresence.create();
			discordPresence.state = 'Main Menu';
			discordPresence.details = '';
			discordPresence.largeImageKey = 'logo';
			discordPresence.largeImageText = 'v${Settings.BUILD_VERSION}';
			discordPresence.startTimestamp = Main.startTime;
			Discord.UpdatePresence(cpp.RawConstPointer.addressOf(discordPresence));
		}
		#end

		this.initialize();
		this.playClicked.on(handleIntentionToPlay);
		this.serversClicked.on(showServersScreen);
		this.accountClicked.on(handleIntentionToReviewAccount);
		this.editorClicked.on(showEditorScreen);
	}

	private function onRemoved(_: Event) {
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);

		this.playClicked.off(handleIntentionToPlay);
		this.serversClicked.off(showServersScreen);
		this.accountClicked.off(handleIntentionToReviewAccount);
		this.editorClicked.off(showEditorScreen);
	}

	private static function handleIntentionToPlay() {
		if (!Global.serverModel.isServerAvailable())
			Global.layers.dialogs.openDialog(new Dialog("Faer is currently offline.\n\n"
				+ "Visit our discord for more information:\n"
				+ "<font color=\"#7777EE\"><a href=\"https://discord.gg/mUPuzKtajq/\">discord.gg/mUPuzKtajq</a></font>.",
				"Server Offline", null, null));
		else {
			if (Account.password == "") {
				var data = new GameInitData();
				data.createCharacter = true;
				data.charId = Global.playerModel.getNextCharId();
				data.gameId = Settings.HUB_GAMEID;
			} else
				Global.setScreenValid(new CharacterSelectionScreen());
		}
	}

	private static function showServersScreen() {
		Global.layers.screens.setScreen(new ServersScreen());
	}

	private static function showEditorScreen() {
		Global.layers.screens.setScreen(new MapEditor());
	}

	private static function handleIntentionToReviewAccount() {
		if (Account.password != "")
			Global.layers.dialogs.openDialog(new AccountDetailDialog());
		else
			Global.layers.dialogs.openDialog(new RegisterDialog());
	}

	public function initialize() {
		this.positionButtons();
		this.addChildren();
	}

	private function makeChildren() {
		this.container = new Sprite();
		this.playButton = new TitleMenuOption("play", 36, true);
		this.playClicked = this.playButton.clicked;
		this.container.addChild(this.playButton);
		this.serversButton = new TitleMenuOption("servers", 22, false);
		this.serversClicked = this.serversButton.clicked;
		this.container.addChild(this.serversButton);
		this.accountButton = new TitleMenuOption("account", 22, false);
		this.accountClicked = this.accountButton.clicked;
		this.container.addChild(this.accountButton);
		this.editorButton = new TitleMenuOption("editor", 22, false);
		this.editorClicked = this.editorButton.clicked;
		this.container.addChild(this.editorButton);
	}

	private function addChildren() {
		addChild(this.container);
	}

	private function positionButtons() {
		this.playButton.x = stage.stageWidth / 2 - this.playButton.width / 2;
		this.playButton.y = stage.stageHeight - 80;
		this.serversButton.x = stage.stageWidth / 2 - this.serversButton.width / 2 - 94;
		this.serversButton.y = stage.stageHeight - 68;
		this.editorButton.x = stage.stageWidth / 2 - this.editorButton.width / 2 - 94 - 94;
		this.editorButton.y = stage.stageHeight - 68;
		this.accountButton.x = stage.stageWidth / 2 - this.accountButton.width / 2 + 96;
		this.accountButton.y = stage.stageHeight - 68;
	}
}
