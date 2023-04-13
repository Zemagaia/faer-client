package account.services;

import cpp.Pointer;
import cpp.Stdlib;
import appengine.RequestHandler;
import lib.tasks.Task;

@:headerCode("#include <appengine/RequestHandler.h>")
class SendPasswordReminderTask extends Task {
	public static var email = "";

	override public function startTask() {
		RequestHandler.setParameter("email", Account.email);
		RequestHandler.complete.once(this.onComplete);
		RequestHandler.sendRequest("/account/forgotPassword");
	}

	private function onComplete(pCompData: Pointer<CompletionData>) {
		email = null;
		var compData = pCompData.ptr;
		if (compData.success)
			this.onForgotDone();
		else
			this.onForgotError(compData.result);
		Stdlib.free(pCompData);
	}

	private function onForgotDone() {
		completeTask(true);
	}

	private function onForgotError(error: String) {
		completeTask(false, error);
	}
}
