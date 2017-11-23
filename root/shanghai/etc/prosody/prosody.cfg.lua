daemonize = true
pidfile = "/run/prosody/prosody.pid"

-- prosodyctl check config

use_libevent = true

c2s_ports = { 5322 }
c2s_interfaces = { "*", "::" }

s2s_ports = { 5369 }
s2s_interfaces = { "*" }

--plugin_paths = {}

modules_enabled = {
	-- Generally required
		"roster"; -- Allow users to have a roster. Recommended ;)
		"saslauth"; -- Authentication for clients and servers. Recommended if you want to log in.
		"tls"; -- Add support for secure TLS on c2s/s2s connections
		"dialback"; -- s2s dialback support
		"disco"; -- Service discovery

	-- Not essential, but recommended
		"carbons"; -- Keep multiple clients in sync
		"pep"; -- Enables users to publish their mood, activity, playing music and more
		"private"; -- Private XML storage (for room bookmarks, etc.)
		"blocklist"; -- Allow users to block communications with other users
		"vcard"; -- Allow users to set vCards

	-- Nice to have
		"version"; -- Replies to server version requests
		"uptime"; -- Report how long server has been running
		"time"; -- Let others know the time here on this server
		"ping"; -- Replies to XMPP pings with pongs
		"register"; -- Allow users to register on this server using a client and change passwords
		--"mam"; -- Store messages in an archive and allow users to access it

	-- Admin interfaces
		"admin_adhoc"; -- Allows administration via an XMPP client that supports ad-hoc commands
		--"admin_telnet"; -- Opens telnet console interface on localhost port 5582

	-- HTTP modules
		--"bosh"; -- Enable BOSH clients, aka "Jabber over HTTP"
		--"websocket"; -- XMPP over WebSockets
		--"http_files"; -- Serve static files from a directory over HTTP

	-- Other specific functionality
		--"limits"; -- Enable bandwidth limiting for XMPP connections
		--"groups"; -- Shared roster support
		--"server_contact_info"; -- Publish contact information for this service
		"announce"; -- Send announcement to all online users
		--"welcome"; -- Welcome users who register accounts
		--"watchregistrations"; -- Alert admins of registrations
		--"motd"; -- Send a message to users when they log in
		--"legacyauth"; -- Legacy authentication. Only used by some old clients and bots.
		--"proxy65"; -- Enables a file transfer proxy service which clients behind NAT can use
}

modules_disabled = {
	"offline"; -- Store offline messages
	-- "c2s"; -- Handle client connections
	-- "s2s"; -- Handle server-to-server connections
	-- "posix"; -- POSIX functionality, sends server to background, enables syslog, etc.
}

allow_registration = false
c2s_require_encryption = true
s2s_require_encryption = false

s2s_secure_auth = false -- server to server cert validation
s2s_insecure_domains = { } -- override when s2s_secure_auth == false
s2s_secure_domains = { } -- override when s2s_secure_auth == true

authentication = "internal_hashed"

storage = "internal" -- or "sql"
--sql = { driver = "SQLite3", database = "prosody.sqlite" } -- Default. 'database' is the filename.
--sql = { driver = "MySQL", database = "prosody", username = "prosody", password = "secret", host = "localhost" }
--sql = { driver = "PostgreSQL", database = "prosody", username = "prosody", password = "secret", host = "localhost" }


-- https://prosody.im/doc/modules/mod_mam
archive_expires_after = "1w" -- Remove archived messages after 1 week

-- https://prosody.im/doc/logging
log = {
	-- info = "prosody.log"; -- Change 'info' to 'debug' for verbose logging
	-- error = "prosody.err";
	"*syslog";
	-- "*console";
}

-- https://prosody.im/doc/statistics
-- statistics = "internal"

-- https://prosody.im/doc/certificates
certificates = "certs" -- cert directory location relative to main config

Include '/etc/prosody/prosody-domains.cfg.lua'

-- https://prosody.im/doc/components
