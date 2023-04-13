package mapeditor;

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

	private function createMapJSON() {
		/*var xi = 0;
			var tile: METile = null;
			var entry: Object = null;
			var entryJSON: String = null;
			var index = 0;
			var bounds: Rectangle = this.meMap.getTileBounds();
			if (bounds == null) {
				return null;
			}
			var jm: Object = {};
			jm["width"] = Std.int(bounds.width);
			jm["height"] = Std.int(bounds.height);
			var dict: Object = {};
			var entries: Array<Object> = [];
			var byteArray: ByteArray = new ByteArray();
			for (yi in Std.int(bounds.y)...Std.int(bounds.bottom))
				for (xi in Std.int(bounds.x)...Std.int(bounds.right)) {
					tile = this.meMap.getTile(xi, yi);
					entry = this.getEntry(tile);
					entryJSON = JsonPrinter.print(entry);
					if (!dict.hasOwnProperty(entryJSON)) {
						index = entries.length;
						dict[entryJSON] = index;
						entries.push(entry);
					} else
						index = dict[entryJSON];

					byteArray.writeUnsignedShort(index);
				}
			jm["dict"] = entries;
			byteArray.compress();
			jm["data"] = Base64.encode(byteArray);
			return JsonPrinter.print(jm);*/
	}

	private function onSave(event: CommandEvent) {
		/*var mapJSON = this.createMapJSON();
			if (mapJSON == null)
				return;

			new FileReference().save(mapJSON, this.filename_ == null ? "map.fm" : this.filename_); */
	}

	private function onLoad(event: CommandEvent) {
		this.loadedFile = new FileReference();
		this.loadedFile.addEventListener(Event.SELECT, this.onFileBrowseSelect);
		this.loadedFile.browse([new FileFilter("Faer Map (*.fm)", "*.fm")]);
	}

	private function onFileBrowseSelect(event: Event) {
		var loadedFile = cast(event.target, FileReference);
		loadedFile.addEventListener(Event.COMPLETE, this.onFileLoadComplete);
		loadedFile.addEventListener(IOErrorEvent.IO_ERROR, this.onFileLoadIOError);
		try {
			loadedFile.load();
		} catch (e) {
			trace("Error: " + e);
		}
	}

	private function onFileLoadComplete(event: Event) {
		var data = cast(event.target, FileReference).data;
		data.uncompress();
		var version: UInt8 = data.readUnsignedByte();
		if (version != 1)
			throw new ValueException("Version not supported");

		var w: UInt16 = data.readUnsignedShort();
		var h: UInt16 = data.readUnsignedShort();
		var objTypes = new Array<UInt16>(), layerTypes = new Array<UInt8>();
		var len = data.readUnsignedShort();
		var byteRead = len <= 256;
		for (i in 0...len) {
			objTypes.push(data.readUnsignedShort());
			layerTypes.push(data.readUnsignedByte());
		}		

		this.meMap.clear();
		this.commandQueue.clear();
		for (y in 0...h)
			for (x in 0...w) {
				var layer = layerTypes[byteRead ? data.readUnsignedByte() : data.readUnsignedShort()];
				var objType = objTypes[byteRead ? data.readUnsignedByte() : data.readUnsignedShort()];
				switch (layer) {
					case Layer.GROUND:
						this.meMap.modifyTile(x, y, Layer.GROUND, objType);
					case Layer.OBJECT:
						this.meMap.modifyTile(x, y, Layer.OBJECT, objType);
					case Layer.REGION:
						this.meMap.modifyTile(x, y, Layer.REGION, objType);
					default:
						throw new ValueException('Unknown layer $layer (objType: $objType)');
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
