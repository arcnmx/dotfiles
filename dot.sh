#!/bin/sh
set -eu

if [ -n "${BASH-}" ]; then
	SELF="${BASH_SOURCE[0]}"
else
	if [ -x "$0" ]; then
		SELF="$0"
	else
		echo "Couldn't find script path, try an absolute path" >&2
		exit 1
	fi
fi

ROOT="$(cd $(dirname "$SELF") && pwd)"
while [ -L "$ROOT" ]; do
	ROOT="$(readlink -e "$ROOT")"
done
INSTALL="$ROOT/$(basename "$SELF")"

if [ $# -lt 1 ]; then
	echo "Usage: $0 COMMAND" >&2
	echo "Commands: dot uninstall update setup newuser" >&2
	exit 1
fi
COMMAND=$1
shift

IS_OSX=
if [[ "$OSTYPE" == darwin* ]]; then
	IS_OSX=y
fi

IS_WINDOWS=
if grep -qs Microsoft /proc/version_signature; then
	IS_WINDOWS=y
fi

CONFIG_ROOT=/opt/arc
PACKAGES_FILE="$CONFIG_ROOT/etc/arc/packages"
HOSTNAME="$(hostname -s)"

stat_uid() {
	local FNAME="$1"
	if [ -n "$IS_OSX" ]; then
		stat -f "%u" "$FNAME"
	else
		stat -c "%u" "$FNAME"
	fi
}

copy_files() {
	local DOTFILES="$1"
	local TARGET="$2"
	(
		cd "$DOTFILES"
		find . -type d -exec mkdir -p "$TARGET/{}" \;
		find . -type f -o -type l -exec rm -f "$TARGET/{}" \;
		find . -type f -exec rm -f "$TARGET/{}" \;
		find . -type f -exec cp -f "{}" "$TARGET/{}" \;
		find . -type l -not -lname delete -exec cp -af "{}" "$TARGET/{}" \;
		find . -type l -lname delete -exec rm -f "$TARGET/{}" \;
	)
}

link_files() {
	local DOTFILES="$1"
	local TARGET="$2"
	(
		cd "$DOTFILES"
		find . -type d -exec mkdir -p "$TARGET/{}" \;
		find . -type f -exec ln -sf "$DOTFILES/{}" "$TARGET/{}" \;
		find . -type l -not -lname delete -exec cp -af "{}" "$TARGET/{}" \;
		find . -type l -lname delete -exec rm -f "$TARGET/{}" \;
	)
}

unlink_files() {
	local DOTFILES="$1"
	local TARGET="$2"
	(
		cd "$DOTFILES"
		find . -type f -exec rm -f "$TARGET/{}" \;
		find . -type l -not -lname delete -exec rm -f "$TARGET/{}" \;
	)
}

package_names() {
	for package in "$@"; do
		case $package in
			remote)
				echo base
				;;
			personal)
				echo base personal
				;;
			desktop)
				echo base personal gui
				;;
			laptop)
				echo base personal gui laptop
				;;
			*)
				echo $package
				;;
		esac
	done
}

packages_ignore() {
	if [ -e "$PACKAGES_FILE" ]; then
		cat "$PACKAGES_FILE"
	else
		echo base
	fi

	if [ -n "$IS_OSX" ]; then
		echo osx
	fi
	if [ -n "$IS_WINDOWS" ]; then
		echo windows
	fi

	echo "$USER"

	echo "$HOSTNAME"
}

packages() {
	if ! [ -e "$PACKAGES_FILE" ]; then
		echo "You must run setup first" >&2
		return 1
	fi

	packages_ignore "$@"
}

package_contents() {
	local DIR="$1"

	for package in $(packages); do
		if [ -e "$DIR/$package" ]; then
			cat "$DIR/$package"
		fi
	done
}

as_brew() {
	BREW=`which brew`
	BREW_UID=$(stat_uid "$BREW")

	if [ "$BREW_UID" -ne "$(id -u)" ]; then
		sudo -Hu "#$BREW_UID" "$@"
	else
		"$@"
	fi
}

brew() {
	BREW=`which brew`

	as_brew "$BREW" "$@"
}

git_update() {
	local ARGS=(-q)

	local URI=$1
	local DIR=$2
	shift 2

	if [ $# -gt 0 ]; then
		local BRANCH=$1
		ARGS+=(-b "$BRANCH")
	fi

	if [ -L "$DIR" ]; then
		true
	elif [ -d "$DIR/.git" ]; then
		(cd "$DIR" && git pull -q --ff-only) || true
	else
		git clone "${ARGS[@]}" "$URI" "$DIR"
	fi
}

case $COMMAND in
	uninstall)
		unlink_files "$ROOT/files" "$HOME"
		;;
	root)
		if [ "$(id -u)" -ne 0 ]; then
			echo "must be root" >&2
			exit 1
		fi

		if su -s /bin/sh nobody -c "stat \"$ROOT\"" > /dev/null 2>&1; then
			REACHABLE=y
		fi

		find / -xdev -lname "$ROOT/root/*" -delete 2>/dev/null || true
		find /etc/systemd/ -type l -delete 2>/dev/null || true

		if [ $# -eq 0 ]; then
			set -- $(packages)
		fi

		for dir in "$@"; do
			dir="$ROOT/root/$dir"
			if [ -d "$dir" ]; then
				if [ -n "${REACHABLE-}" ]; then
					link_files "$dir" /
				else
					copy_files "$dir" /
				fi
			fi
		done
		;;
	update)
		if ! [ -e "$HOME/.dotfiles" ]; then
			ln -s "$ROOT" "$HOME/.dotfiles"
		fi

		if which vim > /dev/null 2>&1 && [ ! -d "/usr/share/vundle" ]; then
			git_update https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
			if [ ! -e "$HOME/.vim/autoload/vundle" ]; then
				mkdir -p "$HOME/.vim/autoload"
				ln -s "$HOME/.vim/bundle/Vundle.vim/autoload/"* "$HOME/.vim/autoload/"
			fi
		fi

		git_update https://github.com/arcnmx/weechat-vimode.git "$HOME/.weechat/weechat-vimode" prefs
		git_update https://github.com/arcnmx/luakit-pass.git "$HOME/.config/luakit/pass"
		git_update https://github.com/arcnmx/luakit-paste.git "$HOME/.config/luakit/paste"
		git_update https://github.com/arcnmx/luakit-unique_instance.git "$HOME/.config/luakit/unique_instance"
		git_update https://github.com/luakit/luakit-plugins.git "$HOME/.config/luakit/plugins"

		if [ "$(stat_uid "$ROOT")" -eq "$(id -u)" ]; then
			find "$HOME" -xdev -lname "$ROOT/files/*" -delete 2>/dev/null || true
			for dir in $(packages_ignore); do
				dir="$ROOT/files/$dir"
				if [ -d "$dir" ]; then
					link_files "$dir" "$HOME"
				fi
			done
			echo | vim +PluginInstall +qall > /dev/null 2>&1
		else
			echo "WARNING: not updating dotfiles, $USER is not owner" >&2
		fi

		if [ -n "$IS_WINDOWS" ]; then
			$ROOT/bin/windows.sh update
		fi

		if [[ "$SHELL" != *zsh ]] && which zsh > /dev/null 2>&1; then
			echo "Changing login shell to zsh..." >&2
			if [ -n "$IS_OSX" ]; then
				for sh in `which -a zsh`; do
					if ! grep -qFx "$sh" /etc/shells; then
						echo "$sh" | sudo tee -a /etc/shells > /dev/null
					fi
				done
			fi

			zsh_shells() {
				(
					cat /etc/shells | sort | uniq -u
					which -a zsh | sort | uniq -u
				) | sort -r | uniq -d
			}
			chsh -s "$(zsh_shells | head -n 1)" "$USER"
		fi

		"$INSTALL" keygen

		;;
	update-system)
		if [ -n "$IS_OSX" ]; then
			brew update
			brew install $(package_contents "$ROOT/homebrew")
		else
			if [ "$(id -u)" -eq 0 ]; then
				"$INSTALL" root
			else
				pacman() {
					sudo pacman "$@"
				}
			fi

			pkg_name() {
				echo "$*" | cut -d / -f 2- | cut -d : -f 2-
			}
			pkg_repo() {
				echo "$*" | cut -d / -f 2- | cut -d : -f 1
			}
			pkg_site() {
				echo "$*" | cut -d / -f 1
			}

			PACKAGES=" "
			PACKAGES_AUR=()
			NOPACKAGES=
			for pkg in $(package_contents "$ROOT/pacman"); do
				if [[ "$pkg" = '!'* ]]; then
					NOPACKAGES="$NOPACKAGES ${pkg:1:${#pkg}}"
				elif ! pacman -Qq $(pkg_name $pkg) > /dev/null 2>&1; then
					if [[ "$pkg" = */* ]]; then
						PACKAGES_AUR+=("$pkg")
					else
						PACKAGES="$PACKAGES $pkg"
					fi
				fi
			done
			for pkg in $NOPACKAGES; do
				PACKAGES=$(echo "$PACKAGES" | sed -e "s/ $pkg / /g")
			done

			PACKAGES=$(echo "$PACKAGES" | sed -e "s/ +/ /g" -e "s/^ $//")

			if [ -n "$PACKAGES" ]; then
				yes | pacman -Sy --needed --noprogressbar $PACKAGES
			fi

			RET=0
			for pkg in ${PACKAGES_AUR[@]+"${PACKAGES_AUR[@]}"}; do
				PKG_SITE=$(pkg_site "$pkg")
				PKG_REPO=$(pkg_repo "$pkg")
				if [[ "$PKG_SITE" = aur ]]; then
					"$ROOT/bin/install-aur.sh" "$PKG_REPO" || RET=$?
				else # github repo slug assumed
					"$ROOT/bin/install-github.sh" "$PKG_SITE/$PKG_REPO" || RET=$?
				fi
			done

			exit $RET
		fi
		;;
	update-self)
		(
			cd "$ROOT"
			git pull -q --ff-only
		)
		"$INSTALL" update
		if [ "$(id -u)" -eq 0 -a -e "$PACKAGES_FILE" ]; then
			"$INSTALL" update-system
		fi
		;;
	keygen)
		if [ "$(id -u)" -ne 0 ]; then
			if [ ! -e "$HOME/.ssh/id_rsa" ]; then
				echo "Generating id_rsa" >&2
				ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -C "$USER@$HOSTNAME"
			fi

			if [ -e "$PACKAGES_FILE" ] && grep -q personal "$PACKAGES_FILE"; then
				IS_PERSONAL=y
			fi
		fi

		if [ -n "${IS_PERSONAL-}" ]; then
			for user in $(cat "$ROOT/data/github-users"); do
				if [ ! -e "$HOME/.ssh/id_rsa_github_$user" ]; then
					echo "Generating github key for $user@github.com" >&2
					ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa_github_$user" -C "$USER@$HOSTNAME $user@github.com"
					if ! "$ROOT/bin/github-upload-key.sh" "$HOME/.ssh/id_rsa_github_$user.pub" "$user"; then
						rm -f "$HOME/.ssh/id_rsa_github_$user"*
						exit 1
					fi
				fi
			done
		fi

		for user in $(cat "$ROOT/data/github-users"); do
			if [ -z "$(shopt -s nullglob; echo "$HOME/.ssh/id_rsa_github_keylist_$user"*.pub)" ]; then
				echo "Downloading github public keys for $user@github.com" >&2
				rm -f "$HOME/.ssh/id_rsa_github_keylist_$user.*.pub"
				COUNTER=0
				KEYS="$("$ROOT/bin/github-get-keys.sh" "$user" || true)"
				if [ -n "$KEYS" ]; then
					echo "$KEYS" | while read line; do
						COUNTER=$((COUNTER+1))
						KEYFILE="$HOME/.ssh/id_rsa_github_keylist_$user.$COUNTER.pub"
						echo "$line" > "$KEYFILE"
					done
				fi
			fi
		done
		;;
	newuser)
		if [ $# -lt 1 ]; then
			echo "Usage: $0 newuser USERNAME [GROUPS]" >&2
			exit 1
		fi
		USERNAME="$1"
		shift

		useradd -mg users -G "$*" -s /bin/zsh "$USERNAME"
		NEW_HOME=`eval echo ~$USERNAME`
		INSTALL_ROOT="$NEW_HOME/.dotfiles"
		(
			cd "$ROOT"
			REMOTE_URL="$(git remote get-url "$(git remote)")"
			REMOTE_PUSH_URL="$(git remote get-url --push "$(git remote)")"
			sudo -Hu "$USERNAME" git clone -q . "$INSTALL_ROOT"
			cp ./.crypt/key "$INSTALL_ROOT/.crypt/"
			chown "$USERNAME":users "$INSTALL_ROOT/.crypt/key"
			cd "$INSTALL_ROOT"
			sudo -Hu "$USERNAME" git remote set-url origin "$REMOTE_URL"
			sudo -Hu "$USERNAME" git remote set-url --push origin "$REMOTE_PUSH_URL"
		)

		if [ -d "$ROOT/.crypt/git-crypt/.git" ]; then
			(
				cd "$ROOT/.crypt/git-crypt"
				REMOTE_CRYPT_URL="$(git remote get-url "$(git remote)")"
				sudo -Hu "$USERNAME" git clone -q . "$INSTALL_ROOT/.crypt/git-crypt"
				cd "$INSTALL_ROOT/.crypt/git-crypt"
				sudo -Hu "$USERNAME" git remote set-url origin "$REMOTE_CRYPT_URL"
			)
		fi

		sudo -Hu "$USERNAME" "$INSTALL_ROOT/dot.sh" crypt-unlock
		sudo -Hu "$USERNAME" "$INSTALL_ROOT/dot.sh" update
		;;
	setup)
		if [ $# -lt 1 ]; then
			echo "Usage: $0 setup TYPE" >&2
			echo "Types: remote, personal, desktop, laptop" >&2
			exit 1
		fi
		TYPE="$1"
		shift

		PACKAGES=`package_names $TYPE`
		if [ ! -e "$CONFIG_ROOT" ]; then
			if [ "$(id -u)" -ne 0 ]; then
				sudo mkdir -p "$CONFIG_ROOT"
				sudo chown "$USER" "$CONFIG_ROOT"
			else
				mkdir -p "$CONFIG_ROOT"
			fi
		fi

		mkdir -p "$(dirname "$PACKAGES_FILE")"
		echo $PACKAGES > "$PACKAGES_FILE"

		if [ -n "$IS_OSX" ]; then
			if ! which brew > /dev/null 2>&1; then
				ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
			fi

			as_brew git config --file="$(brew --repository)/.git/config" --replace-all homebrew.analyticsdisabled true
		fi
		;;
	crypt-unlock)
		if [ ! -f "$ROOT/.crypt/key" ]; then
			"$ROOT/bin/decrypt-key.sh" "$ROOT/.crypt/key.enc" "$ROOT/.crypt/key"
			chmod og-rw "$ROOT/.crypt/key"
		fi

		if ! which git-crypt > /dev/null 2>&1; then
			echo "git-crypt not found in PATH, using shell replacement" >&2
			GIT_CRYPT_DIR="$ROOT/.crypt/git-crypt"
			git_update https://github.com/arcnmx/git-crypt.sh "$GIT_CRYPT_DIR"
			export PATH="$GIT_CRYPT_DIR:$PATH"
		fi

		cd "$ROOT"
		`which git-crypt` unlock "$ROOT/.crypt/key"
		;;
	*)
		echo "Unknown subcommand" >&2
		exit 1
		;;
esac
