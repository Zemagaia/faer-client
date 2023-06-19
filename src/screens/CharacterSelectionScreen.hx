package screens;

import mapeditor.EditingScreen;
import assets.IconFactory;
import openfl.display.BitmapData;
import screens.charrects.CharacterRectList;
import ui.view.LoginView;
import account.Account;
import ui.TextButton;
import openfl.utils.Assets;
import openfl.display.Bitmap;
import ui.SoundIcon;
import lib.tasks.Task.TaskData;
#if !disable_rpc
import hxdiscord_rpc.Types;
import hxdiscord_rpc.Discord;
#end
import util.Settings;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.filters.DropShadowFilter;
import openfl.geom.Rectangle;
import ui.SimpleText;

class CharacterSelectionScreen extends Sprite {
	private static var DROP_SHADOW: DropShadowFilter = new DropShadowFilter(0, 0, 0, 1, 8, 8);

	private var selectTextBackground: Sprite;
	private var selectText: SimpleText;
	private var characterRectList: CharacterRectList;
	private var editorButton: TextButton;
	private var pageDecor: Bitmap;
	private var pageText: SimpleText;
	private var currentPage = 1;
	private var leftPageButtonBase: BitmapData;
	private var leftPageButtonHovered: BitmapData;
	private var leftPageButtonPress: BitmapData;
	private var leftPageButtonDisabled: BitmapData;
	private var leftPageButton: Bitmap;
	private var leftPageButtonHovering: Bool;
	private var leftPageButtonPressed: Bool;
	private var leftPageButtonContainer: Sprite;
	private var rightPageButtonBase: BitmapData;
	private var rightPageButtonHovered: BitmapData;
	private var rightPageButtonPress: BitmapData;
	private var rightPageButtonDisabled: BitmapData;
	private var rightPageButton: Bitmap;
	private var rightPageButtonHovering: Bool;
	private var rightPageButtonPressed: Bool;
	private var rightPageButtonContainer: Sprite;
	private var newsTextBackground: Sprite;
	private var newsText: SimpleText;
	private var newsLeftDecor: Bitmap;
	private var newsLeftText: SimpleText;
	private var newsMiddleDecor: Bitmap;
	private var newsMiddleText: SimpleText;
	private var newsRightDecor: Bitmap;
	private var newsRightText: SimpleText;
	private var gemDecor: Bitmap;
	private var gemIcon: Bitmap;
	private var gemText: SimpleText;
	private var goldDecor: Bitmap;
	private var goldIcon: Bitmap;
	private var goldText: SimpleText;
	private var loginDecor: Bitmap;
	private var guildDecor: Bitmap;
	private var loggedInAsText: SimpleText;
	private var playerNameText: SimpleText;
	private var guildText: SimpleText;
	private var logOutButton: TextButton;

	public function new() {
		super();

		addChild(Global.backgroundImage);
		addChild(new SoundIcon());

		Global.charListTask.finished.once(function(_: TaskData) {
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		});
		Global.charListTask.start();
	}

	private function onAdded(_: Event) {
		#if !disable_rpc
		if (Main.rpcReady) {
			var discordPresence = DiscordRichPresence.create();
			discordPresence.state = 'Character Select';
			discordPresence.details = '';
			discordPresence.largeImageKey = 'logo';
			discordPresence.largeImageText = 'v${Settings.BUILD_VERSION}';
			discordPresence.startTimestamp = Main.startTime;
			Discord.UpdatePresence(cpp.RawConstPointer.addressOf(discordPresence));
		}
		#end

		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);

		var scale9Base = Assets.getBitmapData("assets/ui/screens/charSelect/titleTextBackground.png");

		this.selectTextBackground = new Sprite();
		this.selectTextBackground.graphics.beginBitmapFill(scale9Base);
		this.selectTextBackground.graphics.drawRect(0, 0, scale9Base.width, scale9Base.height);
		this.selectTextBackground.graphics.endFill();
		this.selectTextBackground.scale9Grid = new Rectangle(5, 5, 38, 38);
		addChild(this.selectTextBackground);

		this.selectText = new SimpleText(22, 0xB3B3B3);
		this.selectText.setText("Select a Character");
		this.selectText.setBold(true);
		this.selectText.updateMetrics();
		this.selectText.x = (Main.stageWidth - this.selectText.width) / 2;
		this.selectText.y = 40;
		addChild(this.selectText);

		this.selectTextBackground.x = this.selectText.x - 10;
		this.selectTextBackground.y = this.selectText.y - 5;
		this.selectTextBackground.width = this.selectText.width + 20;
		this.selectTextBackground.height = this.selectText.height + 10;

		this.characterRectList = new CharacterRectList();
		this.characterRectList.x = (Main.stageWidth - 1000) / 2;
		this.characterRectList.y = 80;
		addChild(this.characterRectList);

		if (Global.playerModel.isAdmin()) {
			this.editorButton = new TextButton(22, "Editor");
			this.editorButton.addEventListener(MouseEvent.CLICK, this.onEditorClicked);
			this.editorButton.x = this.characterRectList.x + this.characterRectList.width - this.editorButton.width;
			this.editorButton.y = 425;
			addChild(this.editorButton);
		}	

		this.goldDecor = new Bitmap(Assets.getBitmapData("assets/ui/screens/charSelect/currencyAndGuildViewer.png"));
		this.goldDecor.x = this.characterRectList.x;
		this.goldDecor.y = 35;
		addChild(this.goldDecor);

		this.goldIcon = new Bitmap(IconFactory.makeGold());
		this.goldIcon.x = this.goldDecor.x + (32 - this.goldIcon.width) / 2 + 4;
		this.goldIcon.y = this.goldDecor.y + (32 - this.goldIcon.height) / 2 + 4;
		addChild(this.goldIcon); 

		this.goldText = new SimpleText(22, 0xB3B3B3);
		this.goldText.setText(Std.string(Global.playerModel.getGold()));
		this.goldText.setBold(true);
		this.goldText.updateMetrics();
		this.goldText.x = this.goldDecor.x + (102 - this.goldText.width) / 2 + 47;
		this.goldText.y = this.goldDecor.y + (26 - this.goldText.height) / 2 + 7;
		addChild(this.goldText);

		this.gemDecor = new Bitmap(Assets.getBitmapData("assets/ui/screens/charSelect/currencyAndGuildViewer.png"));
		this.gemDecor.x = this.characterRectList.x + this.characterRectList.width - this.gemDecor.width;
		this.gemDecor.y = 35;
		addChild(this.gemDecor);

		this.gemIcon = new Bitmap(IconFactory.makeGems());
		this.gemIcon.x = this.gemDecor.x + (32 - this.gemIcon.width) / 2 + 4;
		this.gemIcon.y = this.gemDecor.y + (32 - this.gemIcon.height) / 2 + 4;
		addChild(this.gemIcon);

		this.gemText = new SimpleText(22, 0xB3B3B3);
		this.gemText.setText(Std.string(Global.playerModel.getGems()));
		this.gemText.setBold(true);
		this.gemText.updateMetrics();
		this.gemText.x = this.gemDecor.x + (102 - this.gemText.width) / 2 + 47;
		this.gemText.y = this.gemDecor.y + (26 - this.gemText.height) / 2 + 7;
		addChild(this.gemText);

		var pages = Std.int(this.characterRectList.count / 15) + 1;
		if (pages > 1) {
			this.pageDecor = new Bitmap(Assets.getBitmapData("assets/ui/screens/charSelect/characterBoxPageFlipper.png"));
			this.pageDecor.x = (Main.stageWidth - this.pageDecor.width) / 2;
			this.pageDecor.y = 425;
			addChild(this.pageDecor);

			this.pageText = new SimpleText(18, 0xB3B3B3);
			this.pageText.setText('${this.currentPage}/$pages');
			this.pageText.setBold(true);
			this.pageText.updateMetrics();
			this.pageText.x = this.pageDecor.x + 47 + (70 - this.pageText.width) / 2;
			this.pageText.y = this.pageDecor.y + 7 + (26 - this.pageText.height) / 2;
			addChild(this.pageText);

			this.leftPageButtonBase = Assets.getBitmapData("assets/ui/elements/flipperButtonLeft.png");
			this.leftPageButtonHovered = Assets.getBitmapData("assets/ui/elements/flipperButtonLeftHover.png");
			this.leftPageButtonPress = Assets.getBitmapData("assets/ui/elements/flipperButtonLeftPress.png");
			this.leftPageButtonDisabled = Assets.getBitmapData("assets/ui/elements/flipperButtonLeftDisabled.png");

			this.leftPageButton = new Bitmap(this.currentPage == 1 ? this.leftPageButtonDisabled : this.leftPageButtonBase);
			this.leftPageButtonContainer = new Sprite();
			this.leftPageButtonContainer.x = this.pageDecor.x + 4;
			this.leftPageButtonContainer.y = this.pageDecor.y + 4;
			this.leftPageButtonContainer.addChild(this.leftPageButton);
			this.leftPageButtonContainer.addEventListener(MouseEvent.ROLL_OVER, this.onLeftPageRollOver);
			this.leftPageButtonContainer.addEventListener(MouseEvent.ROLL_OUT, this.onLeftPageRollOut);
			this.leftPageButtonContainer.addEventListener(MouseEvent.MOUSE_DOWN, this.onLeftPageMouseDown);
			this.leftPageButtonContainer.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, this.onLeftPageMouseDown);
			this.leftPageButtonContainer.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, this.onLeftPageMouseDown);
			this.leftPageButtonContainer.addEventListener(MouseEvent.MOUSE_UP, this.onLeftPageMouseUp);
			this.leftPageButtonContainer.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, this.onLeftPageMouseUp);
			this.leftPageButtonContainer.addEventListener(MouseEvent.RIGHT_MOUSE_UP, this.onLeftPageMouseUp);
			addChild(this.leftPageButtonContainer);

			this.rightPageButtonBase = Assets.getBitmapData("assets/ui/elements/flipperButtonRight.png");
			this.rightPageButtonHovered = Assets.getBitmapData("assets/ui/elements/flipperButtonRightHover.png");
			this.rightPageButtonPress = Assets.getBitmapData("assets/ui/elements/flipperButtonRightPress.png");
			this.rightPageButtonDisabled = Assets.getBitmapData("assets/ui/elements/flipperButtonRightDisabled.png");

			this.rightPageButton = new Bitmap(this.currentPage >= pages ? this.rightPageButtonDisabled : this.rightPageButtonBase);
			this.rightPageButtonContainer = new Sprite();
			this.rightPageButtonContainer.x = this.pageDecor.x + 128;
			this.rightPageButtonContainer.y = this.pageDecor.y + 4;
			this.rightPageButtonContainer.addChild(this.rightPageButton);
			this.rightPageButtonContainer.addEventListener(MouseEvent.ROLL_OVER, this.onRightPageRollOver);
			this.rightPageButtonContainer.addEventListener(MouseEvent.ROLL_OUT, this.onRightPageRollOut);
			this.rightPageButtonContainer.addEventListener(MouseEvent.MOUSE_DOWN, this.onRightPageMouseDown);
			this.rightPageButtonContainer.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, this.onRightPageMouseDown);
			this.rightPageButtonContainer.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, this.onRightPageMouseDown);
			this.rightPageButtonContainer.addEventListener(MouseEvent.MOUSE_UP, this.onRightPageMouseUp);
			this.rightPageButtonContainer.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, this.onRightPageMouseUp);
			this.rightPageButtonContainer.addEventListener(MouseEvent.RIGHT_MOUSE_UP, this.onRightPageMouseUp);
			addChild(this.rightPageButtonContainer);
		}

		this.newsTextBackground = new Sprite();
		this.newsTextBackground.graphics.beginBitmapFill(scale9Base);
		this.newsTextBackground.graphics.drawRect(0, 0, scale9Base.width, scale9Base.height);
		this.newsTextBackground.graphics.endFill();
		this.newsTextBackground.scale9Grid = new Rectangle(5, 5, 38, 38);
		addChild(this.newsTextBackground);

		this.newsText = new SimpleText(22, 0xB3B3B3);
		this.newsText.setText("News");
		this.newsText.setBold(true);
		this.newsText.updateMetrics();
		this.newsText.x = (Main.stageWidth - this.newsText.width) / 2;
		this.newsText.y = Main.stageHeight - 240;
		addChild(this.newsText);

		this.newsLeftDecor = new Bitmap(Assets.getBitmapData("assets/ui/screens/charSelect/newsBoxSecondary.png"));
		this.newsLeftDecor.x = (Main.stageWidth - 860) / 2;
		this.newsLeftDecor.y = this.newsText.y + this.newsText.height;
		addChild(this.newsLeftDecor);

		this.newsMiddleDecor = new Bitmap(Assets.getBitmapData("assets/ui/screens/charSelect/newsBoxMain.png"));
		this.newsMiddleDecor.x = (Main.stageWidth - 860) / 2 + 268;
		this.newsMiddleDecor.y = this.newsText.y + this.newsText.height;
		addChild(this.newsMiddleDecor);

		this.newsRightDecor = new Bitmap(Assets.getBitmapData("assets/ui/screens/charSelect/newsBoxSecondary.png"));
		this.newsRightDecor.x = (Main.stageWidth - 860) / 2 + 268 + 324;
		this.newsRightDecor.y = this.newsText.y + this.newsText.height;
		addChild(this.newsRightDecor);

		this.newsTextBackground.x = this.newsText.x - 10;
		this.newsTextBackground.y = this.newsText.y - 5;
		this.newsTextBackground.width = this.newsText.width + 20;
		this.newsTextBackground.height = this.newsText.height + 10;

		this.loginDecor = new Bitmap(Assets.getBitmapData("assets/ui/screens/charSelect/loginView.png"));
		this.loginDecor.x = 5;
		this.loginDecor.y = Main.stageHeight - this.loginDecor.height - 5;
		addChild(this.loginDecor);

		this.guildDecor = new Bitmap(Assets.getBitmapData("assets/ui/screens/charSelect/currencyAndGuildViewer.png"));
		this.guildDecor.x = this.loginDecor.x + 7;
		this.guildDecor.y = this.loginDecor.y + 115;
		addChild(this.guildDecor);

		this.loggedInAsText = new SimpleText(18, 0xB3B3B3);
		this.loggedInAsText.setText("Logged in as:");
		this.loggedInAsText.updateMetrics();
		this.loggedInAsText.x = this.loginDecor.x + (this.loginDecor.width - this.loggedInAsText.width) / 2;
		this.loggedInAsText.y = this.loginDecor.y + (32 - this.loggedInAsText.height) / 2 + 18;
		addChild(this.loggedInAsText);

		this.playerNameText = new SimpleText(22, 0xB3B3B3);
		this.playerNameText.setText(Account.userName);
		this.playerNameText.updateMetrics();
		this.playerNameText.x = this.loginDecor.x + (this.loginDecor.width - this.playerNameText.width) / 2;
		this.playerNameText.y = this.loginDecor.y + (50 - this.playerNameText.height) / 2 + 62;
		addChild(this.playerNameText);

		this.guildText = new SimpleText(16, 0xB3B3B3);
		this.guildText.setText(Global.playerModel.getGuildName());
		this.guildText.updateMetrics();
		this.guildText.x = this.loginDecor.x + (this.loginDecor.width - this.guildText.width + 40) / 2;
		this.guildText.y = this.loginDecor.y + (26 - this.guildText.height) / 2 + 115 + 8;
		addChild(this.guildText);

		this.logOutButton = new TextButton(22, "Log Out", 156, 52);
		this.logOutButton.x = this.loginDecor.x + (this.loginDecor.width - this.logOutButton.width) / 2;
		this.logOutButton.y = this.loginDecor.y + (52 - this.logOutButton.height) / 2 + 157;
		this.logOutButton.addEventListener(MouseEvent.CLICK, this.onLogOutClicked);
		addChild(this.logOutButton);
	}

	private function onLogOutClicked(_: MouseEvent) {
		Account.clear();
		Global.layers.screens.setScreen(new LoginView());
	}

	private function onEditorClicked(_: MouseEvent) {
		Global.layers.screens.setScreen(new EditingScreen());
	}

	private function onLeftPageMouseDown(_: MouseEvent) {
		if (this.currentPage == 1)
			return;

		this.leftPageButtonPressed = true;

		this.leftPageButton.bitmapData = this.leftPageButtonPress;
	}

	private function onLeftPageMouseUp(_: MouseEvent) {
		if (this.currentPage == 1)
			return;

		this.leftPageButtonPressed = false;

		this.currentPage--;
		this.characterRectList.updateBoxes(this.currentPage);

		if (this.currentPage == 1)
			this.leftPageButton.bitmapData = this.leftPageButtonDisabled;
		else
			this.leftPageButton.bitmapData = this.leftPageButtonHovering ? this.leftPageButtonHovered : this.leftPageButtonBase;

		this.rightPageButton.bitmapData = this.rightPageButtonBase;

		var pages = Std.int(this.characterRectList.count / 15) + 1;
		this.pageText.setText('${this.currentPage}/$pages');
		this.pageText.updateMetrics();
		this.pageText.x = this.pageDecor.x + 47 + (70 - this.pageText.width) / 2;
		this.pageText.y = this.pageDecor.y + 7 + (26 - this.pageText.height) / 2;
	}

	private function onLeftPageRollOver(_: MouseEvent) {
		if (this.currentPage == 1)
			return;

		this.leftPageButtonHovering = true;

		this.leftPageButton.bitmapData = this.leftPageButtonHovered;
	}

	private function onLeftPageRollOut(_: MouseEvent) {
		if (this.currentPage == 1)
			return;

		this.leftPageButtonHovering = false;

		this.leftPageButton.bitmapData = this.leftPageButtonPressed ? this.leftPageButtonPress : this.leftPageButtonBase;
	}

	private function onRightPageMouseDown(_: MouseEvent) {
		var pages = Std.int(this.characterRectList.count / 15) + 1;
		if (this.currentPage >= pages)
			return;

		this.rightPageButtonPressed = true;

		this.rightPageButton.bitmapData = this.rightPageButtonPress;
	}

	private function onRightPageMouseUp(_: MouseEvent) {
		var pages = Std.int(this.characterRectList.count / 15) + 1;
		if (this.currentPage >= pages)
			return;

		this.rightPageButtonPressed = false;

		this.currentPage++;
		this.characterRectList.updateBoxes(this.currentPage);

		if (this.currentPage >= pages)
			this.rightPageButton.bitmapData = this.rightPageButtonDisabled;
		else
			this.rightPageButton.bitmapData = this.rightPageButtonHovering ? this.rightPageButtonHovered : this.rightPageButtonBase;

		this.leftPageButton.bitmapData = this.leftPageButtonBase;

		this.pageText.setText('${this.currentPage}/$pages');
		this.pageText.updateMetrics();
		this.pageText.x = this.pageDecor.x + 47 + (70 - this.pageText.width) / 2;
		this.pageText.y = this.pageDecor.y + 7 + (26 - this.pageText.height) / 2;
	}

	private function onRightPageRollOver(_: MouseEvent) {
		var pages = Std.int(this.characterRectList.count / 15) + 1;
		if (this.currentPage >= pages)
			return;

		this.rightPageButtonHovering = true;

		this.rightPageButton.bitmapData = this.rightPageButtonHovered;
	}

	private function onRightPageRollOut(_: MouseEvent) {
		var pages = Std.int(this.characterRectList.count / 15) + 1;
		if (this.currentPage >= pages)
			return;

		this.rightPageButtonHovering = false;

		this.rightPageButton.bitmapData = this.rightPageButtonPressed ? this.rightPageButtonPress : this.rightPageButtonBase;
	}

	private function onRemoved(_: Event) {
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
	}
}
