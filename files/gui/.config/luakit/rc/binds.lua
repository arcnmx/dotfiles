local modes = require "modes"
local rebind = require "rc.rebind"

rebind(modes.get_mode("command"), ":b[uffers]", ":tabmenu", false)
rebind(modes.get_mode("tabmenu"), "<x>", "<Delete>")

rebind(modes.get_mode("insert"), "<control-i>", "<control-z>")
rebind(modes.get_mode("normal"), "<control-i>", "<control-z>")

rebind(modes.get_mode("normal"), "<x>", "<d>")
modes.remove_binds("normal", { "<control-w>" })

modes.add_cmds({
    { ":mpv", "Open current URL in mpv",
        function (w) os.execute(string.format("mpv %q &", w.view.uri)) end },
    { ":mpa", "Open current URL in mpv (audio only)",
        function (w) os.execute(string.format("urxvt -e mpv --no-video %q &", w.view.uri)) end },
})

-- vim: et:sw=4:ts=8:sts=4:tw=80
