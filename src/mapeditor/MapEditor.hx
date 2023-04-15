package mapeditor;
import util.Settings;
import discord_rpc.DiscordRpc;
import servers.Server;
import core.PlayerModel;
import openfl.display.Sprite;
import openfl.events.Event;

class MapEditor extends Sprite {
	private var model: PlayerModel;
	private var server: Server;
	private var editingScreen: EditingScreen;

	public function new() {
		super();

		this.editingScreen = new EditingScreen();
		addChild(this.editingScreen);

		if (Main.rpcReady)
			DiscordRpc.presence({
				details: 'Map Editor',
				state: '',
				largeImageKey: 'logo',
				largeImageText: 'v${Settings.BUILD_VERSION}',
				startTimestamp: Main.startTime
			});
	}

	public function initialize(model: PlayerModel, server: Server) {
		this.model = model;
		this.server = server;
	}

	private function onMapTestDone(event: Event) {
		addChild(this.editingScreen);
	}

	private function onClientUpdate(event: Event) {
		addChild(this.editingScreen);
	}
}