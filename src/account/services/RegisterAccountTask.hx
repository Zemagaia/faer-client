package account.services;

import cpp.Stdlib;
import cpp.Pointer;
import account.AccountData;
import appengine.RequestHandler;
import lib.tasks.Task;

@:headerCode("#include <appengine/RequestHandler.h>")
class RegisterAccountTask extends Task {
	public static var accountData: AccountData;

	override public function startTask() {
		RequestHandler.setParameter("email", Account.email);
		RequestHandler.setParameter("password", Account.password);
		RequestHandler.complete.once(this.onComplete);
		RequestHandler.sendRequest("/account/register");
	}

	private function onComplete(pCompData: Pointer<CompletionData>) {
		var compData = pCompData.ptr;
		if (compData.success)
			onRegisterDone();

		accountData = null;
		completeTask(compData.success, compData.result);
		Stdlib.free(pCompData);
	}

	private static function onRegisterDone() {
		Account.updateUser(accountData.userName, accountData.email, accountData.password);
	}
}
