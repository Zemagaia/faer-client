package map;

import lime.system.System;
import objects.GameObject;
import openfl.display.CapsStyle;
import openfl.display.GraphicsPath;
import openfl.display.GraphicsSolidFill;
import openfl.display.GraphicsStroke;
import openfl.display.IGraphicsData;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.Sprite;
import openfl.filters.DropShadowFilter;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.Vector;
import ui.SimpleText;
import util.GraphicsUtil;

class SpeechBalloon extends Sprite {
	public var go: GameObject;
	public var lifetime = 0;
	public var hideable = false;
	public var offset: Point;
	public var text: TextField;
	public var disposed = false;

	private var backgroundFill = new GraphicsSolidFill(0, 1);
	private var outlineFill = new GraphicsSolidFill(0xFFFFFF, 1);
	private var lineStyle = new GraphicsStroke(2, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND, 3, new GraphicsSolidFill(0xFFFFFF, 1));
	private var path = new GraphicsPath();
	private var graphicsData = new Vector<IGraphicsData>(0, false, [
		new GraphicsStroke(2, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND, 3, new GraphicsSolidFill(0xFFFFFF, 1)),
		new GraphicsSolidFill(0, 1),
		new GraphicsPath(),
		GraphicsUtil.END_FILL,
		GraphicsUtil.END_STROKE
	]);
	private var startTime = 0;

	public function new(go: GameObject, text: String, background: Int, backgroundAlpha: Float, outline: Int, outlineAlpha: Float, textColor: Int,
			lifetime: Int, bold: Bool, hideable: Bool) {
		super();

		this.offset = new Point();
		mouseEnabled = false;
		mouseChildren = false;
		this.go = go;
		this.lifetime = lifetime * 1000;
		this.hideable = hideable;
		this.disposed = false;
		this.text = new TextField();
		this.text.autoSize = TextFieldAutoSize.LEFT;
		this.text.embedFonts = true;
		this.text.width = 150;
		var format: TextFormat = new TextFormat();
		format.font = SimpleText.font.fontName;
		format.size = 14;
		format.bold = bold;
		format.color = textColor;
		this.text.defaultTextFormat = format;
		this.text.selectable = false;
		this.text.mouseEnabled = false;
		this.text.multiline = true;
		this.text.wordWrap = true;
		this.text.text = text;
		addChild(this.text);
		var w: Int = Std.int(this.text.textWidth + 4);
		this.offset.x = -w / 2;
		this.backgroundFill.color = background;
		this.backgroundFill.alpha = backgroundAlpha;
		this.outlineFill.color = outline;
		this.outlineFill.alpha = outlineAlpha;
		this.lineStyle.fill = this.outlineFill;
		this.graphicsData[0] = this.lineStyle;
		this.graphicsData[1] = this.backgroundFill;
		graphics.clear();
		GraphicsUtil.clearPath(this.path);
		GraphicsUtil.drawCutEdgeRect(-6, -6, w + 12, Std.int(height + 12), 4, [1, 1, 1, 1], this.path);
		this.graphicsData[2] = this.path;
		graphics.drawGraphicsData(this.graphicsData);
		filters = [new DropShadowFilter(0, 0, 0, 1, 16, 16)];
		this.offset.y = -height - this.go.height * Main.ATLAS_HEIGHT * go.size * 5 - 2;
		visible = false;
		this.startTime = System.getTimer();
	}

	public function draw(time: Int) {
		var dt = time - this.startTime;
		if (dt > this.lifetime || this.go != null && this.go.map == null)
			return false;

		if (this.go == null) {
			visible = false;
			return true;
		}

		visible = true;
		x = this.go.screenX + this.offset.x;
		y = this.go.screenYNoZ + this.offset.y;
		return true;
	}

	public function dispose() {
		this.disposed = true;
		parent.removeChild(this);
	}
}
