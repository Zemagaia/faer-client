package ui.tooltip;

import objects.ItemLibrary;
import network.NetworkHandler.StatType;
import constants.ActivationType;
import objects.ObjectLibrary;
import objects.Player;
import openfl.display.Bitmap;
import openfl.filters.DropShadowFilter;
import ui.LineBreakDesign;
import ui.SimpleText;
import util.BitmapUtil;
import util.Utils;
import constants.ItemConstants;

using util.Utils;

class EquipmentToolTip extends ToolTip {
	private static inline var MAX_WIDTH: Int = 230;

	private var icon: Bitmap;
	private var titleText: SimpleText;
	private var tierText: SimpleText;
	private var line1: LineBreakDesign;
	private var effectsText: SimpleText;
	private var line2: LineBreakDesign;
	private var restrictionsText: SimpleText;
	private var player: Player;
	private var isEquippable = false;
	private var objectType = 0;
	private var curItemXML: Xml = null;
	private var objectXML: Xml = null;
	private var playerCanUse = false;
	private var restrictions: Array<Restriction>;
	private var effects: Array<Effect>;
	private var yOffset = 0;
	private var rarityColor = 0;

	private static function buildRestrictionsHTML(restrictions: Array<Restriction>) {
		var html = "";
		var first = true;
		for (restriction in restrictions) {
			if (!first)
				html += "\n";
			else
				first = false;

			var line = "<font color=\"#" + Std.string(restriction.color) + "\">" + restriction.text + "</font>";
			if (restriction.bold)
				line = "<b>" + line + "</b>";

			html += line;
		}

		return html;
	}

	private static function statToName(stat: String) {
		switch (stat) {
			case "MaxHP":
				return "Health";
			case "MaxMP":
				return "Mana";
			default:
				return stat;
		}
	}

	public static function slotTypeToName(itemType: Int) {
		switch (itemType) {
			case ItemConstants.BOOTS_TYPE:
				return "Boots";
			case ItemConstants.CONSUMABLE_TYPE:
				return "Consumable";
			case ItemConstants.RELIC_TYPE:
				return "Relic";

			case ItemConstants.SWORD_TYPE:
				return "Sword";
			case ItemConstants.BOW_TYPE:
				return "Bow";
			case ItemConstants.STAFF_TYPE:
				return "Staff";

			case ItemConstants.VEST_TYPE:
				return "Vest";
			case ItemConstants.HIDE_TYPE:
				return "Hide";
			case ItemConstants.ROBE_TYPE:
				return "Robe";

			default:
				return "Unknown";
		}
	}

	public function new(objectType: Int, player: Player, invType: Int, inventoryOwnerType: String, inventorySlotID: Int = 1) {
		this.player = player;
		this.playerCanUse = player != null ? ItemLibrary.isUsableByPlayer(objectType, player) : false;
		this.objectXML = ItemLibrary.xmlLibrary.get(objectType);
		this.rarityColor = ColorUtils.getRarityColor(this.objectXML.element("Tier"), 0x999999);
		super(0x424242, 0.6, this.rarityColor, 1, true);
		this.objectType = objectType;
		var equipSlotIndex: Int = this.player != null ? ItemLibrary.getMatchingSlotIndex(this.objectType, this.player) : -1;
		this.isEquippable = equipSlotIndex != -1;
		this.effects = new Array<Effect>();

		if (this.player == null)
			this.curItemXML = this.objectXML;
		else if (this.isEquippable && this.player.equipment[equipSlotIndex] != -1)
			this.curItemXML = ItemLibrary.xmlLibrary.get(this.player.equipment[equipSlotIndex]);

		var scaleValue = ItemLibrary.xmlLibrary.get(this.objectType).intElement("ScaleValue", 5);
		var texture = ItemLibrary.getRedrawnTextureFromType(this.objectType, 60, true, true, scaleValue);
		texture = BitmapUtil.cropToBitmapData(texture, 4, 4, texture.width - 8, texture.height - 8);
		this.icon = new Bitmap(texture);
		this.icon.x = 12;
		this.icon.y = 12;
		addChild(this.icon);

		this.titleText = new SimpleText(16, this.rarityColor, false, Std.int(MAX_WIDTH - this.icon.width - 4 - 30), 0);
		this.titleText.setBold(true);
		this.titleText.setItalic(true);
		this.titleText.wordWrap = true;
		this.titleText.text = ItemLibrary.typeToDisplayId.get(this.objectType);
		this.titleText.updateMetrics();
		this.titleText.filters = [new DropShadowFilter(0, 0, 0, 0.5, 12, 12)];
		this.titleText.x = this.icon.width + 16;
		this.titleText.y = 6;
		addChild(this.titleText);

		this.tierText = new SimpleText(12, this.rarityColor, false, Std.int(MAX_WIDTH - this.icon.width - 4 - 30), 0);
		this.tierText.filters = [new DropShadowFilter(0, 0, 0, 0.5, 12, 12)];
		this.tierText.x = this.icon.width + 16;
		this.tierText.y = this.titleText.y + this.titleText.actualHeight;
		if (this.objectXML.elementExists("Tier"))
			this.tierText.text = this.objectXML.element("Tier");
		else
			this.tierText.text = "Common";

		this.tierText.text += " " + slotTypeToName(this.objectXML.intElement("SlotType"));
		if (this.tierText.text.indexOf("Tier") == -1 && this.objectXML.elementExists("TierReq"))
			tierText.text += " (Tier " + StringUtils.toRoman(this.objectXML.intElement("TierReq")) + ")";
		this.tierText.updateMetrics();
		addChild(this.tierText);

		if (this.objectXML.elementExists("NumProjectiles"))
			this.effects.push(new Effect("Shots", this.objectXML.element("NumProjectiles")));

		if (this.objectXML.elementExists("RateOfFire")) {
			var fireRate = this.objectXML.floatElement("RateOfFire", 1);
			if (fireRate != 1)
				this.effects.push(new Effect("Fire Rate", Std.int(fireRate * 100) + "%"));
		}

		if (this.objectXML.elementExists("Projectile")) {
			var projXML = this.objectXML.elementsNamed("Projectile").next();
			var range = projXML.intElement("Speed") * projXML.intElement("LifetimeMS") / 10000;
			if (projXML.elementExists("Damage"))
				this.effects.push(new Effect("Physical Damage", projXML.element("Damage")));
			if (projXML.elementExists("MagicDamage"))
				this.effects.push(new Effect("Magic Damage", projXML.element("MagicDamage")));
			if (projXML.elementExists("TrueDamage"))
				this.effects.push(new Effect("True Damage", projXML.element("TrueDamage")));
			this.effects.push(new Effect("Range", TooltipHelper.getFormattedString(range)));
			if (this.objectXML.elementExists("MultiHit"))
				this.effects.push(new Effect("", "Piercing"));

			for (condEffectXML in projXML.elementsNamed("ConditionEffect"))
				this.effects.push(new Effect("Shot Effect", condEffectXML.value() + " for " + condEffectXML.attribute("duration") + " secs"));
		}

		for (activateXML in this.objectXML.elementsNamed("Activate"))
			switch (activateXML.value()) {
				case ActivationType.COND_EFFECT_AURA:
					this.effects.push(new Effect("Effect on Group", "Within " + activateXML.attribute("range") + " tiles"));
					this.effects.push(new Effect("", "  " + activateXML.attribute("effect") + " for " + activateXML.attribute("duration") + " secs"));
				case ActivationType.COND_EFFECT_SELF:
					this.effects.push(new Effect("Effect on Self", ""));
					this.effects.push(new Effect("", "  " + activateXML.attribute("effect") + " for " + activateXML.attribute("duration") + " secs"));
				case ActivationType.HEAL:
					this.effects.push(new Effect("", "+" + activateXML.attribute("amount") + " HP"));
				case ActivationType.HEAL_NOVA:
					this.effects.push(new Effect("Party Heal", activateXML.attribute("amount") + " HP at " + activateXML.attribute("range") + " sqrs"));
				case ActivationType.MAGIC:
					this.effects.push(new Effect("", "+" + activateXML.attribute("amount") + " MP"));
				case ActivationType.MAGIC_NOVA:
					this.effects.push(new Effect("Fill Party Magic", activateXML.attribute("amount") + " MP at " + activateXML.attribute("range") + " sqrs"));
				case ActivationType.TELEPORT:
					this.effects.push(new Effect("", "Teleport to Target"));
				case ActivationType.INCREMENT_STAT:
					var stat = activateXML.attribute("stat");
					var amt = activateXML.intAttribute("amount");
					var val = "";
					if (stat != "MaxHP" && stat != "MaxMP")
						val = "Permanently increases " + statToName(stat);
					else
						val = "+" + amt + " " + statToName(stat);

					this.effects.push(new Effect("", val));
				case ActivationType.STAT_BOOST_SELF:
					this.effects.push(new Effect("",
						"+"
						+ activateXML.attribute("amount")
						+ " "
						+ statToName(activateXML.attribute("stat"))
						+ " for "
						+ activateXML.attribute("duration")
						+ " seconds"));
				case ActivationType.STAT_BOOST_AURA:
					this.effects.push(new Effect("",
						"+"
						+ activateXML.attribute("amount")
						+ " "
						+ statToName(activateXML.attribute("stat"))
						+ " for "
						+ activateXML.attribute("duration")
						+ " seconds"));
				case ActivationType.TOTEM:
					this.effects.push(new Effect("", "Summons a Totem for " + activateXML.attribute("duration") + " seconds"));
					this.effects.push(new Effect("Totem",
						(activateXML.attribute("targetPlayers") == "true" ? "Allies" : "Enemies")
						+ " receive "
						+ activateXML.attribute("effect")
						+ " for "
						+ activateXML.attribute("amount")
						+ " seconds"
						+ " within "
						+ activateXML.attribute("radius")
						+ " tiles"));
				case ActivationType.TIER_INCREASE:
					this.effects.push(new Effect("", "Gain Tier " + StringUtils.toRoman(activateXML.intAttribute("amount")) + " on use"));
				case ActivationType.UNLOCK_SKIN:
					var skinXML = ItemLibrary.xmlLibrary.get(activateXML.intAttribute("objType"));
					var classXML = ItemLibrary.xmlLibrary.get(skinXML.intElement("PlayerClassType"));
					this.effects.push(new Effect("Unlocks Skin",
						"\'"
						+ skinXML.element("DisplayId", skinXML.attribute("id"))
						+ "\' "
						+ "("
						+ classXML.element("DisplayId", classXML.attribute("id"))
						+ ")"));
				case ActivationType.OPEN_PORTAL:
					var portalXML = ItemLibrary.xmlLibrary.get(activateXML.intAttribute("objType"));
					this.effects.push(new Effect("Opens Portal", "\'" + portalXML.element("DisplayId", portalXML.attribute("id")) + "\'"));
				case ActivationType.CLOCK:
					this.effects.push(new Effect("", "Rewinds time by " + activateXML.attribute("amount") + " seconds"));
				case ActivationType.DAMAGE_MULTIPLIER:
					this.effects.push(new Effect("",
						"Deal " + activateXML.attribute("amount") + "x damage for " + activateXML.attribute("duration") + " seconds"));
				case ActivationType.HIT_MULTIPLIER:
					this.effects.push(new Effect("",
						"Take " + activateXML.attribute("amount") + "x damage for " + activateXML.attribute("duration") + " seconds"));
				case ActivationType.BLOODSTONE:
					this.effects.push(new Effect("",
						"Steal "
						+ activateXML.attribute("amount")
						+ " HP per target hit,\n"
						+ "up to "
						+ activateXML.attribute("totalDamage")
						+ " HP within "
						+ activateXML.attribute("radius")
						+ " tiles"));
			}

		for (activateXML in this.objectXML.elementsNamed("ActivateOnEquip"))
			if (activateXML.value() == "IncrementStat")
				this.effects.push(new Effect("", this.compareIncrementStat(activateXML)));

		if (this.objectXML.elementExists("Cooldown"))
			this.effects.push(new Effect("Cooldown", this.objectXML.element("Cooldown") + " seconds"));

		if (this.objectXML.elementExists("MpCost"))
			this.effects.push(new Effect("MP Cost", this.objectXML.element("MpCost")));

		if (this.objectXML.elementExists("HpCost"))
			this.effects.push(new Effect("HP Cost", this.objectXML.element("HpCost")));

		this.yOffset = Std.int(this.tierText.y + this.tierText.height + 8);
		if (this.effects.length != 0 || this.objectXML.elementExists("ExtraTooltipData")) {
			this.line1 = new LineBreakDesign(MAX_WIDTH - 12, this.rarityColor);
			this.line1.x = 8;
			this.line1.y = this.yOffset;
			addChild(this.line1);
			this.effectsText = new SimpleText(14, 0xB3B3B3, false, Std.int(MAX_WIDTH - this.icon.width - 4), 0);
			this.effectsText.wordWrap = true;
			this.effectsText.htmlText = this.buildEffectsHTML(this.effects);
			this.effectsText.useTextDimensions();
			this.effectsText.filters = [new DropShadowFilter(0, 0, 0, 0.5, 12, 12)];
			this.effectsText.x = 10;
			this.effectsText.y = this.line1.y + 14;
			addChild(this.effectsText);
			this.yOffset = Std.int(this.effectsText.y + this.effectsText.height + 8);
		}

		this.restrictions = new Array<Restriction>();
		if (this.objectXML.elementExists("Untradable"))
			this.restrictions.push(new Restriction("Untradable", 0xFFFFFF, false));

		if (this.playerCanUse) {
			if (this.objectXML.elementExists("InvUse"))
				this.restrictions.push(new Restriction("Can be used multiple times", 0xFFFFFF, false));
		} else if (this.player != null)
			this.restrictions.push(new Restriction("Not usable by " + ObjectLibrary.typeToDisplayId.get(this.player.objectType), 0xAA0000, true));

		if (this.restrictions.length != 0) {
			this.line2 = new LineBreakDesign(MAX_WIDTH - 12, this.rarityColor);
			this.line2.x = 8;
			this.line2.y = this.yOffset;
			addChild(this.line2);
			this.restrictionsText = new SimpleText(14, 0xB3B3B3, false, MAX_WIDTH - 4, 0);
			this.restrictionsText.wordWrap = true;
			this.restrictionsText.htmlText = "<span class=\'in\'>" + buildRestrictionsHTML(this.restrictions) + "</span>";
			this.restrictionsText.useTextDimensions();
			this.restrictionsText.filters = [new DropShadowFilter(0, 0, 0, 0.5, 12, 12)];
			this.restrictionsText.x = 10;
			this.restrictionsText.y = this.line2.y + 14;
			addChild(this.restrictionsText);
		}
	}

	private function compareIncrementStat(activateXML: Xml) {
		var stat = activateXML.attribute("stat");
		var amount = activateXML.intAttribute("amount");
		return (amount > -1 ? "+" + activateXML.attribute("amount") : activateXML.attribute("amount")) + " " + statToName(stat);
	}

	private function buildEffectsHTML(effects: Array<Effect>) {
		var html = "";
		var first = true;
		for (effect in effects) {
			var textColor = "#FFFF8F";
			if (!first)
				html += "\n";
			else
				first = false;

			if (effect.name != "")
				html += effect.name + ": ";

			if (this.isEquippable && this.curItemXML == null)
				textColor = "#00ff00";

			html += "<font color=\"" + textColor + "\">" + effect.value + "</font>";
		}

		return html;
	}
}

class Effect {
	public var name = "";
	public var value = "";

	public function new(name: String, value: String) {
		this.name = name;
		this.value = value;
	}
}

class Restriction {
	public var text = "";
	public var color = 0;
	public var bold = false;

	public function new(text: String, color: Int, bold: Bool) {
		this.text = text;
		this.color = color;
		this.bold = bold;
	}
}
