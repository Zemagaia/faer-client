package objects;

import constants.ItemConstants;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import objects.animation.AnimationsData;
import openfl.display.BitmapData;
import util.AssetLibrary;
import util.GlowRedrawer;
import util.TextureRedrawer;

using util.Utils.XmlUtil;

class ObjectLibrary {
	public static var propsLibrary: IntMap<ObjectProperties> = new IntMap<ObjectProperties>();
	public static var xmlLibrary: IntMap<Xml> = new IntMap<Xml>();
	public static var idToType: StringMap<Int> = new StringMap<Int>();
	public static var typeToDisplayId: IntMap<String> = new IntMap<String>();
	public static var typeToTextureData: IntMap<TextureData> = new IntMap<TextureData>();
	public static var typeToTopTextureData: IntMap<TextureData> = new IntMap<TextureData>();
	public static var typeToAnimationsData: IntMap<AnimationsData> = new IntMap<AnimationsData>();
	public static var typeToAbilityProps = new IntMap<AbilityProperties>();
	public static var defaultProps: ObjectProperties = new ObjectProperties(null);
	public static var playerChars: Array<Xml> = new Array<Xml>();
	public static var hexTransforms: Array<Xml> = new Array<Xml>();
	public static var playerClassAbbr: IntMap<String> = new IntMap<String>();

	public static function parseFromXML(xml: Xml) {
		var id: String = null;
		var displayId: String = null;
		var objectType = 0;
		var found = false;
		for (objectXML in xml.elementsNamed("Object")) {
			id = objectXML.get("id");
			displayId = id;
			if (objectXML.elementsNamed("DisplayId").hasNext())
				displayId = objectXML.elementsNamed("DisplayId").next().firstChild().nodeValue;

			if (objectXML.elementsNamed("Group").hasNext())
				if (objectXML.elementsNamed("Group").next().firstChild().nodeValue == "Hexable")
					hexTransforms.push(objectXML);

			objectType = Std.parseInt(objectXML.get("type"));
			propsLibrary.set(objectType, new ObjectProperties(objectXML));
			xmlLibrary.set(objectType, objectXML);
			idToType.set(id, objectType);
			typeToDisplayId.set(objectType, displayId);
			if (objectXML.elementsNamed("Class").next().firstChild().nodeValue == "Player") {
				typeToAbilityProps.set(objectType, new AbilityProperties(objectXML));
				playerClassAbbr.set(objectType, objectXML.get("id").substr(0, 2));
				found = false;
				for (i in 0...playerChars.length)
					if (Std.parseInt(playerChars[i].get("type")) == objectType) {
						playerChars[i] = objectXML;
						found = true;
					}

				if (!found)
					playerChars.push(objectXML);
			}

			typeToTextureData.set(objectType, new TextureData(objectXML));

			if (objectXML.elementsNamed("Top").hasNext())
				typeToTopTextureData.set(objectType, new TextureData(objectXML.elementsNamed("Top").next()));

			if (objectXML.elementsNamed("Animation").hasNext())
				typeToAnimationsData.set(objectType, new AnimationsData(objectXML));
		}
	}

	public static function getIdFromType(objType: Int) {
		return xmlLibrary.get(objType)?.get("id");
	}

	public static function getPropsFromId(id: String): ObjectProperties {
		return propsLibrary.get(idToType.get(id));
	}

	public static function getXMLfromId(id: String) {
		return xmlLibrary.get(idToType.get(id));
	}

	public static function getObjectFromType(objectType: Int) {
		if (objectType == 0 || !xmlLibrary.exists(objectType))
			objectType = idToType.get("Crocodile");

		var objectXML = xmlLibrary.get(objectType);
		var objClass = objectXML.element("Class");
		switch (objClass) {
			case "Bazaar" | "Character" | "ClosedStashChest" | "Container" | "FoundingTable" 
				| "GameObject" | "GuildManager" | "GuildHallPortal" | "Merchant" 
				| "SkinChanger" | "Portal" | "Wall":
				return new GameObject(objectXML, objClass);
			case "Player":
				return new Player(objectXML);
			default:
				trace('Could not create object ($objClass)');
				return null;
		}
	}

	public static function getTextureFromType(objectType: Int) {
		return typeToTextureData.get(objectType)?.getTexture();
	}

	public static function getRedrawnTextureFromType(objectType: Int, size: Int, includeBottom: Bool, useCaching: Bool = true, scaleValue: Int = 5) {
		var textureData: TextureData = typeToTextureData.get(objectType);
		var texture: BitmapData = textureData != null ? textureData.getTexture() : null;
		if (texture == null)
			texture = AssetLibrary.getImageFromSet("misc", 0);

		var mask: BitmapData = textureData != null ? textureData.mask : null;
		if (mask == null)
			return TextureRedrawer.redraw(texture, size, includeBottom, 0, useCaching, scaleValue);

		texture = TextureRedrawer.resize(texture, size, includeBottom);
		texture = GlowRedrawer.outlineGlow(texture, 0);
		return texture;
	}

	public static function getSizeFromType(objectType: Int) {
		var objectXML: Xml = xmlLibrary.get(objectType);
		if (!objectXML.elementsNamed("Size").hasNext())
			return 100;

		return Std.parseInt(objectXML.elementsNamed("Size").next().firstChild().nodeValue);
	}
}
