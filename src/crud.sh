#!/usr/bin/env bash

#arguments: (nickname,password)
#------------------------------------------------------------------------------------------------------------------------------------------
#variables:
#	result: contains the tuple result of the psql query
#return:
#	0: query was successfull
#	1: query wasnt successfull
#------------------------------------------------------------------------------------------------------------------------------------------
#first argument is nickname, second argument is the password (not encrypted)
#------------------------------------------------------------------------------------------------------------------------------------------
function create_player() {
	result=$(psql -t -U postgres -d hangman_db -c "INSERT INTO player (nickname, password) values ('$1', MD5('$2'));")
	if [[ -z $result ]]; then
		return 1
	else
		return 0
	fi
}

#arguments: (word,player_id)
#	word: the word to be added
#	player_id: the id of the logged in player that wants to add a new word
#------------------------------------------------------------------------------------------------------------------------------------------
#variables:
#	result: contains the tuple result of the psql query
#return:
#	0: query was successfull
#	1: query wasnt successfull
#------------------------------------------------------------------------------------------------------------------------------------------
#first argument is the word to add, the second argument is the player's id (logged in)
#------------------------------------------------------------------------------------------------------------------------------------------
function create_word() {
	result=$(psql -t -U postgres -d hangman_db -c "INSERT INTO word (word, player_id) values ('$1','$2');")

	if [[ -z $result ]]; then
		return 1
	else
		return 0
	fi

}

#arguments: (word,player_id)
#	word: the word to be added
#	player_id: the id of the logged in player that wants to add a new word
#------------------------------------------------------------------------------------------------------------------------------------------
#variables:
#	result: contains the tuple result of the psql query
#return:
#	0: query was successfull
#	1: query wasnt successfull
#------------------------------------------------------------------------------------------------------------------------------------------
#first argument is the word to delete, the second argument is the player's id (logged in)
#------------------------------------------------------------------------------------------------------------------------------------------
function delete_word() {
	result=$(psql -t -U postgres -d hangman_db -c "DELETE FROM word WHERE word='$1' AND player_id='$2")

	if [[ -z $result ]]; then
		return 1
	else
		return 0
	fi

}

#arguments: (nickname,password)
#-------------------------------------------------------------------------------------------------------------------------------------------
#variables: (player_id, player_nickname, player_score)
#	player_id: contains the player id
#	player_nickname: contains the nickname of the player
#	player_score: contains the player score
#-------------------------------------------------------------------------------------------------------------------------------------------
#return:
#	0: everything was successfull	
#	1: query wasnt successfull
function get_player() {
	local result=$(psql -t -U postgres -d hangman_db -c "SELECT id, nickname, score FROM player WHERE nickname='$1' AND password=MD5('$2');")

	if [[ -z $result ]]; then
		return 1
	fi

	#separating each part of the result table as a single line, each column separated by space
	local result_list=$(echo $result | sed 's/\s|\s/ /g' )

	#getting player variables
	local i=0
	for var in $result_list; do
		if [[ $i == 0 ]]; then
			player_id=$var
		elif [[ $i == 1 ]]; then
			player_nickname=$var
		else
			player_score=$var
		fi

		i=$(($i + 1))
	done

	return 0
}



#echo $player_id
#echo $player_nickname
#echo $player_score
