// file must begin with comment

// enable unsigned extensions
try {
	Components.utils.import("resource://gre/modules/addons/XPIProvider.jsm", {}).eval("SIGNED_TYPES.clear()");
} catch(ex) {}

// default preferences
let env = Components.classes["@mozilla.org/process/environment;1"].getService(Components.interfaces.nsIEnvironment);
lockPref("browser.download.dir", env.get("HOME") + "/downloads");
lockPref("browser.download.folderList", 2);
lockPref("browser.sessionstore.max_resumed_crashes", 10);
lockPref("browser.startup.homepage", "about:blank");
lockPref("general.smoothScroll", false);
lockPref("services.sync.client.name", env.get("HOSTNAME"));
