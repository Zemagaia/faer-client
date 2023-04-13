package ui.options;

import openfl.events.Event;

class ChoiceOption extends Option {
	private var callback: () -> Void;
	private var choiceBox: ChoiceBox;

	public function new(paramName: String, labels: Array<String>, values: Array<String>, desc: String, tooltipText: String, callback: () -> Void) {
		super(paramName, desc, tooltipText);
		this.callback = callback;
		//this.choiceBox = new ChoiceBox(labels, values, Settings.values.get(paramName));
		//this.choiceBox.addEventListener(Event.CHANGE, this.onChange);
		//addChild(this.choiceBox);
	}

	override public function refresh() {
		//this.choiceBox.setValue(Settings.values.get(paramName));
	}

	private function onChange(event: Event) {
		//Settings.values.set(paramName, Std.string(this.choiceBox.value()));
		//Settings.save();
		if (this.callback != null)
			this.callback();
	}
}
