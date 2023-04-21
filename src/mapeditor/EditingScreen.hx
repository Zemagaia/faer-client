package mapeditor;

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

class EditingScreen extends Sprite {
	private static inline var MAP_Y = 600 - MEMap.SIZE - 10;

	public var commandMenu: MECommandMenu;
	public var meMap: MEMap;
	public var infoPane: InfoPane;
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

		this.commandMenu = new MECommandMenu();
		this.commandMenu.x = 15;
		this.commandMenu.y = MAP_Y;
		this.commandMenu.addEventListener(CommandEvent.UNDO_COMMAND_EVENT, this.onUndo);
		this.commandMenu.addEventListener(CommandEvent.REDO_COMMAND_EVENT, this.onRedo);
		this.commandMenu.addEventListener(CommandEvent.CLEAR_COMMAND_EVENT, this.onClear);
		this.commandMenu.addEventListener(CommandEvent.LOAD_COMMAND_EVENT, this.onLoad);
		this.commandMenu.addEventListener(CommandEvent.SAVE_COMMAND_EVENT, this.onSave);
		this.commandMenu.addEventListener(CommandEvent.TEST_COMMAND_EVENT, this.onTest);
		addChild(this.commandMenu);

		this.commandQueue = new CommandQueue();
		this.meMap = new MEMap();
		this.meMap.addEventListener(TilesEvent.TILES_EVENT, this.onTilesEvent);
		this.meMap.x = 800 / 2 - MEMap.SIZE / 2;
		this.meMap.y = MAP_Y;
		addChild(this.meMap);

		this.infoPane = new InfoPane(this.meMap);
		this.infoPane.x = 4;
		this.infoPane.y = 600 - InfoPane.HEIGHT - 10;
		addChild(this.infoPane);

		this.chooserDropDown = new DropDown(["Ground", "Objects", "Regions"], Chooser.WIDTH, 26);
		this.chooserDropDown.x = this.meMap.x + MEMap.SIZE + 4;
		this.chooserDropDown.y = MAP_Y;
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

	private function onTilesEvent(event: TilesEvent) {
		var tile: IntPoint = null;
		var type = 0;
		var oldName: String = null;
		var props: EditTileProperties = null;
		tile = event.tiles[0];
		switch (this.commandMenu.getCommand()) {
			case MECommandMenu.DRAW_COMMAND:
				this.addModifyCommandList(event.tiles, this.chooser.layer, this.chooser.selectedType());
			case MECommandMenu.ERASE_COMMAND:
				this.addModifyCommandList(event.tiles, this.chooser.layer, -1);
			case MECommandMenu.SAMPLE_COMMAND:
				type = this.meMap.getType(tile.x, tile.y, this.chooser.layer);
				if (type == -1)
					return;

				this.chooser.setSelectedType(type);
				this.commandMenu.setCommand(MECommandMenu.DRAW_COMMAND);
			case MECommandMenu.EDIT_COMMAND:
				oldName = this.meMap.getObjectName(tile.x, tile.y);
				props = new EditTileProperties(event.tiles, oldName);
				props.addEventListener(Event.COMPLETE, this.onEditComplete);
				addChild(props);
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

			for (y in xStart...xStart + h)
				for (x in yStart...yStart + w) {
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
		// dispatchEvent(new MapTestEvent(this.createMapJSON()));
	}
}
