package ui.panels;

import objects.BasicObject;
import game.GameSprite;
import objects.GameObject;
import openfl.display.Sprite;
import openfl.events.Event;
import ui.panels.itemgrids.ItemGrid;

class InteractPanel extends Sprite {
	public var gs: GameSprite;
	public var w = 0;
	public var h = 0;
	public var currentPanel: Panel = null;
	public var currObjId: Int = -1;
	public var currObj: BasicObject = null;

	private var overridePanel: Panel;

	public function new(gs: GameSprite, w: Int, h: Int) {
		super();

		this.gs = gs;
		this.w = w;
		this.h = h;
	}

	public function setOverride(panel: Panel) {
		if (this.overridePanel != null)
			this.overridePanel.removeEventListener(Event.COMPLETE, this.onComplete);

		this.overridePanel = panel;
		this.overridePanel.addEventListener(Event.COMPLETE, this.onComplete);
	}

	public function redraw() {
		this.currentPanel.draw();
	}

	public function draw() {
		/*graphics.clear();
		if (this.overridePanel != null) {
			graphics.lineStyle(4, 0x666666);
			graphics.beginFill(0x1B1B1B);sa
			graphics.drawRoundRect(0, 0, this.w, this.h, 20);

			this.setPanel(this.overridePanel);
			this.currentPanel.draw();
			return;
		}

		if (this.currentPanel == null || Global.currentInteractiveTarget != this.currObjId) {
			if (!this.gs.map.objects.exists(Global.currentInteractiveTarget)) {
				//if (this.prevPortal != null)
					//this.prevPortal.drawNameExtras = false;

				this.currObjId = -1;
				this.setPanel(new EmptyPanel());
				return;
			}

			this.currObj = this.gs.map.objects.get(Global.currentInteractiveTarget);
			this.currObjId = this.currObj.objectId;

			if (Std.isOfType(this.currObj, Portal)) {
				this.prevPortal = cast(this.currObj, Portal);
				this.prevPortal.drawNameExtras = true;
				this.setPanel(new PortalPanel(this.gs, this.currObjId));
			} else if (this.prevPortal != null)
				this.prevPortal.drawNameExtras = false;

			// this.setPanel(new EmptyPanel());
		}

		if (!Std.isOfType(this.currentPanel, EmptyPanel) && !Std.isOfType(this.currentPanel, PortalPanel)) {
			graphics.lineStyle(2, 0x666666);
			graphics.beginFill(0x1B1B1B);
			graphics.drawRect(0, 0, this.w, this.h);
		}

		this.currentPanel.draw();*/
	}

	public function setPanel(panel: Panel) {
		if (panel != this.currentPanel) {
			if (this.currentPanel != null)
				removeChild(this.currentPanel);
			this.currentPanel = panel;
			if (this.currentPanel != null)
				this.positionPanelAndAdd();
		}
	}

	private function positionPanelAndAdd() {
		if (Std.isOfType(this.currentPanel, ItemGrid)) {
			this.currentPanel.x = (this.w - this.currentPanel.width) * 0.5;
			this.currentPanel.y = 8;
		} else {
			this.currentPanel.x = 6;
			this.currentPanel.y = 8;
		}
		addChild(this.currentPanel);
	}

	private function onComplete(event: Event) {
		if (this.overridePanel != null) {
			this.overridePanel.removeEventListener(Event.COMPLETE, this.onComplete);
			this.overridePanel = null;
		}
		this.setPanel(null);
		this.draw();
	}
}
