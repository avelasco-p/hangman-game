#!/usr/bin/env bash

#database name hangman_db
#password handled by pgpass file

#arguments: (none)
#------------------------------------------------------------------------------------------------------------------------------------------
#variables:
#	result: contains the tuple result of the psql query
#return:
#	0: query was successfull
#	1: query wasnt successfull
#------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------
function login() {
	read -p "enter your nickname: " nickname
	read -s -p "enter your passwod: " passwd
	echo ""
	login_result=$(psql -t -U postgres -d hangman_db -c "SELECT * FROM player WHERE nickname='$nickname' AND password=MD5('$passwd')")

	if [[ -z $login_result ]]; then
		return 1
	else
		return 0
	fi
}
