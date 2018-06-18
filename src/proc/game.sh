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
	local diff progress;
	clear;
	draw_logo;
	echo "";

	diff=$(("$3" - "$2"));
	progress=$(("$3" / "${#criminal[@]}"));
	progress=$(("$diff" / "$progress"));

	for line in "${criminal[@]:0:$progress}"; do
		if [[ "$progress" -eq "${#criminal[@]}" ]]; then
			echo "$line" | sed 's/o/x/g';
		else
			echo "$line"
		fi
	done
	echo ""
	echo -e "\t$1";
	echo "points left: $2";
}

# score is in global scope, defined in hangman
function do_round {
	local word word_aux score_aux;
	word="$1";
	word_aux="${word//[A-Za-z0-9]/_}";
	score_aux="$score"

	while [[ "$score" -gt 0 && "$word_aux" != "$word" ]]; do
		show_progress "$word_aux" "$score" "$score_aux";
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
	show_progress "$word_aux" "$score" "$score_aux";
}


function hangman {
	local words words_ids;
	score=0;
	words=($(get_all_words));
	word_ids=();
	if [[ -z "$words" ]]; then
		echo "can't play with no words!"
		read -n1 -p "Press any key to continue..."
		return 1;
	fi

	continue="y";
	while [[ $continue == "y" ]]; do
		word_index=$(($RANDOM % ${#words[@]}));
		params=($(echo ${words[$word_index]} | sed 's/-/\ /g'));
		word_ids+=("${params[2]}");

		score=$(("$score" + "${params[1]}"));
		do_round "${params[0]}" "$score";
		if [[ "$score" -eq 0 ]]; then
			echo "You lost!";
			continue="n";
			read -n1 -p "Press any key to go back to menu..."
		else
			read -n1 -p "continue? (y/n): " continue;
		fi
	done	

	insert_score "$score" "$1" "$word_ids";
}
