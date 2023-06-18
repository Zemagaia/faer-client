package ui.dialogs;

import openfl.display.BitmapData;
import util.NativeTypes.Float32;
import openfl.geom.Rectangle;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.CapsStyle;
import openfl.display.Graphics;
import openfl.display.GraphicsPath;
import openfl.display.GraphicsSolidFill;
import openfl.display.GraphicsStroke;
import openfl.display.IGraphicsData;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.filters.DropShadowFilter;
import openfl.text.TextFieldAutoSize;
import openfl.Vector;
import ui.SimpleText;
import ui.TextButton;
import util.GraphicsUtil;

class Dialog extends Sprite {
	public static inline var BUTTON1_EVENT: String = "DIALOG_BUTTON1";
	public static inline var BUTTON2_EVENT: String = "DIALOG_BUTTON2";
	private static inline var WIDTH: Int = 300;

	public var box: Sprite;
	public var textText: SimpleText;
	public var titleText: SimpleText = null;
	public var button1: TextButton = null;
	public var button2: TextButton = null;
	public var offsetX = 0.0;
	public var offsetY = 0.0;
	public var decorContainer: Shape;
	public var closeButton: Bitmap;
	public var closeButtonContainer: Sprite;

	private var closeTexBase: BitmapData;
	private var closeTexHovered: BitmapData;

	public function new(text: String, title: String, button1: String = null, button2: String = null) {
		super();

		var decor = Assets.getBitmapData("assets/ui/tooltips/tooltipFrame.png");
		this.decorContainer = new Shape();
		this.decorContainer.graphics.beginBitmapFill(decor);
		this.decorContainer.graphics.drawRect(0, 0, decor.width, decor.height);
		this.decorContainer.graphics.endFill();
		this.decorContainer.scale9Grid = new Rectangle(6, 6, 36, 36);

		this.closeTexBase = Assets.getBitmapData("assets/ui/elements/xButton.png");
		this.closeTexHovered = Assets.getBitmapData("assets/ui/elements/xButtonHighlight.png");
		this.closeButtonContainer = new Sprite();
		this.closeButton = new Bitmap(this.closeTexBase);
		this.closeButton.x = WIDTH - this.closeButton.width - 10;
		this.closeButton.y = 10;
		this.closeButton.scaleX = this.closeButton.scaleY = 0.75;
		this.closeButtonContainer.addChild(this.closeButton);
		this.closeButtonContainer.addEventListener(MouseEvent.CLICK, this.onCloseClick);
		this.closeButtonContainer.addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
		this.closeButtonContainer.addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);

		this.box = new Sprite();
		this.initText(text);
		this.initTitleText(title);
		if (button1 != null) {
			this.button1 = new TextButton(16, button1);
			this.button1.addEventListener(MouseEvent.CLICK, this.onButton1Click);
		}

		if (button2 != null) {
			this.button2 = new TextButton(16, button2);
			this.button2.addEventListener(MouseEvent.CLICK, this.onButton2Click);
		}

		this.draw();
		addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
	}

	private function onCloseClick(_: MouseEvent) {
		Global.layers.dialogs.closeDialogs();
	}

	private function onRollOver(_: MouseEvent) {
		this.closeButton.bitmapData = this.closeTexHovered;
	}

	private function onRollOut(_: MouseEvent) {
		this.closeButton.bitmapData = this.closeTexBase;
	}

	public function initText(text: String) {
		this.textText = new SimpleText(14, 0xB3B3B3, false, WIDTH - 40, 0);
		this.textText.x = 20;
		this.textText.multiline = true;
		this.textText.wordWrap = true;
		this.textText.htmlText = "<p align=\"center\">" + text + "</p>";
		this.textText.autoSize = TextFieldAutoSize.CENTER;
		this.textText.mouseEnabled = true;
		this.textText.updateMetrics();
		this.textText.filters = [new DropShadowFilter(0, 0, 0, 1, 6, 6, 1)];
	}

	public function draw() {
		if (this.titleText != null) {
			this.titleText.y = 10;
			this.box.addChild(this.titleText);
			this.textText.y = this.box.height + 10;
		} else
			this.textText.y = 10;

		this.box.addChild(this.textText);

		if (this.button1 != null) {
			var by = Std.int(this.box.height + 16);
			this.box.addChild(this.button1);
			this.button1.y = by;
			if (this.button2 == null) {
				this.button1.x = WIDTH / 2 - this.button1.width / 2;
			} else {
				this.button1.x = WIDTH / 4 - this.button1.width / 2;
				this.box.addChild(this.button2);
				this.button2.x = 3 * WIDTH / 4 - this.button2.width / 2;
				this.button2.y = by;
			}
		}

		this.decorContainer.width = WIDTH;
		this.decorContainer.height = this.box.height + 10;
		this.box.addChildAt(this.decorContainer, 0);

		this.box.addChild(this.closeButtonContainer);

		this.box.filters = [new DropShadowFilter(0, 0, 0, 1, 16, 16, 1)];
		addChild(this.box);
	}

	private function initTitleText(title: String) {
		if (title != null) {
			this.titleText = new SimpleText(18, 5746018, false, WIDTH, 0);
			this.titleText.setBold(true);
			this.titleText.htmlText = "<p align=\"center\">" + title + "</p>";
			this.titleText.updateMetrics();
			this.titleText.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8, 1)];
		}
	}

	private function onAddedToStage(event: Event) {
		this.box.x = this.offsetX + stage.stageWidth / 2 - this.box.width / 2;
		this.box.y = this.offsetY + stage.stageHeight / 2 - this.box.height / 2;
	}

	private function onButton1Click(event: MouseEvent) {
		dispatchEvent(new Event(BUTTON1_EVENT));
	}

	private function onButton2Click(event: Event) {
		dispatchEvent(new Event(BUTTON2_EVENT));
	}
}
