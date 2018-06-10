#!/usr/bin/env bash

db_user="postgres"
db_name="hangman"
usr_max_size=15

# receives an argument and wraps it as a sql query to
# psql
function sql {
	echo "$(psql -t -U $db_user -d $db_name -c "$1")";
}

#this functions is used to log in
#arguments: (usr,pwd)
#	usr: the usr id (or nickname) to log in
#	pwd: the password
#----------------------------------------------------------------------
#variables: (player_id)
#	usr_id: contains the id of the logged in player
#----------------------------------------------------------------------
#return:
#	0: everything was successfull	
#	1: query wasnt successfull
function get_player {
	local result="$(sql "SELECT usr FROM login WHERE usr='$1' AND pwd=MD5('$2');")";

	if [[ -z "$result" ]]; then
		return 1;
	fi

	# separating each part of the result table as
	# a single line, each column separated by space
	echo "$result" | sed 's/\s|\s/ /g' | sed 's/\s//g';
	
	return 0;
}

#arguments: (usr,pwd)
#---------------------------------------------------------------------
#variables:
#return:
#	0: query was successfull
#	1: query wasnt successfull
#---------------------------------------------------------------------
#first argument is username, second argument is the password (not encrypted)
#---------------------------------------------------------------------
function insert_player {
	local result="$(sql "INSERT INTO login values ('$1', MD5('$2'));")";
	if [[ -z $result ]]; then
		return 1
	else
		return 0
	fi
}

#arguments: (word,usr_id)
#	word: content of word to be found
#	usr_id: usr id that owns the word
#---------------------------------------------------------------------
#variables: (curr_word)
#	curr_word: word found returned as a list of strings (id_palabra, palabra,puntos,usr)
#return:
#	0: query was successfull
#	1: query wasnt successfull
#---------------------------------------------------------------------
#first argument is the word guessed id, the second argument is the player's id (logged in)
#---------------------------------------------------------------------
function get_word {
	local result="$(sql "SELECT * FROM palabra WHERE palabra='$1' AND usr='$2'")";

	if [[ -z $result ]]; then
		return 1
	else
		curr_word=($(echo $result | sed 's/\s|\s/\n/g'))
		return 0
	fi
}

#arguments: (word,points,usr_id)
#	word: the word to be added
#	points: an integer, which is a calculated number = word_size * 20
#	usr_id: the id of the logged in usr that wants to add a new word
#---------------------------------------------------------------------
#variables: (none)
#return:
#	0: query was successfull
#	1: query wasnt successfull
#---------------------------------------------------------------------
#first argument is the word to add, the second argument is the player's id (logged in)
#---------------------------------------------------------------------
function insert_word {
	local word_length="$(echo $1 | wc --chars)";
	local points=$(($word_length * 20));
	local result="$(sql "INSERT INTO palabra (palabra, puntos, usr) values ('$1', $points ,'$2');")";

	if [[ -z $result ]]; then
		return 1;
	else
		return 0;
	fi
}

#arguments: (old_word, new_word, usr_id)
#	word: the word to be added
#	usr_id: the id of the logged in player that wants to add a new word
#---------------------------------------------------------------------
#variables: (result)
#return:
#	0: query was successfull
#	1: query wasnt successfull
#---------------------------------------------------------------------
#first argument is the word to update, the second argument is the player's id (logged in)
#---------------------------------------------------------------------
function update_word {
	local result="$(sql "UPDATE palabra SET palabra='$2' WHERE palabra='$1' AND usr='$3'")";

	if [[ -z $result ]]; then
		return 1
	else
		echo $result
		return 0
	fi

}

#arguments: (word,usr_id)
#	word: the word to be deleted
#	usr_id: the id of the logged in player that wants to add a new word (varchar)
#---------------------------------------------------------------------
#variables: (none)
#return:
#	0: query was successfull
#	1: query wasnt successfull
#---------------------------------------------------------------------
#first argument is the word to delete, the second argument is the player's id (logged in)
#---------------------------------------------------------------------
function delete_word {
	local result="$(sql "DELETE FROM palabra WHERE id_palabra='$1' AND usr='$2';")";

	if [[ -z $result ]]; then
		return 1
	else
		return 0
	fi

}

#arguments: (word_id,score_id)
#	word_id: id of the word
#	score_id: the word that is being
#---------------------------------------------------------------------
#variables: (none)
#return:
#	0: query was successfull
#	1: query wasnt successfull
#---------------------------------------------------------------------
#first argument is the word guessed id, the second argument is the player's id (logged in)
#---------------------------------------------------------------------
function insert_word_x_score {
	local result=$(sql "INSERT INTO palabra_x_puntaje (id_palabra, id_puntaje) values ($1,$2);")

	if [[ -z $result ]]; then
		return 1
	else
		return 0
	fi
}

#arguments: (score,usr,date,words)
#	score: new score::integer
#	usr: the usr_id, a varchar (primary key of login table)::string
#	words: the list of words guessed in the session::list<string> 
#---------------------------------------------------------------------
#variables: (none)
#return:
#	0: query was successfull
#	1: query wasnt successfull
#---------------------------------------------------------------------
#first argument is the score to add (end of each game), the second argument is the player's id (logged in), 
#	the third argument is the date of transaction, the 4th argument is the list of words in the session
#---------------------------------------------------------------------
function insert_score {
	local result=$(sql "INSERT INTO puntaje (puntaje, usr) values ('$1','$2');")
	local last_score=$(sql "SELECT id_puntaje from puntaje WHERE usr='$2' order by id_puntaje DESC LIMIT 1;")
	id_list=("$3");

	if [[ -z $result ]]; then
		return 1
	else
		for id in "${id_list[@]}"; do
			insert_word_x_score "$id" "$(echo "$last_score" | sed s/\s//g)";
		done
		return 0
	fi
}

#arguments: ()
#---------------------------------------------------------------------
#return:
#	0: query was successfull
#	1: query wasnt successfull
#---------------------------------------------------------------------
function get_scores {
	local result="$(sql "SELECT usr, puntaje from puntaje ORDER BY puntaje DESC;")"
	if [[ -z "$result" ]]; then
		return 1;
	fi
		echo "$result" | sed 's/\s|\s/ /g';
		return 0;
}

#arguments: (usr, order)
#---------------------------------------------------------------------
#return:
#	0: query was successfull
#	1: query wasnt successfull
#---------------------------------------------------------------------
function get_user_scores {
	local result="$(sql "SELECT puntaje, fecha from puntaje WHERE usr='$1' ORDER BY $2 DESC")"
	if [[ -z "$result" ]]; then
		return 1;
	fi
	echo "$result" | sed 's/\s|\s/ /g';
	return 0;
}


#arguments: (usr_id)
#	usr_nickname: the id of the usr
#----------------------------------------------------------------------
#variables: (usr_words)
#	curr_usr_words: a list of the usr words (only the string content (column 'palabra'))
#----------------------------------------------------------------------
#return:
#	0: everything was successfull	
#	1: query wasnt successfull
function get_player_words {
	local result=$(sql "SELECT palabra, puntos, id_palabra FROM palabra WHERE usr='$1';");

	if [[ -z $result ]]; then
		return 1;
	fi

	echo $result | sed 's/\s|\s/-/g';
	return 0;
}
