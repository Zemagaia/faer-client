package objects;

import constants.ItemConstants;
import util.GlowRedrawer;
import util.TextureRedrawer;
import util.AssetLibrary;
import haxe.ds.IntMap;
import haxe.ds.StringMap;

class ItemLibrary {
	public static var propsLibrary: IntMap<ItemProperties> = new IntMap<ItemProperties>();
	public static var xmlLibrary: IntMap<Xml> = new IntMap<Xml>();
	public static var idToType: StringMap<Int> = new StringMap<Int>();
	public static var typeToDisplayId: IntMap<String> = new IntMap<String>();
	public static var typeToTextureData: IntMap<TextureData> = new IntMap<TextureData>();

	public static function parseFromXML(xml: Xml) {
		var id: String = null;
		var displayId: String = null;
		var objectType = 0;
		var found = false;
		for (objectXML in xml.elementsNamed("Item")) {
			id = objectXML.get("id");
			displayId = id;
			if (objectXML.elementsNamed("DisplayId").hasNext())
				displayId = objectXML.elementsNamed("DisplayId").next().firstChild().nodeValue;

			objectType = Std.parseInt(objectXML.get("type"));
			xmlLibrary.set(objectType, objectXML);
			propsLibrary.set(objectType, new ItemProperties(objectXML));
			idToType.set(id, objectType);
			typeToDisplayId.set(objectType, displayId);
			typeToTextureData.set(objectType, new TextureData(objectXML));
		}
	}

	public static function getRedrawnTextureFromType(objectType: Int, size: Int, includeBottom: Bool, useCaching: Bool = true, scaleValue: Int = 5) {
		var textureData = typeToTextureData.get(objectType);
		var texture = textureData != null ? textureData.getTexture() : null;
		if (texture == null)
			texture = AssetLibrary.getImageFromSet("misc", 0);

		var mask = textureData != null ? textureData.mask : null;
		if (mask == null)
			return TextureRedrawer.redraw(texture, size, includeBottom, 0, useCaching, scaleValue);

		texture = TextureRedrawer.resize(texture, size, includeBottom);
		texture = GlowRedrawer.outlineGlow(texture, 0);
		return texture;
	}

	public static function getSlotTypeFromType(objectType: Int) {
		var objectXML: Xml = xmlLibrary.get(objectType);
		if (!objectXML.elementsNamed("SlotType").hasNext())
			return -1;

		return Std.parseInt(objectXML.elementsNamed("SlotType").next().firstChild().nodeValue);
	}

	public static function getMatchingSlotIndex(objectType: Int, player: Player) {
		var objectXML: Xml = null;
		var slotType = 0;
		if (objectType != ItemConstants.NO_ITEM) {
			objectXML = xmlLibrary.get(objectType);
			slotType = Std.parseInt(objectXML.elementsNamed("SlotType").next().firstChild().nodeValue);
			for (i in 0...18)
				if (player.slotTypes[i] == slotType)
					return i;
		}

		return -1;
	}

	public static function isUsableByPlayer(objectType: Int, player: Player) {
		if (player == null)
			return true;

		var objectXML: Xml = xmlLibrary.get(objectType);
		if (objectXML == null || !objectXML.elementsNamed("SlotType").hasNext())
			return false;

		var slotType: Int = Std.parseInt(objectXML.elementsNamed("SlotType").next().firstChild().nodeValue);
		if (slotType == ItemConstants.CONSUMABLE_TYPE)
			return true;

		for (i in 0...player.slotTypes.length)
			if (slotsMatching(player.slotTypes[i], slotType))
				return true;

		return false;
	}

	public static function isUntradable(objectType: Int) {
		var objectXML: Xml = xmlLibrary.get(objectType);
		return objectXML != null && objectXML.elementsNamed("Untradable").hasNext();
	}

	public static function slotsMatching(slot1: Int, slot2: Int) {
		if (genericMatch(ItemConstants.WEAPON_TYPES, ItemConstants.ANY_WEAPON_TYPE, slot1, slot2)
			|| genericMatch(ItemConstants.ARMOR_TYPES, ItemConstants.ANY_ARMOR_TYPE, slot1, slot2))
			return true;

		return slot1 == slot2;
	}

	private static function genericMatch(slotTypes: Array<Int>, targetType: Int, slot1: Int, slot2: Int) {
		return slotTypes.indexOf(slot1) != -1 && slot2 == targetType || slotTypes.indexOf(slot2) != -1 && slot1 == targetType;
	}

	public static function getSizeFromType(objectType: Int) {
		var objectXML: Xml = xmlLibrary.get(objectType);
		if (!objectXML.elementsNamed("Size").hasNext())
			return 100;

		return Std.parseInt(objectXML.elementsNamed("Size").next().firstChild().nodeValue);
	}
}
