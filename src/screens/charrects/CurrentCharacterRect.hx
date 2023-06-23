package screens.charrects;

import openfl.display.BitmapData;
import openfl.Assets;
import openfl.display.Bitmap;
import util.Settings;
import appengine.SavedCharacter;
import characters.ConfirmDeleteCharacterDialog;
import classes.model.CharacterClass;
import game.model.GameInitData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.filters.DropShadowFilter;
import screens.events.DeleteCharacterEvent;
import ui.SimpleText;
import ui.tooltip.ToolTip;

class CurrentCharacterRect extends CharacterRect {
	private static var toolTip: ToolTip = null;

	public var charName = "";
	public var savedChar: SavedCharacter;

	private var charType: CharacterClass;
	private var classNameText: SimpleText;
	private var icon: DisplayObject;
	public var deleteButton: Bitmap;
	public var deleteButtonContainer: Sprite;

	private var deleteTexBase: BitmapData;
	private var deleteTexHovered: BitmapData;


	private static function removeToolTip() {
		if (toolTip != null) {
			if (toolTip.parent != null && toolTip.parent.contains(toolTip))
				toolTip.parent.removeChild(toolTip);
			toolTip = null;
		}
	}

	public function new(charName: String, charType: CharacterClass, savedChar: SavedCharacter) {
		super();
		this.charName = charName;
		this.charType = charType;
		this.savedChar = savedChar;
		this.classNameText = new SimpleText(18, 0xB3B3B3, false, 0, 0);
		this.classNameText.setBold(true);
		this.classNameText.text = "L" + this.savedChar.tier() + " " + this.charType.name;
		this.classNameText.updateMetrics();
		this.classNameText.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8)];
		this.classNameText.x = (202 - this.classNameText.width) / 2 + 71;
		this.classNameText.y = (32 - this.classNameText.height) / 2 + 17;
		addChild(this.classNameText);

		this.deleteTexBase = Assets.getBitmapData("assets/ui/elements/xButton.png");
		this.deleteTexHovered = Assets.getBitmapData("assets/ui/elements/xButtonHighlight.png");
		this.deleteButtonContainer = new Sprite();
		this.deleteButton = new Bitmap(this.deleteTexBase);
		this.deleteButton.x = 288;
		this.deleteButton.y = 16;
		this.deleteButtonContainer.addChild(this.deleteButton);
		this.deleteButtonContainer.addEventListener(MouseEvent.CLICK, this.onDeleteClick);
		this.deleteButtonContainer.addEventListener(MouseEvent.ROLL_OVER, this.onDeleteRollOver);
		this.deleteButtonContainer.addEventListener(MouseEvent.ROLL_OUT, this.onDeleteRollOut);
		addChild(this.deleteButtonContainer);
		
		this.selectContainer.addEventListener(MouseEvent.CLICK, this.onSelected);

		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}

	private function onDeleteClick(_: MouseEvent) {
		Global.charModel.select(this.savedChar);
		Global.layers.dialogs.openDialog(new ConfirmDeleteCharacterDialog());
	}

	private function onDeleteRollOver(_: MouseEvent) {
		this.deleteButton.bitmapData = this.deleteTexHovered;
	}

	private function onDeleteRollOut(_: MouseEvent) {
		this.deleteButton.bitmapData = this.deleteTexBase;
	}

	private function onAdded(_: Event) {
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
	}

	private function onRemoved(_: Event) {
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);

		removeEventListener(MouseEvent.CLICK, this.onSelected);
		// this.deleteButton.removeEventListener(MouseEvent.CLICK, this.onDeleteCharacter);

		removeToolTip();
	}

	private function onSelected(_: MouseEvent) {
		var characterClass: CharacterClass = Global.classModel.getCharacterClass(this.savedChar.objectType());
		characterClass.setIsSelected(true);
		characterClass.skins.getSkin(this.savedChar.skinType()).setIsSelected(true);

		var data: GameInitData = new GameInitData();
		data.createCharacter = false;
		data.charId = this.savedChar.charId();
		Global.playGame(data);
	}

	public function setIcon(value: DisplayObject) {
		if (this.icon != null)
			removeChild(this.icon);
		this.icon = value;
		this.icon.x = this.icon.y = 12;
		if (this.icon != null)
			addChild(this.icon);
	}

	override public function onRollOver(event: MouseEvent) {
		super.onRollOver(event);
		removeToolTip();
	}

	override public function onRollOut(event: MouseEvent) {
		super.onRollOut(event);
		removeToolTip();
	}

	private function onDeleteDown(event: MouseEvent) {
		event.stopImmediatePropagation();
		dispatchEvent(new DeleteCharacterEvent(this.savedChar));
	}
}
