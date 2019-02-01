// file must begin with comment

// enable unsigned extensions
try {
	Components.utils.import("resource://gre/modules/addons/XPIProvider.jsm", {}).eval("SIGNED_TYPES.clear()");
} catch(ex) {}

// default preferences
lockPref("browser.download.dir", getenv("HOME") + "/downloads");
lockPref("services.sync.client.name", getenv("HOSTNAME"));
lockPref("gfx.webrender.all.qualified", true);
lockPref("layers.acceleration.force-enabled", true);
lockPref("gfx.canvas.azure.accelerated", true);
lockPref("browser.ctrlTab.recentlyUsedOrder", false);
lockPref("general.smoothScroll", false); // this might not be so bad but...
