package account.services;

import cpp.Stdlib;
import cpp.Pointer;
import appengine.RequestHandler;
import lib.tasks.Task;

@:headerCode("#include <appengine/RequestHandler.h>")
class BuyCharacterSlotTask extends Task {
	override public function startTask() {
		RequestHandler.setParameter("email", Account.email);
		RequestHandler.setParameter("password", Account.password);
		RequestHandler.maxRetries = 2;
		RequestHandler.complete.once(this.onComplete);
		RequestHandler.sendRequest("/account/purchaseCharSlot");
	}

	private function onComplete(pCompData: Pointer<CompletionData>) {
		var compData = pCompData.ptr;
		if (compData.success)
			updatePlayerData();
		completeTask(compData.success, compData.result);
		Stdlib.free(pCompData);
	}

	private static function updatePlayerData() {
		Global.playerModel.setMaxCharacters(Global.playerModel.getMaxCharacters() + 1);
		Global.playerModel.addGems(-Global.playerModel.getNextCharSlotPrice());
	}
}
