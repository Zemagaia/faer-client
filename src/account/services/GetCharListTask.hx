package account.services;

import cpp.Stdlib;
import cpp.Pointer;
import appengine.RequestHandler;
import lib.tasks.Task;
import openfl.events.TimerEvent;
import openfl.utils.Timer;

@:headerCode("#include <appengine/RequestHandler.h>")
class GetCharListTask extends Task {
	private var retryTimer: Timer;

	override public function startTask() {
		this.sendRequest();
	}

	private function sendRequest() {
		RequestHandler.setParameter("email", Account.email);
		RequestHandler.setParameter("password", Account.password);
		RequestHandler.complete.once(this.onComplete);
		RequestHandler.sendRequest("/char/list");
	}

	private function onComplete(pCompData: Pointer<CompletionData>) {
		var compData = pCompData.ptr;
		if (compData.success)
			this.onListComplete(compData.result);
		else
			this.onListComplete("EOF");
		Stdlib.free(pCompData);
	}

	private function onListComplete(data: String) {
		if (data != "EOF" && data.indexOf("Error") == -1) {
			Global.parseCharList(Xml.parse(data).firstElement());
			completeTask(true);
		} else
			completeTask(false);

		if (this.retryTimer != null)
			this.stopRetryTimer();
	}

	private function stopRetryTimer() {
		this.retryTimer.stop();
		this.retryTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, this.onRetryTimer);
		this.retryTimer = null;
	}

	private function onRetryTimer(event: TimerEvent) {
		this.stopRetryTimer();
		this.sendRequest();
	}
}
