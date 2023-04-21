package mapeditor;

import ui.TextInputField;
import haxe.display.Server.ModuleId;
import util.Stack;
import haxe.ds.GenericStack;
import game.model.GameInitData;
import haxe.Exception;
import map.RegionLibrary;
import objects.ObjectLibrary;
import map.GroundLibrary;
import haxe.format.JsonParser;
import openfl.utils.ByteArray;
import openfl.geom.Rectangle;
import openfl.utils.Object;
import haxe.format.JsonPrinter;
import haxe.crypto.Base64;
import util.NativeTypes;
import haxe.ValueException;
import ui.dropdown.DropDown;
import screens.AccountScreen;
import ui.view.ScreenBase;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;
import openfl.net.FileReference;

@:structInit
class FillData {
	public var x1: Int;
	public var x2: Int;
	public var y1: Int;
	public var y2: Int;
}

class EditingScreen extends Sprite {
	public var commandMenu: MECommandMenu;
	public var meMap: MEMap;
	public var infoPane: InfoPane;
	public var brushSize: TextInputField;
	public var randomChance: TextInputField;
	public var chooserDropDown: DropDown;
	public var groundChooser: GroundChooser;
	public var objChooser: ObjectChooser;
	public var regionChooser: RegionChooser;
	public var chooser: Chooser;

	private var commandQueue: CommandQueue;
	private var loadedFile: FileReference = null;

	public function new() {
		super();

		addChild(new ScreenBase());
		addChild(new AccountScreen());

		this.brushSize = new TextInputField("Brush Size", false, "");
		this.brushSize.inputText.text = "0.5";
		this.brushSize.x = Main.stageWidth / 2 - MEMap.WIDTH / 2;
		this.brushSize.y = Main.stageHeight - MEMap.HEIGHT - 10 - 70;
		addChild(this.brushSize);

		this.randomChance = new TextInputField("Random Chance", false, "");
		this.randomChance.inputText.text = "0.05";
		this.randomChance.x = Main.stageWidth / 2 - MEMap.WIDTH / 2 + 250;
		this.randomChance.y = Main.stageHeight - MEMap.HEIGHT - 10 - 70;
		addChild(this.randomChance);

		this.commandMenu = new MECommandMenu();
		this.commandMenu.x = 15;
		this.commandMenu.y = Main.stageHeight - MEMap.HEIGHT - 10;
		this.commandMenu.addEventListener(CommandEvent.UNDO_COMMAND_EVENT, this.onUndo);
		this.commandMenu.addEventListener(CommandEvent.REDO_COMMAND_EVENT, this.onRedo);
		this.commandMenu.addEventListener(CommandEvent.CLEAR_COMMAND_EVENT, this.onClear);
		this.commandMenu.addEventListener(CommandEvent.LOAD_COMMAND_EVENT, this.onLoad);
		this.commandMenu.addEventListener(CommandEvent.SAVE_COMMAND_EVENT, this.onSave);
		this.commandMenu.addEventListener(CommandEvent.TEST_COMMAND_EVENT, this.onTest);
		addChild(this.commandMenu);

		this.commandQueue = new CommandQueue();
		this.meMap = new MEMap(this);
		this.meMap.addEventListener(TilesEvent.TILES_EVENT, this.editTiles);
		this.meMap.x = Main.stageWidth / 2 - MEMap.WIDTH / 2;
		this.meMap.y = Main.stageHeight - MEMap.HEIGHT - 10;
		addChild(this.meMap);

		this.infoPane = new InfoPane(this.meMap);
		this.infoPane.x = 4;
		this.infoPane.y = Main.stageHeight - InfoPane.HEIGHT - 10;
		addChild(this.infoPane);

		this.chooserDropDown = new DropDown(["Ground", "Objects", "Regions"], Chooser.WIDTH, 26);
		this.chooserDropDown.x = this.meMap.x + MEMap.WIDTH + 4;
		this.chooserDropDown.y = Main.stageHeight - MEMap.HEIGHT - 10;
		this.chooserDropDown.addEventListener(Event.CHANGE, this.onDropDownChange);
		addChild(this.chooserDropDown);

		this.groundChooser = new GroundChooser();
		this.groundChooser.x = this.chooserDropDown.x;
		this.groundChooser.y = this.chooserDropDown.y + this.chooserDropDown.height + 4;
		this.chooser = this.groundChooser;
		addChild(this.groundChooser);

		this.objChooser = new ObjectChooser();
		this.objChooser.x = this.chooserDropDown.x;
		this.objChooser.y = this.chooserDropDown.y + this.chooserDropDown.height + 4;

		this.regionChooser = new RegionChooser();
		this.regionChooser.x = this.chooserDropDown.x;
		this.regionChooser.y = this.chooserDropDown.y + this.chooserDropDown.height + 4;
	}

	private function ipArrContains(arr: Array<IntPoint>, x: Int, y: Int) {
		for (ip in arr)
			if (ip.x == x && ip.y == y)
				return true;

		return false;
	}

	private function inRadius(cX: Float, cY: Float, x: Float, y: Float, radius: Float) {
		var dx = cX - x, dy = cY - y;
		return Math.sqrt(dx * dx + dy * dy) <= radius;
	}

	public function editTiles(tiles: Array<IntPoint>) {
		switch (this.commandMenu.getCommand()) {
			case MECommandMenu.FILL_COMMAND:
				var tile = tiles[0];
				var currType = this.meMap.getType(tile.x, tile.y, this.chooser.layer);
				var selType = this.chooser.selectedType();
				if ((this.chooser.layer == Layer.GROUND || this.chooser.layer == Layer.OBJECT)
					&& selType == 65535
					|| this.chooser.layer == Layer.REGION
					&& selType == 255)
					return;

				var tiles: Array<IntPoint> = [];
				var stack = new Stack<FillData>();
				stack.add({
					x1: tile.x,
					x2: tile.x,
					y1: tile.y,
					y2: 1
				});
				stack.add({
					x1: tile.x,
					x2: tile.x,
					y1: tile.y - 1,
					y2: -1
				});
				while (!stack.isEmpty()) {
					var pop = stack.pop();
					var x = pop.x1;
					var y = pop.y1;
					if (!this.ipArrContains(tiles, x, y) && this.meMap.getType(x, y, this.chooser.layer) == currType)
						while (!this.ipArrContains(tiles, x - 1, y) && this.meMap.getType(x - 1, y, this.chooser.layer) == currType) {
							tiles.push(new IntPoint(x - 1, y));
							x--;
						}

					if (x < pop.x1)
						stack.add({
							x1: x,
							x2: pop.x1 - 1,
							y1: y - pop.y2,
							y2: -pop.y2
						});

					var x1 = pop.x1;
					var x2 = pop.x2;
					while (x1 <= x2) {
						while (!this.ipArrContains(tiles, x1, y) && this.meMap.getType(x1, y, this.chooser.layer) == currType) {
							tiles.push(new IntPoint(x1, y));
							x1++;
							stack.add({
								x1: x,
								x2: x1 - 1,
								y1: y + pop.y2,
								y2: pop.y2
							});
							if (x1 - 1 > pop.y2)
								stack.add({
									x1: x2 + 1,
									x2: x1 - 1,
									y1: y - pop.y2,
									y2: -pop.y2
								});
						}
						x1++;
						while (x1 < x2 && !this.ipArrContains(tiles, x1, y) && this.meMap.getType(x1, y, this.chooser.layer) != currType)
							x1++;
						x = x1;
					}
				}

				this.addModifyCommandList(tiles, this.chooser.layer, selType);
			case MECommandMenu.RANDOM_COMMAND:
				var modTiles: Array<IntPoint> = [];
				var chance = Std.parseFloat(this.randomChance.text());
				for (ip in tiles)
					if (Math.random() < chance)
						modTiles.push(ip);
				this.addModifyCommandList(modTiles, this.chooser.layer, this.chooser.selectedType());
			case MECommandMenu.DRAW_COMMAND:
				if (tiles.length == 1) {
					var modTiles: Array<IntPoint> = [];
					var cX = tiles[0].x, cY = tiles[0].y;
					var radius = Std.parseFloat(this.brushSize.text());
					for (y in Math.floor(cY - radius)...Math.ceil(cY + radius))
						for (x in Math.floor(cX - radius)...Math.ceil(cX + radius))
							if (this.inRadius(cX, cY, x, y, radius))
								modTiles.push({x: x, y: y});
					this.addModifyCommandList(modTiles, this.chooser.layer, this.chooser.selectedType());
				} else
					this.addModifyCommandList(tiles, this.chooser.layer, this.chooser.selectedType());
			case MECommandMenu.ERASE_COMMAND:
				if (tiles.length == 1) {
					var modTiles: Array<IntPoint> = [];
					var cX = tiles[0].x, cY = tiles[0].y;
					var radius = Std.parseFloat(this.brushSize.text());
					for (y in Math.floor(cY - radius)...Math.ceil(cY + radius))
						for (x in Math.floor(cX - radius)...Math.ceil(cX + radius))
							if (this.inRadius(cX, cY, x, y, radius))
								modTiles.push({x: x, y: y});
					this.addModifyCommandList(modTiles, this.chooser.layer, this.chooser.layer == Layer.REGION ? 255 : 65535);
				} else
					this.addModifyCommandList(tiles, this.chooser.layer, this.chooser.layer == Layer.REGION ? 255 : 65535);
			case MECommandMenu.SAMPLE_COMMAND:
				var tile = tiles[0];
				var type = this.meMap.getType(tile.x, tile.y, this.chooser.layer);
				if ((this.chooser.layer == Layer.GROUND || this.chooser.layer == Layer.OBJECT)
					&& type == 65535
					|| this.chooser.layer == Layer.REGION
					&& type == 255)
					return;

				this.chooser.setSelectedType(type);
				this.commandMenu.setCommand(MECommandMenu.DRAW_COMMAND);
		}
		this.meMap.draw();
	}

	private function onEditComplete(event: Event) {
		var props = cast(event.currentTarget, EditTileProperties);
		this.addObjectNameCommandList(props.tiles, props.getObjectName());
	}

	private function addModifyCommandList(tiles: Array<IntPoint>, layer: Int, type: Int) {
		var oldType = 0;
		var commandList: CommandList = new CommandList();
		for (tile in tiles) {
			oldType = this.meMap.getType(tile.x, tile.y, layer);
			if (oldType != type)
				commandList.addCommand(new MEModifyCommand(this.meMap, tile.x, tile.y, layer, oldType, type));
		}

		if (commandList.empty())
			return;

		this.commandQueue.addCommandList(commandList);
	}

	private function addObjectNameCommandList(tiles: Array<IntPoint>, objName: String) {
		var oldName: String = null;
		var commandList: CommandList = new CommandList();
		for (tile in tiles) {
			oldName = this.meMap.getObjectName(tile.x, tile.y);
			if (oldName != objName)
				commandList.addCommand(new MEObjectNameCommand(this.meMap, tile.x, tile.y, oldName, objName));
		}

		if (commandList.empty())
			return;

		this.commandQueue.addCommandList(commandList);
	}

	private function onDropDownChange(event: Event) {
		switch (this.chooserDropDown.getValue()) {
			case "Ground":
				if (!contains(this.groundChooser))
					addChild(this.groundChooser);
				if (contains(this.objChooser))
					removeChild(this.objChooser);
				if (contains(this.regionChooser))
					removeChild(this.regionChooser);
				this.chooser = this.groundChooser;
			case "Objects":
				if (!contains(this.objChooser))
					addChild(this.objChooser);
				if (contains(this.groundChooser))
					removeChild(this.groundChooser);
				if (contains(this.regionChooser))
					removeChild(this.regionChooser);
				this.chooser = this.objChooser;
			case "Regions":
				if (!contains(this.regionChooser))
					addChild(this.regionChooser);
				if (contains(this.groundChooser))
					removeChild(this.groundChooser);
				if (contains(this.objChooser))
					removeChild(this.objChooser);
				this.chooser = this.regionChooser;
		}
	}

	private function onUndo(event: CommandEvent) {
		this.commandQueue.undo();
		this.meMap.draw();
	}

	private function onRedo(event: CommandEvent) {
		this.commandQueue.redo();
		this.meMap.draw();
	}

	private function onClear(event: CommandEvent) {
		var oldTile: METile = null;
		var tiles = this.meMap.getAllTiles();
		var commandList: CommandList = new CommandList();
		for (tile in tiles) {
			oldTile = this.meMap.getTile(tile.x, tile.y);
			if (oldTile != null)
				commandList.addCommand(new MEClearCommand(this.meMap, tile.x, tile.y, oldTile));
		}

		if (commandList.empty())
			return;

		this.commandQueue.addCommandList(commandList);
		this.meMap.draw();
	}

	private function createMap() {
		var bounds: Rectangle = this.meMap.getTileBounds();
		if (bounds == null)
			return null;

		var byteArray = new ByteArray();
		byteArray.writeByte(1); // version
		byteArray.writeShort(Std.int(bounds.x));
		byteArray.writeShort(Std.int(bounds.y));
		byteArray.writeShort(Std.int(bounds.width));
		byteArray.writeShort(Std.int(bounds.height));
		for (yi in Std.int(bounds.y)...Std.int(bounds.bottom))
			for (xi in Std.int(bounds.x)...Std.int(bounds.right)) {
				var tile = this.meMap.getTile(xi, yi);
				if (tile?.types == null) {
					byteArray.writeShort(65535);
					byteArray.writeShort(65535);
					byteArray.writeByte(255);
				} else {
					byteArray.writeShort(tile.types[Layer.GROUND]);
					byteArray.writeShort(tile.types[Layer.OBJECT]);
					byteArray.writeByte(tile.types[Layer.REGION]);
				}
			}
		byteArray.compress();
		return byteArray;
	}

	private function onSave(event: CommandEvent) {
		var mapJSON = this.createMap();
		if (mapJSON == null)
			return;

		new FileReference().save(mapJSON, "map.fm");
	}

	private function onLoad(event: CommandEvent) {
		this.loadedFile = new FileReference();
		this.loadedFile.addEventListener(Event.SELECT, this.onFileBrowseSelect);
		this.loadedFile.browse([new FileFilter("Faer Map (*.fm) or JSON Map (*.jm)", "*.fm;*.jm")]);
	}

	private function onFileBrowseSelect(event: Event) {
		var loadedFile = cast(event.target, FileReference);
		loadedFile.addEventListener(Event.COMPLETE, this.onFileLoadComplete);
		loadedFile.addEventListener(IOErrorEvent.IO_ERROR, this.onFileLoadIOError);
		try {
			loadedFile.load();
		} catch (e: Exception) {
			trace('File load error: ${e.details}, stack trace: ${e.stack}');
		}
	}

	private function onFileLoadComplete(event: Event) {
		var fileRef: FileReference = cast event.target;
		var data = fileRef.data;

		var split = fileRef.name.split('.');
		if (split.length < 2)
			return;

		this.meMap.clear();
		this.commandQueue.clear();

		var ext = split[1];
		if (ext == "fm") {
			data.uncompress();
			var version: UInt8 = data.readUnsignedByte();
			if (version != 1)
				throw new ValueException("Version not supported");

			var xStart: UInt16 = data.readUnsignedShort();
			var yStart: UInt16 = data.readUnsignedShort();
			var w: UInt16 = data.readUnsignedShort();
			var h: UInt16 = data.readUnsignedShort();

			for (y in yStart...yStart + h)
				for (x in xStart...xStart + w) {
					this.meMap.modifyTile(x, y, Layer.GROUND, data.readUnsignedShort());
					this.meMap.modifyTile(x, y, Layer.OBJECT, data.readUnsignedShort());
					this.meMap.modifyTile(x, y, Layer.REGION, data.readUnsignedByte());
				}
		} else if (ext == "jm") {
			var jm = JsonParser.parse(data.toString());

			var bytes: ByteArray = Base64.decode(jm.data);
			bytes.uncompress();
			for (yi in 0...jm.height)
				for (xi in 0...jm.width) {
					var bas = Std.int(bytes.readShort() / 256);
					var entry: Object = jm.dict[bas];
					if (!(xi < 0 || xi >= 256 || yi < 0 || yi >= 256)) {
						if (entry.hasOwnProperty("ground"))
							this.meMap.modifyTile(xi, yi, Layer.GROUND, GroundLibrary.idToType.get(entry.ground));

						if (entry.hasOwnProperty("objs")) {
							var objs: Array<Object> = entry.objs;
							for (obj in objs)
								this.meMap.modifyTile(xi, yi, Layer.OBJECT, ObjectLibrary.idToType.get(obj.id));
						}

						if (entry.hasOwnProperty("regions")) {
							var regions: Array<Object> = entry.regions;
							for (region in regions)
								this.meMap.modifyTile(xi, yi, Layer.REGION, RegionLibrary.idToType.get(region.id));
						}
					}
				}
		}

		this.meMap.draw();
	}

	private function onFileLoadIOError(event: Event) {
		trace("error: " + event);
	}

	private function onTest(_: Event) {
		var savedChars = Global.playerModel.getSavedCharacters();
		if (savedChars == null || savedChars.length == 0)
			return;

		var data = new GameInitData();
		data.charId = savedChars[0].charId();
		data.fmMap = this.createMap();
		Global.playGame(data);
	}
}
