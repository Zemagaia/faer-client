package mapeditor;
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