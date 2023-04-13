package ui.view;

import objects.Player;
import openfl.display.Bitmap;
import openfl.display.GradientType;
import openfl.display.Sprite;
import openfl.filters.DropShadowFilter;
import openfl.geom.Matrix;
import ui.SimpleText;
import ui.StatusBar;
import util.AnimatedChar;
import util.Utils;

class CharacterDetailsView extends Sprite {
	private var portrait: Bitmap;
	private var nameText: SimpleText;
	private var nameDecor: Sprite;
	private var portraitDecor: Sprite;
	private var hpBar: StatusBar;
	private var mpBar: StatusBar;
	private var scale = 0.0;
	private var lastSkin: AnimatedChar;

	public function new(scale: Float = 1) {
		super();

		this.portrait = new Bitmap(null);
		this.portrait.cacheAsBitmap = true;
		this.nameText = new SimpleText(Std.int(15 * scale), 0xB3B3B3, false, 0, 0);
		this.nameText.cacheAsBitmap = true;
		this.scale = scale;
	}

	public function init(player: Player) {
		this.nameDecor = new Sprite();
		this.nameDecor.cacheAsBitmap = true;
		addChild(this.nameDecor);

		var hasMp: Bool = player.maxMP > 0;

		this.hpBar = new StatusBar(Std.int(135 * this.scale), Std.int((hasMp ? 20 : 40) * this.scale), 0xE03434, 0x545454, this.scale);
		this.hpBar.cacheAsBitmap = true;
		this.hpBar.x = 70 * this.scale;
		this.hpBar.y = 24 * this.scale;
		addChild(this.hpBar);

		if (hasMp) {
			this.mpBar = new StatusBar(Std.int(125 * this.scale), Std.int(20 * this.scale), 0x6084E0, 0x545454, this.scale, 4);
			this.mpBar.cacheAsBitmap = true;
			this.mpBar.x = 65 * this.scale;
			this.mpBar.y = 44 * this.scale;
			addChild(this.mpBar);
		}

		this.portraitDecor = new Sprite();
		this.portraitDecor.cacheAsBitmap = true;
		addChild(this.portraitDecor);

		var gradientMatrix: Matrix = new Matrix();
		gradientMatrix.createGradientBox(80 * this.scale, 80 * this.scale, 0, 0, 0);

		this.nameDecor.graphics.clear();
		this.nameDecor.graphics.lineStyle(2 * this.scale, 0x666666);
		this.nameDecor.graphics.beginFill(0x1B1B1B);
		this.nameDecor.graphics.drawRoundRect(50 * this.scale, 5 * this.scale, 115 * this.scale, 20 * this.scale, 15);
		this.nameDecor.graphics.endFill();

		this.portraitDecor.graphics.clear();
		this.portraitDecor.graphics.lineStyle(4 * this.scale, 0x666666);
		this.portraitDecor.graphics.beginGradientFill(GradientType.RADIAL, [ColorUtils.adjustBrightness(0x1B1B1B, 0.15), 0x1B1B1B], [1, 1], [0, 255],
			gradientMatrix);
		this.portraitDecor.graphics.drawCircle(40 * this.scale, 40 * this.scale, 40 * this.scale);
		this.portraitDecor.graphics.endFill();

		this.portrait.bitmapData = player.getPortrait(2 * this.scale);
		this.portrait.x = (80 * this.scale - this.portrait.width) / 2;
		this.portrait.y = (80 * this.scale - this.portrait.height) / 2;
		addChild(this.portrait);
		this.lastSkin = player.skin;

		this.nameText.setBold(true);
		this.nameText.filters = [new DropShadowFilter(0, 0, 0)];
		this.nameText.text = player.name;
		this.nameText.updateMetrics();
		this.nameText.x = (230 * this.scale - this.nameText.width) / 2;
		this.nameText.y = 4 * this.scale;
		addChild(this.nameText);
	}

	public function draw(player: Player) {
		/*if (player.skin != this.lastSkin) {
			if (contains(this.portrait))
				removeChild(this.portrait);
			this.portrait.bitmapData = player.getPortrait(2 * this.scale, player.skin);
			this.portrait.x = (80 * this.scale - this.portrait.width) / 2;
			this.portrait.y = (80 * this.scale - this.portrait.height) / 2;
			addChild(this.portrait);
			this.lastSkin = player.skin;
		}*/

		this.hpBar.draw(player.hp, player.maxHP, player.maxHPBoost, player.maxHPMax);
		if (player.maxMP > 0)
			this.mpBar.draw(Std.int(player.mp), player.maxMP, player.maxMPBoost, player.maxMPMax);
	}

	public function setName(name: String) {
		this.nameText.text = name;
	}
}
