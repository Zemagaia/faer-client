package objects;

import util.AssetLibrary;
import openfl.display.BitmapData;

using util.Utils.XmlUtil;

class Ability {
	public var icon: BitmapData;
	public var manaCost = 0;
	public var healthCost = 0;
	public var cooldown = 0.0;
	public var name = "";
	public var description = "";

	public function new(objectXml: Xml) { 
		if (objectXml == null)
			return;

		this.manaCost = objectXml.intElement("ManaCost");
		this.healthCost = objectXml.intElement("HealthCost");
		this.cooldown = objectXml.floatElement("Cooldown");
		this.name = objectXml.element("Name");
		this.description = objectXml.element("Description");
		var iconXml = objectXml.elementsNamed("Icon").next();
		this.icon = AssetLibrary.getImageFromSet(iconXml.element("Sheet"), iconXml.intElement("Index"));
	}
}

class AbilityProperties {
	public var ability1: Ability;
	public var ability2: Ability;
	public var ability3: Ability;
	public var ultimateAbility: Ability;

	public function new(objectXml: Xml) {
		this.ability1 = new Ability(objectXml.elementsNamed("Ability1").next());
		this.ability2 = new Ability(objectXml.elementsNamed("Ability2").next());
		this.ability3 = new Ability(objectXml.elementsNamed("Ability3").next());
		this.ultimateAbility = new Ability(objectXml.elementsNamed("UltimateAbility").next());
	}
}