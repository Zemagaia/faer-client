package ui.panels;
import network.NetworkHandler;
import game.GameSprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.filters.DropShadowFilter;
import openfl.text.TextFieldAutoSize;
import openfl.utils.Timer;
import ui.SimpleText;
import ui.TextButton;

class TradeRequestPanel extends Panel {
	public var playerName = "";

	private var title: SimpleText;
	private var rejectButton: TextButton;
	private var acceptButton: TextButton;
	private var timer: Timer;

	public function new(gs: GameSprite, name: String) {
		super(gs);
		this.playerName = name;
		this.title = new SimpleText(18, 0xFFFFFF, false, Panel.WIDTH, 0);
		this.title.setBold(true);
		this.title.htmlText = "<p align=\"center\">" + name + " wants to trade with you</p>";
		this.title.wordWrap = true;
		this.title.multiline = true;
		this.title.autoSize = TextFieldAutoSize.CENTER;
		this.title.filters = [new DropShadowFilter(0, 0, 0)];
		this.title.y = 0;
		addChild(this.title);
		this.rejectButton = new TextButton(16, "Reject");
		this.rejectButton.addEventListener(MouseEvent.CLICK, this.onRejectClick);
		this.rejectButton.x = Panel.WIDTH / 4 - this.rejectButton.width / 2;
		this.rejectButton.y = Panel.HEIGHT - this.rejectButton.height - 4;
		addChild(this.rejectButton);
		this.acceptButton = new TextButton(16, "Accept");
		this.acceptButton.addEventListener(MouseEvent.CLICK, this.onAcceptClick);
		this.acceptButton.x = 3 * Panel.WIDTH / 4 - this.acceptButton.width / 2;
		this.acceptButton.y = Panel.HEIGHT - this.acceptButton.height - 4;
		addChild(this.acceptButton);
		this.timer = new Timer(20 * 1000, 1);
		this.timer.start();
		this.timer.addEventListener(TimerEvent.TIMER, this.onTimer);
	}

	private function onTimer(event: TimerEvent) {
		dispatchEvent(new Event(Event.COMPLETE));
	}

	private function onRejectClick(event: MouseEvent) {
		dispatchEvent(new Event(Event.COMPLETE));
	}

	private function onAcceptClick(event: MouseEvent) {
		NetworkHandler.requestTrade(this.playerName);
		dispatchEvent(new Event(Event.COMPLETE));
	}
}
