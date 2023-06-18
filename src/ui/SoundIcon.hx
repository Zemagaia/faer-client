package ui;

import openfl.Assets;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.filters.GlowFilter;
import sound.Music;
import sound.SoundEffectLibrary;
import util.AssetLibrary;
import util.Settings;

class SoundIcon extends Sprite {
	private var bitmap: Bitmap;
	private var soundOnTex: BitmapData;
	private var soundOffTex: BitmapData;

	public function new() {
		super();

		this.soundOnTex = Assets.getBitmapData("assets/ui/elements/buttonSoundOn.png");
		this.soundOffTex = Assets.getBitmapData("assets/ui/elements/buttonSoundOff.png");

		this.bitmap = new Bitmap();
		addChild(this.bitmap);

		this.setBitmap();

		addEventListener(MouseEvent.CLICK, this.onIconClick);
	}

	private function setBitmap() {
		this.bitmap.bitmapData = Settings.playMusic || Settings.playSfx ? this.soundOnTex : this.soundOffTex;
	}

	private function onIconClick(event: MouseEvent) {
		var value = !Settings.playMusic && !Settings.playSfx;
		Music.setPlayMusic(value);
		SoundEffectLibrary.setPlaySFX(value);
		Settings.playWepSfx = value;
		Settings.save();
		this.setBitmap();
	}
}
