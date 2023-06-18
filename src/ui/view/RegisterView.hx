package ui.view;

import ui.dialogs.Dialog;
import screens.CharacterSelectionScreen;
import tasks.RegisterAccountTask;
import account.AccountData;
import lib.tasks.Task.TaskData;
import openfl.events.MouseEvent;
import openfl.text.TextFormatAlign;
import openfl.Assets;
import openfl.display.Bitmap;
import hxdiscord_rpc.Discord;
import util.Settings;
import hxdiscord_rpc.Types.DiscordRichPresence;
import openfl.events.Event;
import openfl.display.Sprite;
import openfl.filters.DropShadowFilter;

class RegisterView extends Sprite {
	private var logo: Bitmap;
	private var nameInput: TextInputField;
	private var emailInput: TextInputField;
	private var passwordInput: TextInputField;
	private var passwordConfirmInput: TextInputField;
	private var loginButton: TextButton;
	private var registerButton: TextButton;
	private var versionText: SimpleText;
	private var copyrightText: SimpleText;

	public function new() {
		super();

		addChild(Global.backgroundImage);
		addChild(new SoundIcon());
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}

	private function onAdded(_: Event) {
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);

		#if !disable_rpc
		if (Main.rpcReady) {
			var discordPresence = DiscordRichPresence.create();
			discordPresence.state = 'Register Screen';
			discordPresence.details = '';
			discordPresence.largeImageKey = 'logo';
			discordPresence.largeImageText = 'v${Settings.BUILD_VERSION}';
			discordPresence.startTimestamp = Main.startTime;
			Discord.UpdatePresence(cpp.RawConstPointer.addressOf(discordPresence));
		}
		#end

		this.logo = new Bitmap(Assets.getBitmapData("assets/ui/faerLogo.png"));
		this.logo.x = (Main.stageWidth - this.logo.width) / 2;
		this.logo.y = 30;
		addChild(this.logo);

		this.nameInput = new TextInputField("Username", false, "");
		this.nameInput.x = (Main.stageWidth - this.nameInput.width) / 2;
		this.nameInput.y = 200;
		addChild(this.nameInput);

		this.emailInput = new TextInputField("E-mail", false, "");
		this.emailInput.x = (Main.stageWidth - this.emailInput.width) / 2;
		this.emailInput.y = 300;
		addChild(this.emailInput);

		this.passwordInput = new TextInputField("Password", true, "");
		this.passwordInput.x = (Main.stageWidth - this.passwordInput.width) / 2;
		this.passwordInput.y = 400;
		addChild(this.passwordInput);

		this.passwordConfirmInput = new TextInputField("Confirm Password", true, "");
		this.passwordConfirmInput.x = (Main.stageWidth - this.passwordConfirmInput.width) / 2;
		this.passwordConfirmInput.y = 500;
		addChild(this.passwordConfirmInput);

		this.loginButton = new TextButton(22, "Login");
		this.loginButton.addEventListener(MouseEvent.CLICK, this.onLoginClick);
		this.loginButton.y = 600;
		addChild(this.loginButton);

		this.registerButton = new TextButton(22, "Register");
		this.registerButton.addEventListener(MouseEvent.CLICK, this.onRegisterClick);
		this.registerButton.y = 600;
		addChild(this.registerButton);

		var combinedWidth = this.loginButton.width + this.registerButton.width + 20; // pad
		this.loginButton.x = (Main.stageWidth - combinedWidth) / 2;
		this.registerButton.x = Main.stageWidth / 2;

		this.versionText = new SimpleText(16, 0xB3B3B3);
		this.versionText.filters = [new DropShadowFilter(0, 0, 0)];
		this.versionText.setText('Release v${Settings.BUILD_VERSION}\nJune 2023'); // todo build date macro
		this.versionText.updateMetrics();
		this.versionText.x = 5;
		this.versionText.y = Main.stageHeight - this.versionText.height;
		addChild(this.versionText);

		this.copyrightText = new SimpleText(16, 0xB3B3B3);
		this.copyrightText.filters = [new DropShadowFilter(0, 0, 0)];
		this.copyrightText.setAlignment(TextFormatAlign.RIGHT);
		this.copyrightText.setText('© Faer 2023\nAll rights reserved.');
		this.copyrightText.updateMetrics();
		this.copyrightText.x = Main.stageWidth - this.copyrightText.width - 5;
		this.copyrightText.y = Main.stageHeight - this.copyrightText.height;
		addChild(this.copyrightText);
	}

	private function isNameValid() {
		var isValid = this.nameInput.text() != "";
		if (!isValid)
			this.nameInput.setError("Not a valid name");

		return isValid;
	}

	private function isPasswordValid() {
		var isValid = this.passwordInput.text() != "";
		if (!isValid)
			this.passwordInput.setError("Password too short");

		isValid = this.passwordInput.text() == this.passwordConfirmInput.text();
		if (!isValid)
			this.passwordInput.setError("Passwords don't match");

		return isValid;
	}

	private function isEmailValid() {
		var isValid = this.emailInput.text() != "";
		if (!isValid)
			this.emailInput.setError("Not a valid email address");

		return isValid;
	}

	private function onLoginClick(_: MouseEvent) {
		Global.layers.screens.setScreen(new LoginView());
	}

	private function onRegisterClick(_: MouseEvent) {
		if (this.isNameValid() && this.isEmailValid() && this.isPasswordValid()) {
			RegisterAccountTask.accountData = new AccountData();
			RegisterAccountTask.accountData.userName = this.nameInput.text();
			RegisterAccountTask.accountData.email = this.emailInput.text();
			RegisterAccountTask.accountData.password = this.passwordInput.text();

			Global.registerAccountTask.finished.once(function(td: TaskData) {
				if (td.result != "EOF" && td.result.indexOf("Error") == -1)
					Global.layers.screens.setScreen(new CharacterSelectionScreen());
				else
					Global.layers.dialogs.openDialog(new Dialog(td.result, "Error"));
			});
			Global.registerAccountTask.start();
		}
	}

	private function onRemoved(_: Event) {
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);

		if (contains(this.logo))
			removeChild(this.logo);
		this.logo = null;

		if (contains(this.emailInput))
			removeChild(this.emailInput);
		this.emailInput = null;

		if (contains(this.passwordInput))
			removeChild(this.passwordInput);
		this.passwordInput = null;

		if (contains(this.loginButton))
			removeChild(this.loginButton);
		this.loginButton.removeEventListener(MouseEvent.CLICK, this.onLoginClick);
		this.loginButton = null;

		if (contains(this.registerButton))
			removeChild(this.registerButton);
		this.registerButton.removeEventListener(MouseEvent.CLICK, this.onRegisterClick);
		this.registerButton = null;

		if (contains(this.versionText))
			removeChild(this.versionText);
		this.versionText = null;

		if (contains(this.copyrightText))
			removeChild(this.copyrightText);
		this.copyrightText = null;
	}
}
