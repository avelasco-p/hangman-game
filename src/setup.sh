#!/usr/bin/env bash

DIR="$(dirname "$(readlink -f "$0")")";

source "$DIR/db/crud.sh";

function setup {
	case "$1" in
		"database")
			psql -U "$db_user" -c "CREATE DATABASE $db_name";
			psql -U "$db_user" -d "$db_name" -f "$DIR/hangman_db.psql";
			echo "done...";
			;;
		"install")
			sudo ln -s $DIR/hangman.sh /usr/local/bin/hangman;
			echo "done...";
			return 0;
			;;
		"uninstall")
			psql -U "$db_user" -c "DROP DATABASE $db_name";
			sudo rm /usr/local/bin/hangman;
			echo "done...";
			return 0;
			;;
		*)
			echo "no such option";
			return 1;

	esac
}

setup "$1";
