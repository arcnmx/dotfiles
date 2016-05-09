#!/bin/bash
set -eu

ROOT="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
INSTALL="$ROOT/$(basename "${BASH_SOURCE[0]}")"

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

CONFIG_ROOT=/opt/arc
PACKAGES_FILE="$CONFIG_ROOT/etc/arc/packages"

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
		find . -type f -exec cp -f "{}" "$TARGET/{}" \;
		find . -type l -exec cp -af "{}" "$TARGET/{}" \;
	)
}

link_files() {
	local DOTFILES="$1"
	local TARGET="$2"
	(
		cd "$DOTFILES"
		find . -type d -exec mkdir -p "$TARGET/{}" \;
		find . -type f -exec ln -sf "$DOTFILES/{}" "$TARGET/{}" \;
		find . -type l -exec cp -af "{}" "$TARGET/{}" \;
	)
}

unlink_files() {
	local DOTFILES="$1"
	local TARGET="$2"
	(
		cd "$DOTFILES"
		find . -type f -exec rm -f "$TARGET/{}" \;
		find . -type l -exec rm -f "$TARGET/{}" \;
	)
}

packages() {
	local TYPE="$1"
	case $TYPE in
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
			echo "Unknown type" >&2
			exit 1
	esac
}

as_brew() {
	BREW=`which brew`
	BREW_UID=$(stat_uid "$BREW")

	if [ "$BREW_UID" -ne "$UID" ]; then
		sudo -Hu "#$BREW_UID" "$@"
	else
		"$@"
	fi
}

brew() {
	BREW=`which brew`

	as_brew "$BREW" "$@"
}

case $COMMAND in
	uninstall)
		unlink_files "$ROOT/files" "$HOME"
		;;
	root)
		REACHABLE=
		if sudo -u nobody stat "$ROOT" > /dev/null 2>&1; then
			REACHABLE=y
		fi

		for dir in "$@"; do
			dir="$ROOT/root/$dir"
			if [ -d "$dir" ]; then
				if [ -n "$REACHABLE" ]; then
					link_files "$dir" /
				else
					copy_files "$dir" /
				fi
			fi
		done
		;;
	update)
		if [ ! -d "/usr/share/oh-my-zsh" ]; then
			if [ -d "$HOME/.oh-my-zsh/git/.git" ]; then
				(cd "$HOME/.oh-my-zsh/git" && git pull -q)
			else
				git clone -q https://github.com/robbyrussell/oh-my-zsh.git "$HOME/.oh-my-zsh/git"
			fi
		fi

		if [ ! -d "/usr/share/vundle" ]; then
			if [ -d "$HOME/.vim/bundle/Vundle.vim/.git" ]; then
				(cd "$HOME/.vim/bundle/Vundle.vim" && git pull -q)
			else
				git clone -q https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
				mkdir -p "$HOME/.vim/autoload"
				ln -s "$HOME/.vim/bundle/Vundle.vim/autoload/"* "$HOME/.vim/autoload/"
			fi
		fi

		if [ "$(stat_uid "$ROOT")" -eq "$UID" ]; then
			link_files "$ROOT/files" "$HOME"
			echo | vim +PluginInstall +qall > /dev/null 2>&1
		else
			echo "WARNING: not updating dotfiles, $USER is not owner" >&2
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

		if [ -z "$(shopt -s nullglob; echo "$HOME/.ssh/id_rsa_github_keylist_"*.pub)" ]; then
			for user in $(cat "$ROOT/data/github-users"); do
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
			done
		fi
		;;
	update-system)
		if [ -e "$PACKAGES_FILE" ]; then
			PACKAGES=`cat "$PACKAGES_FILE"`
		else
			echo "You must run setup first" >&2
			exit 1
		fi

		HOSTNAME=`hostname`

		if [ -n "$IS_OSX" ]; then
			(
				cd "$ROOT/homebrew"

				PACKAGES=`cat $PACKAGES`
				if [ -e "$HOSTNAME" ]; then
					PACKAGES="$PACKAGES `cat "$HOSTNAME"`"
				fi

				brew update
				brew upgrade
				brew install $PACKAGES
			)
		else
			"$INSTALL" root $PACKAGES "$HOSTNAME"

			(
				cd "$ROOT/pacman"

				PACKAGES=`cat $PACKAGES`
				if [ -e "$HOSTNAME" ]; then
					PACKAGES="$PACKAGES `cat "$HOSTNAME"`"
				fi

				pacman -Syu --needed --noconfirm $PACKAGES
			)

			(
				cd "$ROOT/pacman/aur"

				PACKAGES=`cat $PACKAGES`
				if [ -e "$HOSTNAME" ]; then
					PACKAGES="$PACKAGES `cat "$HOSTNAME"`"
				fi

				RET=0
				for pkg in $PACKAGES; do
					pacman -Qq $pkg > /dev/null 2>&1 ||
						./install.sh $pkg || RET=$?
				done

				exit $RET
			)
		fi
		;;
	keygen)
		HOSTNAME=`hostname`

		if [ ! -e "$HOME/.ssh/id_rsa" ]; then
			ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -C "$USER@$HOSTNAME"
		fi

		for user in $(cat "$ROOT/data/github-users"); do
			if [ ! -e "$HOME/.ssh/id_rsa_github_$user" ]; then
				ssh-keygen -t rsa -b 4096 -N "" -f "$HOME/.ssh/id_rsa_github_$user" -C "$USER@$HOSTNAME $user@github.com"
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

		HOSTNAME=`hostname`

		useradd -mg users -G "$*" -s /bin/zsh "$USERNAME"
		NEW_HOME=`eval echo ~$USERNAME`
		INSTALL_ROOT="$NEW_HOME/.dotfiles"
		(
			cd "$ROOT"
			REMOTE_URL="$(git remote get-url "$(git remote)")"
			sudo -Hu "$USERNAME" git clone -q . "$INSTALL_ROOT"
			sudo -Hu "$USERNAME" cp ./.crypt/key "$INSTALL_ROOT/.crypt/"
			chown "$USERNAME":users "$INSTALL_ROOT/.crypt/key"
			cd "$INSTALL_ROOT"
			sudo -Hu "$USERNAME" git remote set-url origin "$REMOTE_URL"
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

		sudo -Hu "$USERNAME" "$INSTALL_ROOT/install.sh" crypt-unlock
		sudo -Hu "$USERNAME" "$INSTALL_ROOT/install.sh" update
		;;
	setup)
		if [ $# -lt 1 ]; then
			echo "Usage: $0 setup TYPE" >&2
			echo "Types: remote, personal, desktop, laptop" >&2
			exit 1
		fi
		TYPE="$1"
		shift

		PACKAGES=`packages $TYPE`
		if [ ! -e "$CONFIG_ROOT" ]; then
			if [ "$UID" -ne 0 ]; then
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
			if [ ! -d "$GIT_CRYPT_DIR" ]; then
				git clone -q https://github.com/arcnmx/git-crypt.sh "$GIT_CRYPT_DIR"
			fi
			export PATH="$GIT_CRYPT_DIR:$PATH"
		fi

		`which git-crypt` unlock "$ROOT/.crypt/key"
		;;
	*)
		echo "Unknown subcommand" >&2
		exit 1
		;;
esac
