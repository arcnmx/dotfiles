import weechat
import re
weechat.register("prettydiscord", "yugge", "0.1", "GPL", "Prettify the discord forwarder output", "", "")
script_options = {
    "botnick" : "discord",
}

discord_nicks = []

for option, default_value in script_options.items():
    if not weechat.config_is_set_plugin(option):
        weechat.config_set_plugin(option, default_value)

def modifier_cb(data, modifier, modifier_data, string):
    botnick = weechat.config_string(weechat.config_get("plugins.var.python.prettydiscord.botnick"))
    if not string.startswith(":"+botnick+"!"):
        return "%s" % (string)

    string = weechat.hook_modifier_exec("irc_color_decode","1",string)
    msg = weechat.info_get_hashtable("irc_message_parse",{"message": string})
    nick = re.search("<(.*?)>",msg["text"]).group(1)
    string = string.replace(msg["nick"],nick+"[D]")
    string = string.replace("<"+nick+"> ","")
    return "%s" % (string)

weechat.hook_modifier("irc_in2_privmsg", "modifier_cb", "")
