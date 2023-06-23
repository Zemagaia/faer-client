package objects;

import util.AssetLibrary;
import openfl.display.BitmapData;

using util.Utils.XmlUtil;

class Ability {
	public var icon: BitmapData;
	public var manaCost = 0;
	public var cooldown = 0.0;
	public var name = "";
	public var description = "";

	public function new(objectXML: Xml) { 
		if (objectXML == null)
			return;

		this.manaCost = objectXML.intElement("ManaCost");
		this.cooldown = objectXML.floatElement("Cooldown");
		this.name = objectXML.element("Name");
		this.description = objectXML.element("Description");
		var iconXml = objectXML.elementsNamed("Icon").next();
		this.icon = AssetLibrary.getImageFromSet(iconXml.element("Sheet"), iconXml.intElement("Index"));
	}
}

class AbilityProperties {
	public var ability1: Ability;
	public var ability2: Ability;
	public var ability3: Ability;
	public var ultimateAbility: Ability;

	public function new(objectXML: Xml) {
		this.ability1 = new Ability(objectXML.elementsNamed("Ability1").next());
		this.ability2 = new Ability(objectXML.elementsNamed("Ability2").next());
		this.ability3 = new Ability(objectXML.elementsNamed("Ability3").next());
		this.ultimateAbility = new Ability(objectXML.elementsNamed("UltimateAbility").next());
	}
}