package util;

import sound.SoundEffectLibrary;
import sound.Music;
import util.Utils.KeyCode;
import util.NativeTypes;
import sys.FileSystem;
import sys.io.File;

enum abstract GlowType(UInt8) from UInt8 to UInt8 {
	final None = 0;
	final Low = 1;
	final Medium = 2;
	final High = 3;
	final VeryHigh = 4;
}

class Settings {
	public static inline var BUILD_VERSION = "0.5";
	public static inline var BUILD_LABEL = "Faer v" + BUILD_VERSION;
	// public static inline var APP_ENGINE_URL = "http://20.31.128.28:8080";
	public static inline var APP_ENGINE_URL = "http://127.0.0.1:8080";
	public static inline var DISABLE_MAP_BG = #if hl true #else false #end;
	public static inline var FELLOW_GUILD_COLOR: UInt32 = 0xA6FF5D;
	public static inline var DEFAULT_COLOR: UInt32 = 0xFCDF00;
	public static inline var PLAYER_ROTATE_SPEED: Float32 = 0.003;
	public static inline var SERVER_CHAT_NAME = "";
	public static inline var TERMS_OF_USE_URL = "https://to.do/tos";
	public static inline var PRIVACY_POLICY_URL = "https://to.do/privacy";
	public static inline var SETTINGS_VERSION: UInt8 = 0;

	public static var moveLeft = KeyCode.A;
	public static var moveRight = KeyCode.D;
	public static var moveUp = KeyCode.W;
	public static var moveDown = KeyCode.S;
	public static var rotateLeft = KeyCode.Q;
	public static var rotateRight = KeyCode.E;
	public static var shoot = KeyCode.Mouse1;
	public static var useAbility = KeyCode.Mouse2;
	public static var interact = KeyCode.R;
	public static var goToHub = KeyCode.Tab;
	public static var chatUp = KeyCode.PageUp;
	public static var chatDown = KeyCode.PageDown;
	public static var resetCamera = KeyCode.Z;
	public static var perfStats = KeyCode.F3;
	public static var options = KeyCode.Escape;
	public static var toggleCentering = KeyCode.X;
	public static var chat = KeyCode.Enter;
	public static var chatCmd = KeyCode.Slash;
	public static var respond = KeyCode.F2;
	public static var guildChat = KeyCode.G;
	public static var switchTabs = KeyCode.B;
	public static var walk = KeyCode.Shift;
	public static var ability1 = KeyCode.Number1;
	public static var ability2 = KeyCode.Number2;
	public static var ability3 = KeyCode.Number3;
	public static var ultimateAbility = KeyCode.Number4;
	public static var playMusic = true;
	public static var playSfx = true;
	public static var playWepSfx = true;
	public static var centerCamera = true;
	public static var textBubbles = true;
	public static var selectedServer = "";
	public static var cameraAngle: Float32 = 0.0;
	public static var selectedCursor: Int8 = 3;
	public static var glowType: GlowType = GlowType.High;
	public static var savedEmail = "";
	public static var perfStatsOpen = false;

	public static var messagesSent = new Array<String>();

	public static function load() {
		try {
			if (FileSystem.exists("settings")) {
				var o = File.read("settings");
				var ver = o.readByte();
				if (ver != SETTINGS_VERSION) {
					trace("Invalid settings version. Loading default");
					o.close();

					setDefaults();
					save();
					load();
					return;
				}
				moveLeft = o.readByte();
				moveRight = o.readByte();
				moveUp = o.readByte();
				moveDown = o.readByte();
				rotateLeft = o.readByte();
				rotateRight = o.readByte();
				shoot = o.readByte();
				useAbility = o.readByte();
				interact = o.readByte();
				goToHub = o.readByte();
				chatUp = o.readByte();
				chatDown = o.readByte();
				resetCamera = o.readByte();
				perfStats = o.readByte();
				options = o.readByte();
				toggleCentering = o.readByte();
				chat = o.readByte();
				chatCmd = o.readByte();
				respond = o.readByte();
				guildChat = o.readByte();
				switchTabs = o.readByte();
				walk = o.readByte();
				playMusic = o.readByte() == 1 ? true : false;
				playSfx = o.readByte() == 1 ? true : false;
				playWepSfx = o.readByte() == 1 ? true : false;
				centerCamera = o.readByte() == 1 ? true : false;
				textBubbles = o.readByte() == 1 ? true : false;
				selectedServer = o.readString(o.readByte());
				cameraAngle = o.readFloat();
				selectedCursor = o.readByte();
				glowType = o.readByte();
				savedEmail = o.readString(o.readUInt16());
				perfStatsOpen = o.readByte() == 1 ? true : false;
				ability1 = o.readByte();
				ability2 = o.readByte();
				ability3 = o.readByte();
				ultimateAbility = o.readByte();
				o.close();
			}
		} catch (e) {
			trace('Settings load failed $e');
		}

		Music.setPlayMusic(Settings.playMusic);
		SoundEffectLibrary.setPlaySFX(Settings.playSfx);
	}

	public static function save() {
		try {
			var w = File.write("settings");
			w.writeByte(SETTINGS_VERSION);
			w.writeByte(moveLeft);
			w.writeByte(moveRight);
			w.writeByte(moveUp);
			w.writeByte(moveDown);
			w.writeByte(rotateLeft);
			w.writeByte(rotateRight);
			w.writeByte(shoot);
			w.writeByte(useAbility);
			w.writeByte(interact);
			w.writeByte(goToHub);
			w.writeByte(chatUp);
			w.writeByte(chatDown);
			w.writeByte(resetCamera);
			w.writeByte(perfStats);
			w.writeByte(options);
			w.writeByte(toggleCentering);
			w.writeByte(chat);
			w.writeByte(chatCmd);
			w.writeByte(respond);
			w.writeByte(guildChat);
			w.writeByte(switchTabs);
			w.writeByte(walk);
			w.writeByte(playMusic == true ? 1 : 0);
			w.writeByte(playSfx == true ? 1 : 0);
			w.writeByte(playWepSfx == true ? 1 : 0);
			w.writeByte(centerCamera == true ? 1 : 0);
			w.writeByte(textBubbles == true ? 1 : 0);
			w.writeByte(selectedServer.length);
			w.writeString(selectedServer);
			w.writeFloat(cameraAngle);
			w.writeByte(selectedCursor);
			w.writeByte(glowType);
			w.writeUInt16(savedEmail.length);
			w.writeString(savedEmail);
			w.writeByte(perfStatsOpen == true ? 1 : 0);
			w.writeByte(ability1);
			w.writeByte(ability2);
			w.writeByte(ability3);
			w.writeByte(ultimateAbility);
			w.close();
		} catch (e) {
			trace('Settings save failed: $e');
		}
	}

	public static function setDefaults() {
		moveLeft = KeyCode.A;
		moveRight = KeyCode.D;
		moveUp = KeyCode.W;
		moveDown = KeyCode.S;
		rotateLeft = KeyCode.Q;
		rotateRight = KeyCode.E;
		shoot = KeyCode.Mouse1;
		useAbility = KeyCode.Mouse2;
		interact = KeyCode.R;
		goToHub = KeyCode.Tab;
		chatUp = KeyCode.PageUp;
		chatDown = KeyCode.PageDown;
		resetCamera = KeyCode.Z;
		perfStats = KeyCode.F3;
		options = KeyCode.Escape;
		toggleCentering = KeyCode.X;
		chat = KeyCode.Enter;
		chatCmd = KeyCode.Slash;
		respond = KeyCode.F2;
		guildChat = KeyCode.G;
		switchTabs = KeyCode.B;
		walk = KeyCode.Shift;
		playMusic = true;
		playSfx = true;
		playWepSfx = true;
		centerCamera = true;
		selectedServer = "";
		cameraAngle = 0;
		textBubbles = true;
		selectedCursor = 3;
		glowType = GlowType.None;
		perfStatsOpen = false;
		ability1 = KeyCode.Number1;
		ability2 = KeyCode.Number2;
		ability3 = KeyCode.Number3;
		ultimateAbility = KeyCode.Number4;
		// e-mail is intentionally missing from here

		Main.refreshCursor();
	}
}
