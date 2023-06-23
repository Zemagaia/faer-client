package ui.tooltip;

import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.filters.DropShadowFilter;

class ToolTip extends Sprite {
	public var contentWidth = 0.0;
	public var contentHeight = 0.0;
	public var decorContainer: Sprite;

	private var decor: BitmapData;
	private var followMouse = false;
	private var targetObj: DisplayObject;

	public function new(background: Int, backgroundAlpha: Float, outline: Int, outlineAlpha: Float, followMouse: Bool = true) {
		super();

		this.decor = Assets.getBitmapData("assets/ui/tooltips/tooltipFrame.png");
		this.followMouse = followMouse;
		mouseEnabled = false;
		mouseChildren = false;
		this.decorContainer = new Sprite();
		this.decorContainer.graphics.beginBitmapFill(this.decor);
		this.decorContainer.graphics.drawRect(0, 0, this.decor.width, this.decor.height);
		this.decorContainer.graphics.endFill();
		this.decorContainer.scale9Grid = new Rectangle(29, 29, 1, 1);
		this.decorContainer.x = this.decorContainer.y = -6;
		this.decorContainer.width = this.decorContainer.height = 0;
		addChild(this.decorContainer);
		addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
	}

	public function attachToTarget(dObj: DisplayObject) {
		if (dObj != null) {
			this.targetObj = dObj;
			this.targetObj.addEventListener(MouseEvent.ROLL_OUT, this.onLeaveTarget);
		}
	}

	public function detachFromTarget() {
		if (this.targetObj != null) {
			this.decorContainer.width = this.decorContainer.height = 0; // more hackyness
			this.targetObj.removeEventListener(MouseEvent.ROLL_OUT, this.onLeaveTarget);
			parent?.removeChild(this);
			this.targetObj = null;
		}
	}

	public function draw() {
		this.contentWidth = Math.max(60, width);
		this.contentHeight = Math.max(40, height);

		this.decorContainer.width = this.contentWidth + 12;
		this.decorContainer.height = this.contentHeight + 12;
	}

	private function position() {
		if (Main.primaryStage == null)
			return;

		if (Main.primaryStage.mouseX < Main.stageWidth / 2)
			x = Main.primaryStage.mouseX + 12;
		else
			x = Main.primaryStage.mouseX - width - 1;

		if (x < 12)
			x = 12;

		if (Main.primaryStage.mouseY < Main.stageHeight / 3)
			y = Main.primaryStage.mouseY + 12;
		else
			y = Main.primaryStage.mouseY - height - 1;

		if (y < 12)
			y = 12;
	}

	private function onLeaveTarget(e: MouseEvent) {
		this.detachFromTarget();
	}

	private function onAddedToStage(event: Event) {
		this.draw();
		if (this.followMouse) {
			this.position();
			addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
	}

	private function onRemovedFromStage(event: Event) {
		if (this.followMouse)
			removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
	}

	private function onEnterFrame(event: Event) {
		this.position();
	}
}
