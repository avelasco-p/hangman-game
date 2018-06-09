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
		echo $result
		return 0
	fi
}


#arguments: (<none>)
#-------------------------------------------------------------------------------------------------------------------------------------------
#variables: (result, players, cant_players)
#	result: contains the tuple result of the psql query
#	players: list of players, each element of the list is a string composed by id, nickname and score of each player, each separated by comma
#	cant_players: number of players in db
#-------------------------------------------------------------------------------------------------------------------------------------------
#return:
#	0: everything was successfull	
#	1: query wasnt successfull
function get_players() {
	result=$(psql -t -U postgres -d hangman_db -c "SELECT id, nickname, score FROM player;")

	if [[ -z $result ]]; then
		return 1
	fi

	#separating each part of the result table as a single line, each column separated by space
	result_list=$(echo $result | sed 's/\s|\s/ /g' )

	#each player will be composed as a single string, each column delimited by comma (id,nickname,score)
	players=()

	#every 3 words (cols) theres a new player (id, nickname, score)
	i=0
	player=""
	for col in $result_list; do
		i=$(($i + 1))
		player="$player$col"
		
		if [[ $(($i % 3)) == 0 ]]; then
			players+=("$player")
			player=()
		else
			player="$player,"
		fi
	done

	#defining cant_players variable
	cant_players=$(($i/3))

	return 0
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
#first argument is the word to add, the second argument is the player's id (logged in)
#------------------------------------------------------------------------------------------------------------------------------------------
function delete_word() {
	result=$(psql -t -U postgres -d hangman_db -c "DELETE FROM word WHERE word='$1' AND player_id='$2")

	if [[ -z $result ]]; then
		return 1
	else
		return 0
	fi

}

#create_player velasco 1234
get_players
