package screens;

import ui.SoundIcon;
import ui.ClickableText;
import appengine.RequestHandler;
import appengine.RequestHandler.CompletionData;
import lib.tasks.Task.TaskData;
#if !disable_rpc
import hxdiscord_rpc.Types;
import hxdiscord_rpc.Discord;
#end
import util.Settings;
import appengine.SavedCharacter;
import classes.model.CharacterClass;
import game.model.GameInitData;
import game.view.CurrencyDisplay;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.filters.DropShadowFilter;
import openfl.geom.Rectangle;
import ui.Scrollbar;
import ui.SimpleText;
import ui.view.ScreenBase;

class CharacterSelectionScreen extends Sprite {
	private static var DROP_SHADOW: DropShadowFilter = new DropShadowFilter(0, 0, 0, 1, 8, 8);

	private var nameText: SimpleText;
	private var currencyDisplay: CurrencyDisplay;
	private var characterList: CharacterList;
	private var characterListHeight = 0.0;
	private var playButton: ClickableText;
	private var classesButton: ClickableText;
	private var scrollBar: Scrollbar;

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


	}

	private function onRemoved(_: Event) {
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
	}
}