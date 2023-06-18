package account;

import util.Settings;

class Account {
	public static var userName = "";
	public static var email = "";
	public static var password = "";

	public static function updateUser(newName: String,newEmail: String, newPassword: String) {
		userName = newName;
		email = newEmail;
		password = newPassword;

		Settings.savedEmail = newEmail;
		Settings.save();
	}

	public static function clear() {
		updateUser("Guest", "", "");
	}
}
