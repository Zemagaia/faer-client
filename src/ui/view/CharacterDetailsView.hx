package ui.view;

import openfl.text.TextFormatAlign;
import openfl.display.Shape;
import openfl.Assets;
import objects.Player;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.filters.DropShadowFilter;
import ui.SimpleText;
import ui.StatusBar;
import util.AnimatedChar;

class CharacterDetailsView extends Sprite {
	private var decor: Bitmap;
	private var portrait: Bitmap;
	private var hpBar: Bitmap;
	private var hpBarText: SimpleText;
	private var mpBar: Bitmap;
	private var mpBarText: SimpleText;
	private var xpBar: Bitmap;
	private var nameText: SimpleText;
	private var scale = 0.0;
	private var lastSkin: AnimatedChar;

	public function new(scale: Float = 1) {
		super();

		this.decor = new Bitmap(Assets.getBitmapData("assets/ui/playerInterfaceDecor.png"));
		this.decor.scaleX = this.decor.scaleY = 2 * scale;
		this.decor.cacheAsBitmap = true;

		this.hpBar = new Bitmap(Assets.getBitmapData("assets/ui/playerInterfaceHealthBar.png"));
		this.hpBar.scaleX = this.hpBar.scaleY = 2 * scale;
		this.hpBar.cacheAsBitmap = true;

		this.hpBarText = new SimpleText(Std.int(15 * scale), 0xB3B3B3, false, 360);
		this.hpBarText.setAlignment(TextFormatAlign.CENTER);
		this.hpBarText.setBold(true);
		this.hpBarText.filters = [new DropShadowFilter(0, 0, 0)];

		this.mpBar = new Bitmap(Assets.getBitmapData("assets/ui/playerInterfaceManaBar.png"));
		this.mpBar.scaleX = this.mpBar.scaleY = 2 * scale;
		this.mpBar.cacheAsBitmap = true;

		this.mpBarText = new SimpleText(Std.int(15 * scale), 0xB3B3B3, false, 360);
		this.mpBarText.setAlignment(TextFormatAlign.CENTER);
		this.mpBarText.setBold(true);
		this.mpBarText.filters = [new DropShadowFilter(0, 0, 0)];

		this.xpBar = new Bitmap(Assets.getBitmapData("assets/ui/playerInterfaceXPBar.png"));
		this.xpBar.scaleX = this.xpBar.scaleY = 2 * scale;
		this.xpBar.cacheAsBitmap = true;

		this.portrait = new Bitmap(null);
		this.portrait.cacheAsBitmap = true;

		this.nameText = new SimpleText(Std.int(15 * scale), 0xFCDF00, false, 0, 0);
		this.nameText.cacheAsBitmap = true;
		this.scale = scale;
	}

	public function init(player: Player) {
		addChild(this.decor);

		this.hpBar.x = 106 * this.scale;
		this.hpBar.y = 8 * this.scale;
		addChild(this.hpBar);

		this.hpBarText.x = 106 * this.scale;
		this.hpBarText.y = 8 * this.scale;
		addChild(this.hpBarText);

		this.mpBar.x = 106 * this.scale;
		this.mpBar.y = 38 * this.scale;
		addChild(this.mpBar);

		this.mpBarText.x = 106 * this.scale;
		this.mpBarText.y = 38 * this.scale;
		addChild(this.mpBarText);

		this.xpBar.x = 106 * this.scale;
		this.xpBar.y = 68 * this.scale;
		addChild(this.xpBar);

		/*var hasMp: Bool = player.maxMP > 0;

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
		}*/

		this.portrait.bitmapData = player.getPortrait(2 * this.scale);
		this.portrait.x = (100 * this.scale - this.portrait.width) / 2;
		this.portrait.y = (90 * this.scale - this.portrait.height) / 2;
		addChild(this.portrait);
		this.lastSkin = player.skin;

		this.nameText.setBold(true);
		this.nameText.filters = [new DropShadowFilter(0, 0, 0)];
		this.nameText.text = player.name;
		this.nameText.updateMetrics();
		this.nameText.x = (370 * this.scale - this.nameText.width) / 2;
		this.nameText.y = 68 * this.scale;
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

		this.hpBar.scaleX = 2 * this.scale * (player.hp / player.maxHP);
		this.mpBar.scaleX = 2 * this.scale * (player.mp / player.maxMP);
		this.hpBarText.setText('${player.hp}/${player.maxHP} ${player.maxHPBoost > 0 ? '(+${player.maxHPBoost})' : ''}');
		this.hpBarText.setColor(player.maxHP - player.maxHPBoost >= player.maxHPMax ? 0xFCDF00 : (player.maxHPBoost > 0 ? 0x5EB531 : 0xB3B3B3));
		this.hpBarText.updateMetrics();
		this.mpBarText.setText('${player.mp}/${player.maxMP} ${player.maxMPBoost > 0 ? '(+${player.maxMPBoost})' : ''}');
		this.mpBarText.setColor(player.maxMP - player.maxMPBoost >= player.maxMPMax ? 0xFCDF00 : (player.maxMPBoost > 0 ? 0x5EB531 : 0xB3B3B3));
		this.mpBarText.updateMetrics();

		/*this.hpBar.draw(player.hp, player.maxHP, player.maxHPBoost, player.maxHPMax);
		if (player.maxMP > 0)
			this.mpBar.draw(Std.int(player.mp), player.maxMP, player.maxMPBoost, player.maxMPMax);*/
	}

	public function setName(name: String) {
		this.nameText.text = name;
	}
}
