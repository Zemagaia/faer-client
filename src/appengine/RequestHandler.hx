package appengine;

import cpp.Pointer;
import haxe.Http;
import util.Settings;
import util.Signal;

@:unreflective
@:structAccess
@:native("CCompletionData")
extern class CompletionData {
	public var success: Bool;
	public var result: String;

	@:native("new CCompletionData")
	public static function create(success: Bool, result: String): Pointer<CompletionData>;
}

@:headerCode('
struct CCompletionData {
   CCompletionData(bool inSuccess, ::String inResult) : success(inSuccess), result(inResult) { }

   bool success;
   ::String result;
};')
class RequestHandler {
	public static var complete = new Signal<Pointer<CompletionData>>();
	public static var maxRetries = 0;
	private static var http = new Http(null);
	private static var retriesLeft = 0;

	public static function init() {
		http.onError = function(text: String) {
			if (text.length == 0)
				text = "Unable to contact server";

			retryOrReportError(text);
		}

		http.onData = function(text: String) {
			if (text.substring(0, 7) == "<Error>")
				retryOrReportError(text);
			else if (text.substring(0, 12) == "<FatalError>")
				cleanUpAndComplete(false, text);
			else
				cleanUpAndComplete(true, text);
		}
	}

	public static inline function setParameter(name: String, value: String) {
		http.setParameter(name, value);
	}

	public static function sendRequest(url: String) {
		http.url = Settings.APP_ENGINE_URL + url;
		retriesLeft = maxRetries;
		http.request(true);
	}

	private static function retryOrReportError(error: String) {
		if (--retriesLeft > 0)
			http.request(true);
		else
			cleanUpAndComplete(true, error);
	}

	private static function cleanUpAndComplete(isOK: Bool, data: String) {
		if (!isOK) {
			var match = ~/<\.*>(.*)<\.*>/.split(data);
			data = match?.length > 1 ? match[1] : data;
		}

		complete.emit(CompletionData.create(isOK, data));
	}
}