package screens.charrects;

import appengine.SavedCharacter;
import assets.CharacterFactory;
import classes.model.CharacterClass;
import classes.model.CharacterSkin;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import screens.NewCharacterScreen;

class CharacterRectList extends Sprite {
	public var count: Int = 0;
	
	public function new() {
		super();

		this.count = Global.playerModel.getSavedCharacters().length + Global.playerModel.getAvailableCharSlots() + 1;
		this.updateBoxes(1);
	}

	public function updateBoxes(page: Int) {
		removeChildren();

		var buyRect: BuyCharacterRect;
		var charType: CharacterClass = null;
		var currCharBox: CurrentCharacterRect = null;
		var newCharRect: CreateNewCharacterRect = null;
		var charName: String = Global.playerModel.getName();
		var yOffset = 4.0, xFlip = 0.0, idx = 0;
		for (savedChar in Global.playerModel.getSavedCharacters()) {
			if (idx < 15 * (page - 1)) {
				idx++;
				continue;
			}
				
			charType = Global.classModel.getCharacterClass(savedChar.objectType());
			currCharBox = new CurrentCharacterRect(charName, charType, savedChar);
			currCharBox.setIcon(getIcon(savedChar));
			currCharBox.x = xFlip;
			currCharBox.y = yOffset;
			addChild(currCharBox);
			if (idx % 3 == 2) {
				xFlip = 0;
				yOffset += currCharBox.height + 4;
			} else
				xFlip += currCharBox.width + 5;

			idx++;
			if (idx == 15 * page)
				return;
		}

		if (Global.playerModel.hasAvailableCharSlot()) {
			for (i in 0...Global.playerModel.getAvailableCharSlots()) {
				if (idx < 15 * (page - 1)) {
					idx++;
					continue;
				}

				newCharRect = new CreateNewCharacterRect();
				newCharRect.addEventListener(MouseEvent.MOUSE_DOWN, onNewChar);
				newCharRect.x = xFlip;
				newCharRect.y = yOffset;
				addChild(newCharRect);
				if (idx % 3 == 2) {
					xFlip = 0;
					yOffset += newCharRect.height + 4;
				} else
					xFlip += newCharRect.width + 5;

				idx++;
				if (idx == 15 * page)
					return;
			}
		}

		buyRect = new BuyCharacterRect();
		buyRect.addEventListener(MouseEvent.MOUSE_DOWN, onBuyCharSlot);
		buyRect.x = xFlip;
		buyRect.y = yOffset;
		addChild(buyRect);
	}

	private static function getIcon(savedChar: SavedCharacter): DisplayObject {
		var chrClass: CharacterClass = Global.classModel.getCharacterClass(savedChar.objectType());
		var skin: CharacterSkin = chrClass.skins.getSkin(savedChar.skinType()) != null ? chrClass.skins.getSkin(savedChar.skinType()) : chrClass.skins.getDefaultSkin();
		var data: BitmapData = CharacterFactory.makeIcon(skin.template, 75);
		return new Bitmap(data);
	}

	private static function onNewChar(event: Event) {
		Global.layers.screens.setScreen(new NewCharacterScreen());
	}

	private static function onBuyCharSlot(event: Event) {
		Global.buyCharSlot();
	}
}
