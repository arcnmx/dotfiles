local modes = require "modes"

modes.remap_binds("command", {
    { ":b[uffers]", ":tabmenu", true },
})

modes.remap_binds("tabmenu", {
    { "x", "<Delete>", false },
})

modes.remap_binds({"insert", "normal"}, {
    { "<Control-i>", "<Control-z>", false },
})

modes.remap_binds("normal", {
    { "x", "d", false },
})

modes.remove_binds("normal", { "<control-w>" })

modes.add_cmds({
    { ":mpv", "Open current URL in mpv",
        function (w) os.execute(string.format("mpv --keep-open=yes %q &", w.view.uri)) end },
    { ":mpa", "Open current URL in mpv (audio only)",
        function (w) os.execute(string.format("urxvt -e mpv --no-video %q &", w.view.uri)) end },
})

-- vim: et:sw=4:ts=8:sts=4:tw=80
