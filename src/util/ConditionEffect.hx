package util;

import haxe.ds.StringMap;
import openfl.display.BitmapData;
import openfl.filters.BitmapFilterQuality;
import openfl.filters.GlowFilter;
import openfl.geom.Matrix;

class ConditionEffect {
	public static inline var NOTHING = 0;
	public static inline var DEAD = 1;
	public static inline var WEAK = 2;
	public static inline var SLOWED = 3;
	public static inline var SICK = 4;
	public static inline var SPEEDY = 5;
	public static inline var BLEEDING = 6;
	public static inline var HEALING = 7;
	public static inline var DAMAGING = 8;
	public static inline var INVULNERABLE = 9;
	public static inline var ARMORED = 10;
	public static inline var ARMOR_BROKEN = 11;
	public static inline var HIDDEN = 12;
	public static inline var TARGETED = 13;

	public static inline var DEAD_BIT = 1 << DEAD - 1;
	public static inline var WEAK_BIT = 1 << WEAK - 1;
	public static inline var SLOWED_BIT = 1 << SLOWED - 1;
	public static inline var SICK_BIT = 1 << SICK - 1;
	public static inline var SPEEDY_BIT = 1 << SPEEDY - 1;
	public static inline var BLEEDING_BIT = 1 << BLEEDING - 1;
	public static inline var HEALING_BIT = 1 << HEALING - 1;
	public static inline var DAMAGING_BIT = 1 << DAMAGING - 1;
	public static inline var INVULNERABLE_BIT = 1 << INVULNERABLE - 1;
	public static inline var ARMORED_BIT = 1 << ARMORED - 1;
	public static inline var ARMOR_BROKEN_BIT = 1 << ARMOR_BROKEN - 1;
	public static inline var HIDDEN_BIT = 1 << HIDDEN - 1;
	public static inline var TARGETED_BIT = 1 << TARGETED - 1;

	private static var GLOW_FILTER: GlowFilter = new GlowFilter(0, 0.3, 6, 6, 2, BitmapFilterQuality.HIGH, false, false);
	public static var effects: Array<ConditionEffect> = [
		new ConditionEffect("Nothing", 0, null),
		new ConditionEffect("Dead", DEAD_BIT, null),
		new ConditionEffect("Weak", WEAK_BIT, [5]),
		new ConditionEffect("Slowed", SLOWED_BIT, [7]),
		new ConditionEffect("Sick", SICK_BIT, [10]),
		new ConditionEffect("Speedy", SPEEDY_BIT, [6]),
		new ConditionEffect("Bleeding", BLEEDING_BIT, [2]),
		new ConditionEffect("Healing", HEALING_BIT, [1]),
		new ConditionEffect("Damaging", DAMAGING_BIT, [4]),
		new ConditionEffect("Invulnerable", INVULNERABLE_BIT, [11]),
		new ConditionEffect("Armored", ARMORED_BIT, [3]),
		new ConditionEffect("Armor Broken", ARMOR_BROKEN_BIT, [0]),
		new ConditionEffect("Hidden", HIDDEN_BIT, [9])
	];
	private static var conditionEffectFromName: StringMap<Int> = null;
	private static var bitToIcon: Map<Int, Array<BitmapData>> = null;

	public var name = "";
	public var bit = 0;
	public var iconOffsets: Array<Int>;

	public static function getConditionEffectFromName(name: String) {
		if (conditionEffectFromName == null) {
			conditionEffectFromName = new StringMap<Int>();
			for (ce in 0...effects.length)
				conditionEffectFromName.set(effects[ce].name, ce);
		}

		return conditionEffectFromName.get(name);
	}

	public static function getConditionEffectIcons(condition: Int, icons: Array<BitmapData>, index: Int) {
		var newCondition = 0;
		var bit = 0;
		var iconList: Array<BitmapData> = null;
		while (condition != 0) {
			newCondition = condition & condition - 1;
			bit = condition ^ newCondition;
			iconList = getIconsFromBit(bit);
			if (iconList != null)
				icons.push(iconList[index & (iconList.length - 1)]);

			condition = newCondition;
		}
	}

	private static function getIconsFromBit(bit: Int) {
		var drawMatrix: Matrix = null;
		var icons: Array<BitmapData> = null;
		var icon: BitmapData = null;
		if (bitToIcon == null) {
			bitToIcon = new Map<Int, Array<BitmapData>>();
			drawMatrix = new Matrix();
			drawMatrix.translate(2, 2);
			for (ce in 0...effects.length) {
				icons = null;
				if (effects[ce].iconOffsets != null) {
					icons = new Array<BitmapData>();
					for (i in 0...effects[ce].iconOffsets.length) {
						icon = new BitmapData(20, 20, true, 0);
						icon.draw(AssetLibrary.getImageFromSet("conditions", effects[ce].iconOffsets[i]), drawMatrix);
						icons.push(icon);
					}
				}
				bitToIcon.set(effects[ce].bit, icons);
			}
		}

		return bitToIcon.get(bit);
	}

	public function new(name: String, bit: Int, iconOffsets: Array<Int>) {
		this.name = name;
		this.bit = bit;
		this.iconOffsets = iconOffsets;
	}
}
