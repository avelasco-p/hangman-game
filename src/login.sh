#!/usr/bin/env bash

database_name="hangman_db"

function login() {
	read -p "enter your nickname: " nickname
	read -s -p "enter your passwod: " passwd
	echo ""
	result=$(psql -t -U postgres -d hangman_db -c "SELECT * FROM player WHERE nickname='$nickname' AND password=MD5('$passwd')")
}