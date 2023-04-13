package map;

import lime.system.System;
import objects.GameObject;
import openfl.display.Sprite;
import openfl.filters.GlowFilter;
import openfl.geom.Point;
import ui.SimpleText;

class CharacterStatusText extends Sprite {
	public static inline var MAX_DRIFT = 40;

	public var go: GameObject;
	public var offset: Point;
	public var color = 0;
	public var lifetime = 0;
	public var disposed = false;

	private var startTime = 0;

	public function new(go: GameObject, text: String, color: Int, lifetime: Int) {
		super();

		this.go = go;
		this.offset = new Point(Math.random() * 18 - 9, -go.height * Main.ATLAS_HEIGHT * go.size * 5 - Math.random() * 5 - 15);
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
		addChild(t);
		visible = false;
	}

	public function draw(time: Int) {
		if (this.disposed || this.go != null && this.go.map == null)
			return false;

		var dt = time - this.startTime;
		if (dt > this.lifetime)
			return false;

		if (this.go == null) {
			visible = false;
			return true;
		}

		visible = true;
		var frac = dt / this.lifetime;
		// alpha = 1 - frac + 0.33;
		// scaleX = scaleY = Math.min(1, Math.max(0.7, 1 - frac * 0.3 + 0.075));
		x = (this.go != null ? this.go.screenX : 0) + (this.offset != null ? this.offset.x : 0);
		y = (this.go != null ? this.go.screenYNoZ : 0) + (this.offset != null ? this.offset.y : 0) - frac * MAX_DRIFT;
		return true;
	}

	public function getGameObject() {
		return this.go;
	}

	public function dispose() {
		this.disposed = true;
		parent.removeChild(this);
	}
}
