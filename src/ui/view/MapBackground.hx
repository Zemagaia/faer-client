package ui.view;

import openfl.utils.Object;
import haxe.crypto.Base64;
import objects.GameObject;
import openfl.utils.ByteArray;
import objects.ObjectLibrary;
import objects.ObjectLibrary;
import map.GroundLibrary;
import objects.BasicObject;
import util.Utils;
import map.Camera;
import util.NativeTypes;
import haxe.format.JsonParser;
import lime.system.System;
import map.Map;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.Event;
import util.MacroUtil;
import util.Settings;

class MapBackground extends Sprite {
	private static inline var ANGLE: Float32 = 7 * MathUtil.PI / 4;
	private static inline var TO_SEC_HALF: Float32 = 0.5 / 1000;
	private static var backgroundMap: Map;

	private static function makeMap() {
		var jm = MacroUtil.readJson("assets/misc/BackgroundMap.jm");
		var map = new Map();
		map.setProps(jm.width, jm.height, "Background Map", 0, false, false);
		map.initialize();

		var bytes: ByteArray = Base64.decode(jm.data);
		bytes.uncompress();
		for (yi in 0...jm.height)
			for (xi in 0...jm.width) {
				var bas = Std.int(bytes.readShort() / 256);
				var entry: Object = jm.dict[bas];
				if (!(xi < 0 || xi >= map.mapWidth || yi < 0 || yi >= map.mapHeight)) {
					if (entry.hasOwnProperty("ground"))
						map.setGroundTile(xi, yi, GroundLibrary.idToType.get(entry.ground));

					if (entry.hasOwnProperty("objs")) {
						var objs: Array<Object> = entry.objs;
						for (obj in objs) {
							var objType = ObjectLibrary.idToType.get(obj.id);
							var go = ObjectLibrary.getObjectFromType(objType);
							go.size = go.props.getSize() / 100;
							go.objectId = BasicObject.getNextFakeObjectId();
							map.addGameObject(go, xi + 0.5, yi + 0.5);
						}
					}
				}
			}

		return map;
	}

	public function new() {
		super();

		if (Settings.DISABLE_MAP_BG)
			return;

		addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
	}

	private function onAddedToStage(_: Event) {
		addChild(backgroundMap = makeMap());
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	private function onRemovedFromStage(_: Event) {
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	private static function onEnterFrame(_: Event) {
		var time: Int32 = System.getTimer();
		var xVal: Float32 = 60 + 5 * MathUtil.sin(time * TO_SEC_HALF);
		var yVal: Float32 = 70 + 5 * MathUtil.sin(time * TO_SEC_HALF);
		Camera.configureCamera(xVal, yVal);
		backgroundMap.draw(time);
	}
}
