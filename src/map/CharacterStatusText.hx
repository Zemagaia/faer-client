package map;

import openfl.geom.Matrix;
import openfl.display.BitmapData;
import lime.system.System;
import objects.GameObject;
import openfl.display.Sprite;
import openfl.filters.GlowFilter;
import openfl.geom.Point;
import ui.SimpleText;

class CharacterStatusText {
	public static inline var MAX_DRIFT = 40;

	public var go: GameObject;
	public var color = 0;
	public var lifetime = 0;
	public var disposed = false;
	public var startTime = 0;
	public var textTex: BitmapData;

	public function new(go: GameObject, text: String, color: Int, lifetime: Int) {
		this.go = go;
		this.color = color;
		this.lifetime = lifetime;
		this.startTime = System.getTimer();
		this.disposed = false;
		var t = new SimpleText(22, color, false, 0, 0);
		t.setBold(true);
		t.text = text;
		t.updateMetrics();
		t.filters = [new GlowFilter(0, 1, 8, 8, 2, 1)];
		t.x = -t.width / 2;
		t.y = -t.height / 2;
		this.textTex = new BitmapData(Std.int(t.width + 20), 64, true, 0);
		this.textTex.draw(t, new Matrix(1, 0, 0, 1, 12, 0));
	}
}
