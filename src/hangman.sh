#!/usr/bin/env bash
source ./login.sh
source ./crud.sh

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

function show_menu {
	clear;
	echo "$word_aux";
	echo "tries left: $1";
}

function hangman {
	#player_Score has the number of points left
	#tries=$player_score;
	word="$1";
	word_aux="${word//[A-Za-z0-9]/_}";

	while [[ "$player_score" -gt 0 && "$word_aux" != "$word" ]]; do
		show_menu "$player_score";
		read -n 1 -p "enter a letter: " char;
		positions=($(find_in_word "$1" "$char"));

		if [[ ${#positions[@]} -eq 0 ]]; then
			#tries=$(($tries - 1));
			player_score=$(($player_score - 1))
			update_score $player_id $player_score
		else
			positions_str=$(echo "${positions[*]}");
			word_aux=$(place_guess "$positions_str" "$word_aux" "$char");
		fi
	done

	# show menu one last time
	show_menu "$player_score";
	[[ "$word_aux" == "$word" ]] && echo "You won!"
	[[ "$player_score" -eq 0 ]] && echo "Lost!, the word was: $word"
}


for (( i = 0; i <=5; i++ )); do
	login
	if [[ $? == 0 ]]; then
		hangman "$(cat /usr/share/dict/cracklib-small | sort -R | head -n1)";
		break
	else
		echo "error loging in, try again (tries left: $((5-$i)))"
	fi
done
