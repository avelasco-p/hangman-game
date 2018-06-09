#!/usr/bin/env bash
source ./crud.sh

#database name hangman_db
#password handled by pgpass file

#arguments: (none)
#------------------------------------------------------------------------------------------------------------------------------------------
#variables:
#	login_result: contains the tuple result of the psql query
#return:
#	0: query was successfull
#	1: query wasnt successfull
#------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------
function login() {
	read -p "enter your nickname: " nickname
	read -s -p "enter your passwod: " passwd
	echo ""
	local login_result=$(get_player $nickname $passwd)

	if [[ $? == 1 ]]; then
		return 1
	else
		return 0
	fi
}
