#!/usr/bin/bash

# detects the existence of a character in a string
# echoes the position in which they where found
function find_in_word {
	echo "$(echo $1 | grep -iob $2 | grep -oE '^[0-9]+')";
}

# more on this function here:
# https://zaiste.net/how_to_join_elements_of_an_array_in_bash
# more on the shift command
# http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_09_07.html
# takes element in an array and produces a string with joint elements
function join {
	local IFS="$1"; shift; echo "$*";
}

function place_guess {
	# converting word into array of chars
	new_word_aux=($(echo $2 | grep -o .));

	for pos in $1; do
		new_word_aux[$pos]="$3";
	done

	echo "$(join '' ${new_word_aux[@]})";
}

function show_progress {
	clear;
	echo "$1";
	echo "points left: $2";
}

function do_round {
	local word word_aux score;
	word="$1";
	word_aux="${word//[A-Za-z0-9]/_}";
	score="$2";

	while [[ "$score" -gt 0 && "$word_aux" != "$word" ]]; do
		show_progress "$word_aux" "$score";
		read -n 1 -p "enter a letter: " char;
		positions=($(find_in_word "$1" "$char"));

		if [[ ${#positions[@]} -eq 0 ]]; then
			score=$(($score - 10));
		else
			positions_str=$(echo "${positions[*]}");
			word_aux=$(place_guess "$positions_str" "$word_aux" "$char");
		fi
	done

	# show menu one last time
	show_progress "$score";
	if [[ "$word_aux" == "$word" ]]; then
		score=$(($score + $2));
		return $(($score));
	elif [[ "$score" -eq 0 ]]; then
		return 0;
	fi
}


function hangman {
	local score words words_ids;
	score=0;
	words=($(get_player_words "$1"));
	word_ids=();

	continue="y";
	while [[ $continue == "y" ]]; do
		word_index=$(($RANDOM % ${#words[@]}));
		params=($(echo ${words[$word_index]} | sed 's/-/\ /g'));
		word_ids+=(${params[2]});

		do_round "${params[0]}" $(("$score" + "${params[1]}"));
		score=$(("$score" + "$?"));
		read -n1 -p "continue? (y/n): " continue;
	done	

	insert_score "$score" "$1" "$word_ids";
}
