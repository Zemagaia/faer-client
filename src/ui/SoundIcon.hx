package ui;

import openfl.Assets;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import sound.Music;
import sound.SoundEffectLibrary;
import util.Settings;

class SoundIcon extends Sprite {
	private var decor: Bitmap;
	private var soundOnTexBase: BitmapData;
	private var soundOnTexHover: BitmapData;
	private var soundOnTexPress: BitmapData;
	private var soundOffTexBase: BitmapData;
	private var soundOffTexHover: BitmapData;
	private var soundOffTexPress: BitmapData;
	private var hovering: Bool;
	private var pressed: Bool;

	public function new() {
		super();

		this.soundOnTexBase = Assets.getBitmapData("assets/ui/elements/buttonSoundOn.png");
		this.soundOnTexHover = Assets.getBitmapData("assets/ui/elements/buttonSoundOnHover.png");
		this.soundOnTexPress = Assets.getBitmapData("assets/ui/elements/buttonSoundOnPress.png");
		this.soundOffTexBase = Assets.getBitmapData("assets/ui/elements/buttonSoundOff.png");
		this.soundOffTexHover = Assets.getBitmapData("assets/ui/elements/buttonSoundOffHover.png");
		this.soundOffTexPress = Assets.getBitmapData("assets/ui/elements/buttonSoundOffPress.png");

		this.decor = new Bitmap();
		this.decor.x = this.decor.y = 5;
		addChild(this.decor);

		this.decor.bitmapData = this.isSoundOn() ? this.soundOnTexBase : this.soundOffTexBase;

		addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
		addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
		addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
		addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, this.onMouseDown);
		addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, this.onMouseDown);
		addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		addEventListener(MouseEvent.MIDDLE_MOUSE_UP, this.onMouseUp);
		addEventListener(MouseEvent.RIGHT_MOUSE_UP, this.onMouseUp);
	}

	private inline function isSoundOn() {
		return Settings.playMusic || Settings.playSfx;
	}

	private function onRollOver(_: MouseEvent) {
		this.hovering = true;
		this.decor.bitmapData = this.isSoundOn() ? this.soundOnTexHover : this.soundOffTexHover;
	}

	private function onMouseUp(_: MouseEvent) {
		this.pressed = false;

		var soundOn = !this.isSoundOn();

		Settings.playWepSfx = soundOn;
		Music.setPlayMusic(soundOn);
		SoundEffectLibrary.setPlaySFX(soundOn);

		if (this.hovering)
			this.onRollOver(null);
		else
			this.decor.bitmapData = soundOn ? this.soundOnTexBase : this.soundOffTexBase;
	}

	private function onRollOut(_: MouseEvent) {
		this.hovering = false;
		if (this.pressed)
			this.onMouseDown(null);
		else 
			this.decor.bitmapData = this.isSoundOn() ? this.soundOnTexBase : this.soundOffTexBase;
	}

	private function onMouseDown(_: MouseEvent) {
		this.pressed = true;
		this.decor.bitmapData = this.isSoundOn() ? this.soundOnTexPress : this.soundOffTexPress;
	}
}
